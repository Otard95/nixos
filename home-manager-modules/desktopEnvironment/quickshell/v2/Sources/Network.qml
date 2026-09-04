pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking

// Unified network source — combines Quickshell.Networking (device/wifi state)
// with `ip -j addr` (IPv4/IPv6 addresses, not available in the Networking API).
Singleton {
    id: root

    // ── Device resolution ──────────────────────────────────────────────
    function findDevice() {
        let wifi = null
        for (const dev of Networking.devices.values) {
            if (dev.type === DeviceType.Wired && dev.connected) return dev
            if (dev.type === DeviceType.Wifi  && dev.connected && !wifi) wifi = dev
        }
        return wifi
    }

    function findWifiNetwork(dev) {
        if (!dev || dev.type !== DeviceType.Wifi) return null
        for (const net of dev.networks.values)
            if (net.state === ConnectionState.Connected) return net
        return null
    }

    function findWifiDevice() {
        for (const dev of Networking.devices.values)
            if (dev.type === DeviceType.Wifi) return dev
        return null
    }

    function findWiredDevice() {
        for (const dev of Networking.devices.values)
            if (dev.type === DeviceType.Wired) return dev
        return null
    }

    readonly property var _devs:   Networking.devices.values
    readonly property var device:  findDevice()
    readonly property var wifiDevice: findWifiDevice()
    readonly property var wifi:    findWifiNetwork(wifiDevice)
    readonly property bool wifiConnected: wifi !== null
    readonly property var wiredDevice: findWiredDevice()
    readonly property bool wiredEnabled: wiredDevice?.autoconnect ?? false
    readonly property bool wiredConnected: wiredDevice?.connected ?? false
    property bool wifiEnabled: false

    function setWifiEnabled(enabled) {
        wifiSet.command = enabled
            ? ["nmcli", "radio", "wifi", "on"]
            : ["nmcli", "radio", "wifi", "off"]
        wifiSet.running = true
    }

    function toggleWifi() {
        setWifiEnabled(!wifiEnabled)
    }

    function setWiredConnected(connected) {
        if (!wiredDevice) return
        ethernetSet.command = ["nmcli", "device", connected ? "connect" : "disconnect", wiredDevice.name]
        ethernetSet.running = true
    }

    function toggleWired() {
        setWiredConnected(!wiredEnabled)
    }

    Process {
        id: wifiQuery
        command: ["nmcli", "-g", "WIFI", "radio"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.wifiEnabled = this.text.trim() === "enabled"
        }
    }

    Process {
        id: wifiSet
        running: false
        onRunningChanged: if (!running) wifiQuery.running = true
    }

    Process {
        id: ethernetSet
        running: false
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: wifiQuery.running = true
    }

    // ── Exposed interface ──────────────────────────────────────────────
    readonly property bool   available:     !!device
    readonly property bool   isWifi:        device?.type === DeviceType.Wifi
    readonly property string deviceName:    device?.name ?? ""
    readonly property string macAddress:    device?.address ?? ""
    readonly property string ssid:          wifi?.name ?? ""
    readonly property real   signalStrength: wifi?.signalStrength ?? 0.0

    readonly property string icon: {
        if (!available) return "wifi_off"
        if (!isWifi)    return "lan"
        return wifiIcon
    }

    readonly property string wifiIcon: {
        if (!wifiEnabled) return "wifi_off"
        if (!wifiConnected) return "wifi"
        const s = signalStrength
        if (s < 0.25)  return "signal_wifi_0_bar"
        if (s < 0.50)  return "network_wifi_1_bar"
        if (s < 0.75)  return "network_wifi_2_bar"
        if (s < 0.90)  return "network_wifi_3_bar"
        return "signal_wifi_4_bar"
    }

    property string ipv4: ""
    property string ipv6: ""

    // ── IP address resolution via `ip` ─────────────────────────────────
    onDeviceNameChanged: {
        ipv4 = ""
        ipv6 = ""
        if (deviceName !== "") {
            ipProc.command = ["ip", "-j", "addr", "show", "dev", deviceName]
            ipProc.running = true
        }
    }

    Process {
        id: ipProc
        command: ["ip", "-j", "addr"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const ifaces = JSON.parse(this.text)
                    if (!ifaces?.length) return
                    for (const addr of ifaces[0].addr_info ?? []) {
                        if (addr.family === "inet" && !root.ipv4)
                            root.ipv4 = addr.local + "/" + addr.prefixlen
                        // Skip link-local (fe80::) for the display address
                        if (addr.family === "inet6"
                            && !addr.local.startsWith("fe80")
                            && !root.ipv6)
                            root.ipv6 = addr.local + "/" + addr.prefixlen
                    }
                } catch(e) {}
            }
        }
    }

    Timer {
        interval: 30000
        running: root.available
        repeat: true
        onTriggered: {
            ipProc.command = ["ip", "-j", "addr", "show", "dev", root.deviceName]
            ipProc.running = true
        }
    }
}
