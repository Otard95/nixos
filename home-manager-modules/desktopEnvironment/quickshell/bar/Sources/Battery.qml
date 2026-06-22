pragma Singleton
import QtQuick
import Quickshell
import "./Battery" as Strategies

// Proxy/adapter singleton for battery data.
// Tries UPower first, falls back to sysfs if unavailable.
//
// ─── Strategy interface ───────────────────────────────────────────────────────
//
// Every strategy must expose:
//
//   available:  bool       // true if a battery was detected
//   percentage: real       // 0–100
//   charging:   bool       // true if charging (any form)
//   state:      string     // "Charging", "Discharging", "Full", "Empty", "Unknown"
//
// ─────────────────────────────────────────────────────────────────────────────
Singleton {
    id: root

    property var impl: upower.available ? upower : sysfs

    readonly property bool available:  impl.available
    readonly property real percentage: impl.percentage
    readonly property bool charging:   impl.charging
    readonly property string state:    impl.state

    Strategies.UPowerStrategy { id: upower }
    Strategies.SysfsStrategy  { id: sysfs }
}
