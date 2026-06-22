import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland

Scope {
    id: root

    property var workspacesByMonitor:   ({})
    property var activeWindowByMonitor: ({})
    property string activeMode: ""

    function buildWorkspaces() {
        const result = {}
        for (const ws of Hyprland.workspaces.values) {
            if (!ws.monitor) continue
            const mon = ws.monitor.name
            if (!result[mon]) result[mon] = []
            const ref = ws
            result[mon].push({
                id:       ws.id,
                name:     ws.name,
                active:   ws.active,
                focused:  ws.focused,
                activate: () => ref.activate()
            })
        }
        root.workspacesByMonitor = result
    }

    function buildActiveWindow() {
        const ht = Hyprland.activeToplevel
        const wt = ToplevelManager.activeToplevel
        if (!ht || !ht.monitor || !wt) return
        const next = Object.assign({}, root.activeWindowByMonitor)
        next[ht.monitor.name] = { title: wt.title, appId: wt.appId }
        root.activeWindowByMonitor = next
    }

    // Track the focused monitor name so rawEvent handlers know where
    // to attribute window changes.
    property string focusedMonitorName: Hyprland.focusedMonitor?.name ?? ""

    // ── Startup seed ──────────────────────────────────────────────────
    // Hyprland.activeToplevel is null on startup (IPC only reports
    // changes). Query hyprctl directly to get all clients with their
    // monitor IDs, then join with monitor names to seed every monitor.

    property var monitorIdToName: ({})

    // Step 1: get monitor id→name mapping.
    Process {
        id: monitorProc
        command: ["hyprctl", "-j", "monitors"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const monitors = JSON.parse(this.text)
                    const map = {}
                    for (const m of monitors)
                        map[m.id] = m.name
                    root.monitorIdToName = map
                    clientProc.running = true
                } catch(e) {}
            }
        }
    }

    // Step 2: get all clients, pick most recently focused per monitor.
    Process {
        id: clientProc
        command: ["hyprctl", "-j", "clients"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const clients = JSON.parse(this.text)
                    // Lower focusHistoryID = more recently focused.
                    clients.sort((a, b) => a.focusHistoryID - b.focusHistoryID)
                    const result = {}
                    for (const c of clients) {
                        const monName = root.monitorIdToName[c.monitor]
                        if (!monName || result[monName]) continue
                        result[monName] = { title: c.title, appId: c.class }
                    }
                    root.activeWindowByMonitor = result
                } catch(e) {}
            }
        }
    }

    Timer {
        interval: 500
        running: true
        repeat: false
        onTriggered: root.buildWorkspaces()
    }

    // ── Live updates ──────────────────────────────────────────────────
    // focusedWorkspace/focusedMonitor are real property change signals.
    // workspaces is an ObjectModel — it mutates in place, so we listen
    // to its insert/remove signals instead.
    Connections {
        target: Hyprland
        function onFocusedWorkspaceChanged() { root.buildWorkspaces() }
        function onFocusedMonitorChanged()   { root.buildWorkspaces() }

        function onRawEvent(event) {
            // activewindow>>class,title
            if (event.name === "activewindow") {
                const parts = event.data.split(",")
                const cls = parts[0]
                const title = parts.slice(1).join(",")
                if (cls && title && root.focusedMonitorName) {
                    const next = Object.assign({}, root.activeWindowByMonitor)
                    next[root.focusedMonitorName] = { appId: cls, title: title }
                    root.activeWindowByMonitor = next
                }
            }
            // windowtitle>>address — title changed on existing window
            if (event.name === "windowtitle") {
                Qt.callLater(root.buildActiveWindow)
            }
            // submap>>name — empty when returning to default
            if (event.name === "submap") {
                root.activeMode = event.data
            }
        }
    }

    Connections {
        target: Hyprland.workspaces
        function onObjectInsertedPost() { root.buildWorkspaces() }
        function onObjectRemovedPost()  { root.buildWorkspaces() }
    }
}
