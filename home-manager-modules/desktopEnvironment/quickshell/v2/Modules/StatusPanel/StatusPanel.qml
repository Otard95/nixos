import qs
import QtQuick
import Quickshell
import Quickshell.Wayland

Scope {
    id: root

    required property var screen
    property bool open: false
    property string panelId: ""

    function createPanelId(): string {
        const random = Math.floor(Math.random() * 0x100000000)
            .toString(16).padStart(8, "0")
        return "status-panel-" + Date.now().toString(36) + "-" + random
    }

    function syncOpenState(): void {
        StatusPanelState.setPanelOpen(panelId, open)
        Notifications.setPopupInhibitor("status-panel", StatusPanelState.anyOpen)
    }

    onOpenChanged: {
        syncOpenState()
        if (!open)
            Notifications.markAllRead()
    }
    Component.onCompleted: {
        panelId = createPanelId()
        syncOpenState()
    }
    Component.onDestruction: {
        StatusPanelState.setPanelOpen(panelId, false)
        Notifications.setPopupInhibitor("status-panel", StatusPanelState.anyOpen)
    }

    PanelWindow {
        id: panel
        screen: root.screen
        // Stay visible until the close animation finishes
        visible: root.open || panelContent.opacity > 0
        implicitWidth: Theme.statusPanelWidth + Theme.statusPanelMargin
        exclusiveZone: 0
        color: "transparent"
        WlrLayershell.namespace: "quickshell:statusPanel"
        WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

        anchors {
            top: true
            right: true
            bottom: true
        }

        StatusPanelContent {
            id: panelContent
            onCloseRequested: root.open = false

            property real yOffset: root.open ? 0 : -20

            opacity: root.open ? 1.0 : 0.0
            transform: Translate { y: panelContent.yOffset }

            Behavior on opacity {
                NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
            }
            Behavior on yOffset {
                NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
            }

            anchors {
                fill: parent
                topMargin: Theme.statusPanelMargin
                rightMargin: Theme.statusPanelMargin
                bottomMargin: Theme.statusPanelMargin
            }
        }

    }
}
