pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Bluetooth

Singleton {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool available: adapter !== null
    readonly property bool enabled: adapter?.enabled ?? false
    readonly property bool connected: Bluetooth.devices.values.some(device => device.connected)
    readonly property int connectedDeviceCount: Bluetooth.devices.values.filter(device => device.connected).length

    readonly property string icon: {
        if (!enabled) return "bluetooth_disabled"
        return connected ? "bluetooth_connected" : "bluetooth"
    }

    function setEnabled(value) {
        if (adapter) adapter.enabled = value
    }

    function toggle() {
        setEnabled(!enabled)
    }
}
