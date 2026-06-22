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

    readonly property var _devs:   Networking.devices.values
    readonly property var device:  findDevice()
    readonly property var wifi:    findWifiNetwork(device)

    // ── Exposed interface ──────────────────────────────────────────────
    readonly property bool   available:     !!device
    readonly property bool   isWifi:        device?.type === DeviceType.Wifi
    readonly property string deviceName:    device?.name ?? ""
    readonly property string macAddress:    device?.address ?? ""
    readonly property string ssid:          wifi?.name ?? ""
    readonly property real   signalStrength: wifi?.signalStrength ?? 0.0

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
