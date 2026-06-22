import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Scope {
    id: root

    property bool available: false
    property string layout: ""
    property string shortName: ""

    // Map full layout names to short codes.
    function shorten(name) {
        const lower = name.toLowerCase()
        if (lower.includes("english") && lower.includes("us")) return "US"
        if (lower.includes("norw") || lower.includes("(no)")) return "NO"
        if (lower.includes("japanese") || lower.includes("mozc")) return "JP"
        if (lower.includes("german")) return "DE"
        if (lower.includes("french")) return "FR"
        if (lower.includes("spanish")) return "ES"
        if (lower.includes("swedish")) return "SE"
        if (lower.includes("danish")) return "DK"
        if (lower.includes("finnish")) return "FI"
        // Fallback: first two uppercase letters
        const match = name.match(/\((\w+)\)/)
        if (match) return match[1].toUpperCase()
        return name.slice(0, 2).toUpperCase()
    }

    // Seed from hyprctl on startup — find the main keyboard.
    Process {
        id: seedProc
        command: ["hyprctl", "-j", "devices"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const devices = JSON.parse(this.text)
                    // Skip virtual/system keyboards, pick the first real one.
                    const skip = ["video-bus", "power-button", "sleep-button",
                                  "system-control", "consumer-control"]
                    for (const kb of devices.keyboards) {
                        if (skip.some(s => kb.name.includes(s))) continue
                        root.layout = kb.active_keymap
                        root.shortName = root.shorten(kb.active_keymap)
                        root.available = true
                        break
                    }
                } catch(e) {}
            }
        }
    }

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            // activelayout>>keyboard_name,layout_name
            if (event.name === "activelayout") {
                const idx = event.data.indexOf(",")
                if (idx >= 0) {
                    const layoutName = event.data.slice(idx + 1)
                    root.layout = layoutName
                    root.shortName = root.shorten(layoutName)
                    root.available = true
                }
            }
        }
    }
}
