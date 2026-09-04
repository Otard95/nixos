import QtQuick
import Quickshell
import Quickshell.Io

// Reads battery data directly from /sys/class/power_supply/BAT0/.
// No system service required.
Scope {
    id: root

    property bool available: false
    property real percentage: 0
    property bool charging: false
    property string state: "Unknown"

    readonly property string batPath: "/sys/class/power_supply/BAT0"

    Process {
        id: capacityProc
        command: ["cat", root.batPath + "/capacity"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const val = parseInt(this.text.trim())
                if (!isNaN(val)) {
                    root.percentage = val
                    root.available = true
                }
            }
        }
    }

    Process {
        id: statusProc
        command: ["cat", root.batPath + "/status"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const s = this.text.trim()
                switch (s) {
                    case "Charging":
                        root.state = "Charging"; root.charging = true; break
                    case "Discharging":
                        root.state = "Discharging"; root.charging = false; break
                    case "Full":
                        root.state = "Full"; root.charging = false; break
                    case "Not charging":
                        root.state = "Full"; root.charging = false; break
                    default:
                        root.state = "Unknown"; root.charging = false; break
                }
            }
        }
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: {
            capacityProc.running = true
            statusProc.running = true
        }
    }
}
