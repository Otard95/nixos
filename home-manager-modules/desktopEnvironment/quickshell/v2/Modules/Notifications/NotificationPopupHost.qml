import qs
import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import "../StatusPanel/Notifications"

Scope {
    PanelWindow {
        id: window

        visible: Notifications.popupGroups.length > 0
        screen: Quickshell.screens.find(candidate => candidate.name === WM.focusedMonitorName) ?? Quickshell.screens[0] ?? null
        readonly property real fadeWidth: 48

        implicitWidth: 412 + fadeWidth
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

        Rectangle {
            id: fadeMask

            width: popupList.width
            height: popupList.height
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0; color: "transparent" }
                GradientStop { position: window.fadeWidth / fadeMask.width; color: "white" }
            }
        }

        ShaderEffectSource {
            id: fadeMaskTexture

            x: -width
            width: fadeMask.width
            height: fadeMask.height
            sourceItem: fadeMask
            hideSource: true
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
            leftInset: window.fadeWidth
            layer.enabled: true
            layer.effect: MultiEffect {
                maskEnabled: true
                maskSource: fadeMaskTexture
                maskThresholdMin: 0.5
                maskSpreadAtMin: 1
            }
        }
    }
}
