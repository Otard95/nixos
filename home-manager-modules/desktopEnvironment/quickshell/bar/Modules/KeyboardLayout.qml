import qs
import QtQuick

Pill {
    visible: Keyboard.available

    Item {
        implicitWidth:  row.implicitWidth + Theme.innerPadH * 2
        implicitHeight: Theme.barHeight - 10

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 6

            Text {
                anchors.verticalCenter: parent.verticalCenter
                font.family: Theme.font
                font.pixelSize: Theme.fontSm
                color: Theme.text
                text: "󰌌 " + Keyboard.shortName
            }

            Text {
                visible: Keyboard.capsLock
                anchors.verticalCenter: parent.verticalCenter
                font.family: Theme.font
                font.pixelSize: Theme.fontSm
                color: Theme.yellow
                text: "󰌎"
            }
        }
    }
}
