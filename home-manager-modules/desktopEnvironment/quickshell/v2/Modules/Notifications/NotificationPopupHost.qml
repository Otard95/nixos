import qs
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import "../StatusPanel/Notifications"

Scope {
    PanelWindow {
        id: window

        visible: Notifications.popupGroups.length > 0
        screen: Quickshell.screens.find(candidate => candidate.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0] ?? null
        implicitWidth: 412
        exclusiveZone: 0
        color: "transparent"

        WlrLayershell.namespace: "quickshell:notificationPopup"
        WlrLayershell.layer: WlrLayer.Overlay

        anchors {
            top: true
            right: true
            bottom: true
        }

        mask: Region {
            item: popupList
        }

        NotificationListView {
            id: popupList

            anchors {
                top: parent.top
                right: parent.right
                topMargin: 8
                rightMargin: 0
            }
            width: parent.width - 12
            height: Math.min(contentHeight, window.height - anchors.topMargin - 6)
            groups: Notifications.popupGroups
            popup: true
        }
    }
}
