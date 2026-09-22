import qs
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

// Backend-agnostic focus grab.
//
// While `active`, holds input focus on `windows` and emits `cleared` when the
// user interacts outside them — used to dismiss panels on an outside click.
//
// Backend behaviour (picked at runtime from WM.hasFocusGrab):
//   - Native (e.g. Hyprland): uses the compositor grab protocol. The outside
//     click breaks the grab AND still reaches the app underneath.
//   - Fallback (generic wlroots): a transparent full-screen catcher per screen.
//     It dismisses on outside click but SWALLOWS that click — it does not pass
//     through to the app below. Consumers must render their grabbed window on
//     the WlrLayer.Overlay layer so it stays above the catcher (WlrLayer.Top).
Item {
    id: root

    property var windows: []
    property bool active: false
    signal cleared()

    // Native path — created only on a backend that supports a real grab.
    Instantiator {
        model: (root.active && WM.hasFocusGrab) ? 1 : 0
        HyprlandFocusGrab {
            windows: root.windows
            active: true
            onCleared: root.cleared()
        }
    }

    // Fallback path — one transparent click-catcher per screen.
    Variants {
        model: (root.active && !WM.hasFocusGrab) ? Quickshell.screens : []

        PanelWindow {
            required property var modelData

            screen: modelData
            color: "transparent"
            exclusiveZone: 0
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.namespace: "quickshell:focusGrabCatcher"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            anchors { top: true; bottom: true; left: true; right: true }

            MouseArea {
                anchors.fill: parent
                onPressed: root.cleared()
            }
        }
    }
}
