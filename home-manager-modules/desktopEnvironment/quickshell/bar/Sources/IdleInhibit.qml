pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Singleton {
    id: root

    property bool active: false
    property var window: null

    IdleInhibitor {
        window: root.window
        enabled: root.active && root.window !== null
    }

    Process {
        command: ["systemd-inhibit", "--what=idle", "--who=Quickshell", "--why=Idle inhibitor enabled", "--mode=block", "sleep", "infinity",]
        running: root.active
    }

    function toggle() {
        active = !active;
    }
}
