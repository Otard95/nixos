import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.WindowManager

// WM-agnostic fallback using standard Wayland protocols.
//
// Limitations vs. the Hyprland strategy:
//   - Workspaces use the WindowManager abstraction (no Hyprland-specific data).
//   - Active window has no per-monitor tracking; the same globally active window
//     is shown on every monitor.
Scope {
    id: root

    property var workspacesByMonitor:   ({})
    property var activeWindowByMonitor: ({})
    property string activeMode: ""
    // No generic Wayland protocol reports the focused output directly, so this
    // is best-effort: the screen of the active toplevel (foreign-toplevel-
    // management). Empty when nothing is active (e.g. an empty workspace);
    // consumers then fall back to the first screen.
    readonly property string focusedMonitorName:
        ToplevelManager.activeToplevel?.screens?.[0]?.name ?? ""
    readonly property string backend: "wlr"
    readonly property bool hasFocusGrab: false

    function buildWorkspaces() {
        const result = {}
        for (const screen of Quickshell.screens.values) {
            const proj = WindowManager.screenProjection(screen)
            result[screen.name] = proj.windowsets.values.map(ws => {
                const ref = ws
                return {
                    id:       ws.id,
                    name:     ws.name,
                    active:   ws.active,
                    focused:  ws.active,
                    activate: () => ref.activate()
                }
            })
        }
        root.workspacesByMonitor = result
    }

    function buildActiveWindow() {
        const wt = ToplevelManager.activeToplevel
        const result = {}
        for (const screen of Quickshell.screens.values) {
            result[screen.name] = wt ? { title: wt.title, appId: wt.appId } : null
        }
        root.activeWindowByMonitor = result
    }

    Component.onCompleted: {
        buildWorkspaces()
        buildActiveWindow()
    }

    Connections {
        target: WindowManager
        function onWindowsetsChanged() { root.buildWorkspaces() }
    }

    Connections {
        target: ToplevelManager
        function onActiveToplevelChanged() { root.buildActiveWindow() }
    }
}
