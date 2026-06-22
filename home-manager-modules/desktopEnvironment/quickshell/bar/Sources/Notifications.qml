pragma Singleton
import QtQuick
import Quickshell
import "./Notifications" as Strategies

// Proxy/adapter singleton for notification daemon control.
// Swap `impl` to change notification daemon backend.
//
// ─── Strategy interface ───────────────────────────────────────────────────────
//
// Every strategy must expose:
//
//   available: bool     // true if the daemon is running/reachable
//   dnd:       bool     // current Do Not Disturb state
//   toggle():  void     // toggle DND on/off
//
// ─────────────────────────────────────────────────────────────────────────────
Singleton {
    id: root

    property var impl: mako.available ? mako : dunst

    readonly property bool available: impl.available
    readonly property bool dnd:       impl.dnd
    function toggle() { impl.toggle() }

    Strategies.MakoStrategy  { id: mako }
    Strategies.DunstStrategy { id: dunst }
}
