import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root

    property bool available: false
    property bool dnd: false

    function toggle() {
        toggleProc.command = dnd
            ? ["makoctl", "mode", "-r", "do-not-disturb"]
            : ["makoctl", "mode", "-a", "do-not-disturb"]
        toggleProc.running = true
    }

    Process {
        id: readProc
        command: ["makoctl", "mode"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                root.available = true
                root.dnd = this.text.includes("do-not-disturb")
            }
        }
        // makoctl not found or mako not running
        onExited: (code) => { if (code !== 0) root.available = false }
    }

    Process {
        id: toggleProc
        running: false
        onExited: readProc.running = true
    }
}
