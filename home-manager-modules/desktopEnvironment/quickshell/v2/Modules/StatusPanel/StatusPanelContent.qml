import qs
import QtQuick
import QtQuick.Layouts
import "../../Components"
import "Notifications"
import "QuickToggles"
import "Widgets"

Rectangle {
    id: root

    signal closeRequested

    onCloseRequested: powerOptions.pendingPowerAction = null

    focus: true

    Shortcut {
        sequence: "Escape"
        context: Qt.WindowShortcut
        onActivated: root.closeRequested()
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

            WifiToggle {}
            EthernetToggle {}
            BluetoothToggle {}
            AudioToggle {}
            IdleInhibitToggle {}
            MicrophoneToggle {}
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
}
