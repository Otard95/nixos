import qs
import QtQuick

Item {
    id: root

    // Pull in 6px from each side to sit tighter against neighbouring pills.
    readonly property int sideInset: 6
    implicitWidth:  row.implicitWidth - sideInset * 2
    implicitHeight: Theme.barHeight - 10

    // ── Layout ────────────────────────────────────────────────────────
    Row {
        id: row
        anchors.centerIn: parent
        x: (parent.width - row.implicitWidth) / 2
        y: (parent.height - row.implicitHeight) / 2
        spacing: 2

        // Mic in use indicator
        Text {
            visible: Mic.active
            anchors.verticalCenter: parent.verticalCenter
            font.family: Theme.font
            font.pixelSize: Theme.fontMd
            color: Theme.red
            text: "󰍬"
        }

        // DND toggle
        Text {
            anchors.verticalCenter: parent.verticalCenter
            font.family: Theme.font
            font.pixelSize: Theme.fontMd
            color: Notifications.dnd ? Theme.yellow : Theme.subtext1
            text: Notifications.dnd ? "󰂛" : "󰂚"

            MouseArea {
                anchors.fill: parent
                onClicked: Notifications.toggle()
            }
        }

        // Idle inhibitor toggle
        Text {
            anchors.verticalCenter: parent.verticalCenter
            font.family: Theme.font
            font.pixelSize: Theme.fontMd
            color: IdleInhibit.active ? Theme.yellow : Theme.subtext1
            text: IdleInhibit.active ? "󰈈" : "󰈉"

            MouseArea {
                anchors.fill: parent
                onClicked: IdleInhibit.toggle()
            }
        }
    }
}
