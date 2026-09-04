import qs

QuickToggle {
    visible: NetworkSource.wiredDevice !== null
    span: 2
    label: "Ethernet"
    status: NetworkSource.wiredConnected ? "Connected" : "Disconnected"
    icon: "lan"
    shapeOn: NetworkSource.wiredEnabled
    active: NetworkSource.wiredConnected
    onTriggered: NetworkSource.toggleWired()
}
