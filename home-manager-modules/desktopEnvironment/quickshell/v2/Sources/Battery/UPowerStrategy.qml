import QtQuick
import Quickshell
import Quickshell.Services.UPower

Scope {
    id: root

    readonly property var bat: UPower.displayDevice
    readonly property bool available: bat !== null && bat.isLaptopBattery && bat.isPresent
    readonly property real percentage: available ? bat.percentage : 0
    readonly property bool charging: available
        && (bat.state === UPowerDeviceState.Charging)
    readonly property string state: {
        if (!available) return "Unknown"
        switch (bat.state) {
            case UPowerDeviceState.Charging:    return "Charging"
            case UPowerDeviceState.Discharging: return "Discharging"
            case UPowerDeviceState.FullyCharged: return "Full"
            case UPowerDeviceState.Empty:       return "Empty"
            default:                            return "Unknown"
        }
    }
}
