pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "./Keyboard" as Strategies

// Proxy/adapter singleton for keyboard layout data.
// Tries Hyprland first, falls back to basic.
//
// ─── Strategy interface ───────────────────────────────────────────────────────
//
// Every strategy must expose:
//
//   available: bool       // true if layout detection is working
//   layout:    string     // current layout name, e.g. "English (US)"
//   shortName: string     // abbreviated, e.g. "US"
//
// Capslock is read directly from sysfs (hardware state, not WM-specific).
//
// ─────────────────────────────────────────────────────────────────────────────
Singleton {
    id: root

    property var impl: hyprland.available ? hyprland : basic

    readonly property bool available:    impl.available
    readonly property string layout:     impl.layout
    readonly property string shortName:  impl.shortName
    readonly property bool capsLock:     capsState === "1"

    property string capsState: "0"
    property string capsPath: ""

    // Find the first capslock LED path in sysfs.
    Process {
        id: findCapsProc
        command: ["sh", "-c", "ls -1 /sys/class/leds/*/brightness 2>/dev/null | grep capslock | head -1"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const path = this.text.trim()
                if (path) root.capsPath = path
            }
        }
    }

    Process {
        id: capsProc
        command: ["cat", root.capsPath]
        running: false
        stdout: StdioCollector {
            onStreamFinished: root.capsState = this.text.trim()
        }
    }

    Timer {
        interval: 500
        running: root.capsPath !== ""
        repeat: true
        onTriggered: capsProc.running = true
    }

    Strategies.HyprlandStrategy { id: hyprland }
    Strategies.BasicStrategy    { id: basic }
}
