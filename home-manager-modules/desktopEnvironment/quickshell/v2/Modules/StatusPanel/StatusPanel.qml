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
        visible: root.open
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
            onCloseRequested: root.open = false

            anchors {
                fill: parent
                topMargin: Theme.statusPanelMargin
                rightMargin: Theme.statusPanelMargin
                bottomMargin: Theme.statusPanelMargin
            }
        }

    }
}
