pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Networking

Singleton {
    id: root

    // Holds a reference so derived properties re-evaluate when the device list changes.
    readonly property var _devs: Networking.devices.values

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

    function findActiveDevice() {
        let wifi = null
        for (const dev of Networking.devices.values) {
            if (dev.type === DeviceType.Wired && dev.connected) return dev
            if (dev.type === DeviceType.Wifi  && dev.connected && !wifi) wifi = dev
        }
        return wifi
    }

    function findConnectedWifi(dev) {
        if (!dev) return null
        for (const net of dev.networks.values)
            if (net.state === ConnectionState.Connected) return net
        return null
    }

    readonly property var wifiDevice:  findWifiDevice()
    readonly property var wiredDevice: findWiredDevice()
    readonly property var device:      findActiveDevice()
    readonly property var wifi:        findConnectedWifi(wifiDevice)

    // ── Wifi toggle ────────────────────────────────────────────────────
    readonly property bool   wifiEnabled:    Networking.wifiEnabled
    readonly property bool   wifiConnected:  wifi !== null
    readonly property string ssid:           wifi?.name ?? ""
    readonly property real   signalStrength: wifi?.signalStrength ?? 0.0

    function toggleWifi() { Networking.wifiEnabled = !Networking.wifiEnabled }

    // ── Wifi dialog ────────────────────────────────────────────────────
    readonly property var  wifiNetworks: wifiDevice?.networks.values ?? []
    readonly property bool scanning:     wifiDevice?.scannerEnabled ?? false

    // Deduped, sorted view for the dialog list. One entry per SSID (strongest
    // BSSID wins), connected network first, then by descending signal. Hidden
    // (empty-name) APs are dropped — they are not connectable from a list row.
    readonly property var friendlyWifiNetworks: {
        const byName = new Map()
        for (const net of wifiNetworks) {
            if (!net.name) continue
            const seen = byName.get(net.name)
            if (!seen || net.signalStrength > seen.signalStrength)
                byName.set(net.name, net)
        }
        return Array.from(byName.values()).sort((a, b) => {
            if (a.connected !== b.connected) return a.connected ? -1 : 1
            return b.signalStrength - a.signalStrength
        })
    }

    function setScanning(on) {
        if (wifiDevice) wifiDevice.scannerEnabled = on
    }

    function connectNetwork(net)             { net.connect() }
    function connectNetworkWithPsk(net, psk) { net.connectWithPsk(psk) }
    function disconnectNetwork(net)          { net.disconnect() }
    function forgetNetwork(net)              { net.forget() }

    // Per-network presentation helpers for dialog rows.
    function isSecure(net) {
        return !!net && net.security !== WifiSecurityType.Open
    }

    // PSKs only apply to these security types (see WifiNetwork.connectWithPsk).
    function needsPsk(net) {
        if (!net) return false
        const s = net.security
        return s === WifiSecurityType.WpaPsk
            || s === WifiSecurityType.Wpa2Psk
            || s === WifiSecurityType.Sae
    }

    function strengthIcon(strength) {
        if (strength < 0.25) return "signal_wifi_0_bar"
        if (strength < 0.50) return "network_wifi_1_bar"
        if (strength < 0.75) return "network_wifi_2_bar"
        if (strength < 0.90) return "network_wifi_3_bar"
        return "signal_wifi_4_bar"
    }

    // ── Ethernet toggle ────────────────────────────────────────────────
    readonly property bool wiredConnected: wiredDevice?.connected ?? false
    readonly property bool wiredEnabled: {
        const s = wiredDevice?.network?.state
        return s === ConnectionState.Connecting || s === ConnectionState.Connected
    }

    function toggleWired() {
        if (!wiredDevice?.network) return
        wiredEnabled
            ? wiredDevice.network.disconnect()
            : wiredDevice.network.connect()
    }

    // ── Display ────────────────────────────────────────────────────────
    readonly property bool   available: !!device
    readonly property bool   isWifi:    device?.type === DeviceType.Wifi

    readonly property string icon: {
        if (!available) return "wifi_off"
        if (!isWifi)    return "lan"
        return wifiIcon
    }

    readonly property string wifiIcon: {
        if (!wifiEnabled)   return "wifi_off"
        if (!wifiConnected) return "wifi"
        return strengthIcon(signalStrength)
    }
}
