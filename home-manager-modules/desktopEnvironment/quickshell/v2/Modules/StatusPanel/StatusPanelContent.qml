import qs
import QtQuick
import QtQuick.Layouts
import "Notifications"
import "QuickToggles"
import "QuickToggles/Wifi"
import "Widgets"

Rectangle {
    id: root

    signal closeRequested

    property bool panelOpen: false

    onCloseRequested: powerOptions.pendingPowerAction = null

    // When the panel closes (Escape, outside click, focus loss), close any
    // open overlay dialogs so they are not left open on the next open.
    onPanelOpenChanged: {
        if (!panelOpen) {
            wifiDialog.closePasswordPrompt()
            wifiDialog.open = false
        }
    }

    focus: true

    // Escape prioritises the top layer: password prompt, then the wifi dialog,
    // then the whole panel.
    Shortcut {
        sequence: "Escape"
        context: Qt.WindowShortcut
        onActivated: {
            if (wifiDialog.askingPasswordFor !== null)
                wifiDialog.closePasswordPrompt()
            else if (wifiDialog.open)
                wifiDialog.close()
            else
                root.closeRequested()
        }
    }

    color: Theme.crust
    border.width: 1
    border.color: Theme.surface0
    radius: Theme.statusPanelRadius
    clip: true

    ColumnLayout {
        anchors {
            fill: parent
            margins: Theme.statusPanelPadding
        }
        spacing: Theme.statusPanelPadding

        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 5
            Layout.bottomMargin: 8
            spacing: 8

            Uptime {}

            Item {
                Layout.fillWidth: true
            }

            PowerOptions {
                id: powerOptions
                onCloseRequested: root.closeRequested()
            }
        }

        QuickSliders {
            Layout.fillWidth: true
        }

        QuickToggleGrid {
            Layout.fillWidth: true

            WifiToggle {
                onOverlayRequested: wifiDialog.open = !wifiDialog.open
            }
            EthernetToggle {
                span: 1
            }
            MicrophoneToggle {}
            BluetoothToggle {}
            AudioToggle {}
            IdleInhibitToggle {}
            PowerProfileToggle {}
        }

        NotificationList {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 120
        }

        WidgetGroup {
            Layout.fillWidth: true
            Layout.preferredHeight: implicitHeight
        }
    }

    WifiDialog {
        id: wifiDialog
    }

    WifiPasswordDialog {
        network: wifiDialog.askingPasswordFor
        open: wifiDialog.askingPasswordFor !== null
        onDismissed: {
            wifiDialog.closePasswordPrompt()
            close()
        }
    }
}
