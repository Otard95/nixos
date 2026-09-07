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
//   available:   bool   // true if a battery was detected
//   percentage:  real   // 0–100
//   charging:    bool   // true if charging (any form)
//   state:       int    // one of BatterySource.State
//   timeToEmpty: real   // seconds until empty while discharging, else 0
//   timeToFull:  real   // seconds until full while charging, else 0
//
// ─────────────────────────────────────────────────────────────────────────────
Singleton {
    id: root

    enum State {
        Unknown,
        Charging,
        Discharging,
        Full,
        Empty
    }

    property var impl: upower.available ? upower : sysfs

    readonly property bool available:  impl.available
    readonly property real percentage: impl.percentage
    readonly property bool charging:   impl.charging
    readonly property int state:       impl.state

    // Estimated seconds until the relevant target, or 0 when unknown.
    readonly property real timeToEmpty: impl.timeToEmpty
    readonly property real timeToFull:  impl.timeToFull

    // The estimate that matters for the current state. 0 when unknown.
    readonly property real timeRemaining: charging ? timeToFull : timeToEmpty

    Strategies.UPowerStrategy { id: upower }
    Strategies.SysfsStrategy  { id: sysfs }
}
