import qs

QuickToggle {
    span: 2
    label: "Bluetooth"
    status: BluetoothSource.connected ? BluetoothSource.connectedDeviceCount + " connected" : (BluetoothSource.enabled ? "On" : "Off")
    icon: BluetoothSource.icon
    shapeOn: BluetoothSource.enabled
    interactive: BluetoothSource.available
    onTriggered: BluetoothSource.toggle()
}
