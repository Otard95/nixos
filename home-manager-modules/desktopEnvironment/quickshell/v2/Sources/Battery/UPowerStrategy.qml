import QtQuick
import Quickshell
import Quickshell.Services.UPower
import qs

Scope {
    id: root

    readonly property var bat: UPower.displayDevice
    readonly property bool available: bat !== null && bat.isLaptopBattery && bat.isPresent
    readonly property real percentage: available ? bat.percentage : 0
    readonly property bool charging: available
        && (bat.state === UPowerDeviceState.Charging)

    // UPower reports these in seconds and zeroes the irrelevant one.
    readonly property real timeToEmpty: available ? bat.timeToEmpty : 0
    readonly property real timeToFull:  available ? bat.timeToFull  : 0

    readonly property int state: {
        if (!available) return BatterySource.Unknown
        switch (bat.state) {
            case UPowerDeviceState.Charging:     return BatterySource.Charging
            case UPowerDeviceState.Discharging:  return BatterySource.Discharging
            case UPowerDeviceState.FullyCharged: return BatterySource.Full
            case UPowerDeviceState.Empty:        return BatterySource.Empty
            default:                             return BatterySource.Unknown
        }
    }
}
