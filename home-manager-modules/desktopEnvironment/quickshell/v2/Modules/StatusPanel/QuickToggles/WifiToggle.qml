import qs

QuickToggle {
    span: 2
    label: "Wi-Fi"
    status: NetworkSource.wifiConnected ? NetworkSource.ssid : (NetworkSource.wifiEnabled ? "On" : "Off")
    icon: NetworkSource.wifiIcon
    shapeOn: NetworkSource.wifiEnabled
    onTriggered: NetworkSource.toggleWifi()
}
