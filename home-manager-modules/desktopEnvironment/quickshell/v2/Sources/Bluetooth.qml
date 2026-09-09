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

    // ── Bluetooth dialog ───────────────────────────────────────────────
    // Scoped to the default adapter to avoid cross-adapter noise.
    readonly property var devices: adapter?.devices.values ?? []

    // Sorted view for the dialog list: connected first, then paired, then the
    // rest (discovered), each group by name. Nameless devices fall back to the
    // MAC address so they still render a stable, clickable row.
    readonly property var friendlyDevices: {
        function rank(d) {
            if (d.connected) return 0
            if (d.paired || d.bonded) return 1
            return 2
        }
        function label(d) {
            return d.name || d.deviceName || d.address || ""
        }
        return devices.slice().sort((a, b) => {
            const ra = rank(a), rb = rank(b)
            if (ra !== rb) return ra - rb
            return label(a).localeCompare(label(b))
        })
    }

    // ── Discovery ──────────────────────────────────────────────────────
    // `adapter.discovering` is writable: set it to scan. Keep it on only while
    // the dialog is open (battery + radio cost), disable on close.
    readonly property bool discovering: adapter?.discovering ?? false

    function setDiscovering(on) {
        // Guard against redundant writes — BlueZ warns when stopping discovery
        // that never started (double close paths).
        if (adapter && adapter.discovering !== on) adapter.discovering = on
    }

    // ── Per-device actions ─────────────────────────────────────────────
    function connectDevice(dev)    { dev?.connect() }
    function disconnectDevice(dev) { dev?.disconnect() }
    function pairDevice(dev)       { dev?.pair() }
    function cancelPair(dev)       { dev?.cancelPair() }
    function forgetDevice(dev)     { dev?.forget() }        // forget == unpair
    function setTrusted(dev, on)   { if (dev) dev.trusted = on }

    // ── Per-device presentation helpers ────────────────────────────────
    function deviceLabel(dev) {
        if (!dev) return ""
        return dev.name || dev.deviceName || dev.address || ""
    }

    // System icon name from BlueZ (e.g. "audio-headset"), resolvable through
    // Quickshell.iconPath(). Rows may prefer a Material symbol instead.
    function deviceIcon(dev) {
        return dev?.icon ?? ""
    }

    // Map the BlueZ system icon name to a Material symbol for the row.
    function deviceSymbol(dev) {
        const name = dev?.icon ?? ""
        if (name.includes("headset") || name.includes("headphone")) return "headphones"
        if (name.includes("audio")) return "speaker"
        if (name.includes("phone")) return "smartphone"
        if (name.includes("mouse")) return "mouse"
        if (name.includes("keyboard")) return "keyboard"
        if (name.includes("computer") || name.includes("laptop")) return "computer"
        if (name.includes("watch")) return "watch"
        if (name.includes("printer")) return "print"
        if (name.includes("camera")) return "photo_camera"
        if (name.includes("input-gaming") || name.includes("joypad")) return "stadia_controller"
        return "bluetooth"
    }

    // Material battery symbol for a 0–1 level. Mirrors the barred set used
    // elsewhere; `battery_alert` flags a near-empty device.
    function batteryIcon(level) {
        if (level >= 0.95) return "battery_android_frame_full"
        if (level >= 0.85) return "battery_android_6"
        if (level >= 0.70) return "battery_android_5"
        if (level >= 0.55) return "battery_android_4"
        if (level >= 0.40) return "battery_android_3"
        if (level >= 0.25) return "battery_android_2"
        if (level >= 0.10) return "battery_android_1"
        return "battery_alert"
    }

    // True while the device is mid-transition, for dimming/spinner cues.
    function deviceBusy(dev) {
        if (!dev) return false
        return dev.pairing
            || dev.state === BluetoothDeviceState.Connecting
            || dev.state === BluetoothDeviceState.Disconnecting
    }

    function stateLabel(dev) {
        if (!dev) return ""
        if (dev.pairing) return "Pairing…"
        switch (dev.state) {
        case BluetoothDeviceState.Connecting:    return "Connecting…"
        case BluetoothDeviceState.Connected:     return "Connected"
        case BluetoothDeviceState.Disconnecting: return "Disconnecting…"
        default:
            return (dev.paired || dev.bonded) ? "Paired" : ""
        }
    }
}
