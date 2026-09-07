import QtQuick
import Quickshell
import Quickshell.Io
import qs

// Reads battery data directly from /sys/class/power_supply/BAT0/.
// No system service required.
//
// Time estimates come from energy/power. sysfs reports energy in µWh and
// power in µW, so energy / power is a fraction of an hour. The µ prefixes
// cancel, leaving hours; multiply by 3600 for seconds.
Scope {
    id: root

    property bool available: false
    property real percentage: 0
    property bool charging: false
    property int state: BatterySource.Unknown

    property real timeToEmpty: 0
    property real timeToFull: 0

    readonly property string batPath: "/sys/class/power_supply/BAT0"

    // Latest raw µ-unit readings from uevent.
    property real energyNow: 0
    property real energyFull: 0
    property real powerNow: 0

    function recompute() {
        if (powerNow <= 0) {
            timeToEmpty = 0
            timeToFull = 0
            return
        }
        if (state === BatterySource.Discharging) {
            timeToEmpty = energyNow / powerNow * 3600
            timeToFull = 0
        } else if (state === BatterySource.Charging) {
            timeToFull = Math.max(0, energyFull - energyNow) / powerNow * 3600
            timeToEmpty = 0
        } else {
            timeToEmpty = 0
            timeToFull = 0
        }
    }

    Process {
        id: ueventProc
        command: ["cat", root.batPath + "/uevent"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const fields = {}
                for (const line of this.text.split("\n")) {
                    const eq = line.indexOf("=")
                    if (eq === -1) continue
                    fields[line.slice(0, eq)] = line.slice(eq + 1).trim()
                }

                const cap = parseInt(fields["POWER_SUPPLY_CAPACITY"])
                if (!isNaN(cap)) {
                    root.percentage = cap
                    root.available = true
                }

                switch (fields["POWER_SUPPLY_STATUS"]) {
                    case "Charging":
                        root.state = BatterySource.Charging; root.charging = true; break
                    case "Discharging":
                        root.state = BatterySource.Discharging; root.charging = false; break
                    case "Full":
                        root.state = BatterySource.Full; root.charging = false; break
                    case "Not charging":
                        root.state = BatterySource.Full; root.charging = false; break
                    default:
                        root.state = BatterySource.Unknown; root.charging = false; break
                }

                root.energyNow = parseFloat(fields["POWER_SUPPLY_ENERGY_NOW"]) || 0
                root.energyFull = parseFloat(fields["POWER_SUPPLY_ENERGY_FULL"]) || 0
                root.powerNow = parseFloat(fields["POWER_SUPPLY_POWER_NOW"]) || 0
                root.recompute()
            }
        }
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: ueventProc.running = true
    }
}
