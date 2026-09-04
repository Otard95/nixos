import QtQuick
import Quickshell
import Quickshell.Io

// Fallback: polls setxkbmap to get the current layout.
// Works on any X11/XWayland setup but won't react to changes instantly.
Scope {
    id: root

    property bool available: false
    property string layout: ""
    property string shortName: ""

    Process {
        id: proc
        command: ["setxkbmap", "-query"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const match = this.text.match(/layout:\s+(\S+)/)
                if (match) {
                    root.layout = match[1]
                    root.shortName = match[1].toUpperCase().slice(0, 2)
                    root.available = true
                }
            }
        }
    }

    Timer {
        interval: 5000
        running: root.available
        repeat: true
        onTriggered: proc.running = true
    }
}
