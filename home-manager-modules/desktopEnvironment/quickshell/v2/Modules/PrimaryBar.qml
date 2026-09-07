import qs
import QtQuick
import QtQuick.Layouts
import "../Components"
import "Left"
import "Center"
import "Right"

Item {
    id: root

    required property var screen
    required property var panelWindow

    signal toggleStatusPanel

    implicitHeight: Theme.barHeight + Theme.outerRadius

    Rectangle {
        id: barBackground
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: Theme.barHeight
        color: Theme.alpha(Theme.crust, Theme.bgAlpha)
    }

    RoundCorner {
        anchors {
            top: barBackground.bottom
            left: parent.left
        }
        implicitSize: Theme.outerRadius
        color: barBackground.color
        corner: 0
    }

    RoundCorner {
        anchors {
            top: barBackground.bottom
            right: parent.right
        }
        implicitSize: Theme.outerRadius
        color: barBackground.color
        corner: 1
    }

    RowLayout {
        id: leftSection
        anchors {
            left: parent.left
            leftMargin: Theme.innerPadH
            verticalCenter: barBackground.verticalCenter
        }
        width: Math.min(implicitWidth, parent.width * 0.3)
        spacing: Theme.innerSpacing

        Mode {
            Layout.alignment: Qt.AlignVCenter
        }

        ActiveWindow {
            screen: root.screen
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
        }
    }

    Row {
        id: centerSection
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: barBackground.verticalCenter
        spacing: Theme.innerSpacing

        BarGroup {
            padding: 10
            SystemMedia {}
        }

        BarGroup {
            Workspaces {
                screen: root.screen
                Layout.alignment: Qt.AlignVCenter
            }
        }

        BarGroup {
            Clock {
                panelWindow: root.panelWindow
            }

            Battery {
                Layout.alignment: Qt.AlignVCenter
            }
        }
    }

    BarGroup {
        anchors {
            right: parent.right
            rightMargin: Theme.innerPadH
            verticalCenter: barBackground.verticalCenter
        }
        padding: 10

        StatusPill {
            onToggleRequested: root.toggleStatusPanel()

            VolumeMutedIndicator {}
            MicIndicator {}
            KeyboardIndicator {}
            NotificationStatus { indicatorType: NotificationStatus.Number }
            NetworkIndicator {}
            BluetoothIndicator {}
        }
    }
}
