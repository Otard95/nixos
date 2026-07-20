pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Wayland

Singleton {
    id: root

    property bool active: false
    property var window: null

    IdleInhibitor {
        window:  root.window
        enabled: root.active && root.window !== null
    }

    function toggle() { active = !active }
}
