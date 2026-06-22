import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root

    property bool available: false
    property bool dnd: false

    function toggle() {
        toggleProc.command = ["dunstctl", "set-paused", dnd ? "false" : "true"]
        toggleProc.running = true
    }

    Process {
        id: readProc
        command: ["dunstctl", "is-paused"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                root.available = true
                root.dnd = this.text.trim() === "true"
            }
        }
        onExited: (code) => { if (code !== 0) root.available = false }
    }

    Process {
        id: toggleProc
        running: false
        onExited: readProc.running = true
    }
}
