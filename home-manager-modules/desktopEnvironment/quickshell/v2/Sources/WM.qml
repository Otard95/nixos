pragma Singleton
import QtQuick
import Quickshell
import "./WM" as Strategies

// Proxy/adapter singleton — the only import bar modules need for WM data.
// To switch WM backend, change `impl` to point at a different strategy.
//
// ─── Strategy interface ───────────────────────────────────────────────────────
//
// Every strategy must expose:
//
//   workspacesByMonitor: {
//     [monitorName: string]: Array<{
//       id:       int | string
//       name:     string
//       active:   bool          // workspace is visible on its own monitor
//       focused:  bool          // workspace is visible on the globally focused monitor
//       activate: () => void
//     }>
//   }
//
//   activeWindowByMonitor: {
//     [monitorName: string]: { title: string, appId: string } | null
//   }
//
//   activeMode: string    // empty when default, non-empty for submaps/modes
//
// ─────────────────────────────────────────────────────────────────────────────
Singleton {
    id: root

    property var impl: hyprland

    readonly property var workspacesByMonitor:   impl.workspacesByMonitor
    readonly property var activeWindowByMonitor: impl.activeWindowByMonitor
    readonly property string activeMode:         impl.activeMode

    Strategies.HyprlandStrategy { id: hyprland }
    // Strategies.WlrStrategy { id: wlr }   // swap impl above to use this
}
