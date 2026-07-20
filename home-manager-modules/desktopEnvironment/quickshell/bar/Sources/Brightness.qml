pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property int brightness: -1
    property int maxBrightness: -1
    readonly property int percent: maxBrightness > 0
        ? Math.round(brightness / maxBrightness * 100) : -1
    readonly property bool available: percent >= 0

    Process {
        id: getProc
        command: ["brightnessctl", "-m"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = this.text.trim().split(",")
                if (parts.length >= 5) {
                    root.brightness = parseInt(parts[2]) || 0
                    root.maxBrightness = parseInt(parts[4]) || 0
                }
            }
        }
    }

    Timer {
        interval: 5000
        running: root.available
        repeat: true
        onTriggered: getProc.running = true
    }

    function set(expr) {
        setProc.command = ["brightnessctl", "s", expr]
        setProc.running = true
    }

    Process {
        id: setProc
        running: false
        onRunningChanged: if (!running) getProc.running = true
    }
}
