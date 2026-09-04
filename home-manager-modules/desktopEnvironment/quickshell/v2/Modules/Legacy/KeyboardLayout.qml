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

            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                font.family: Theme.font
                font.pixelSize: Theme.fontS
                color: Theme.text
                text: "󰌌 " + Keyboard.shortName
            }

            StyledText {
                visible: Keyboard.capsLock
                anchors.verticalCenter: parent.verticalCenter
                font.family: Theme.font
                font.pixelSize: Theme.fontS
                color: Theme.yellow
                text: "󰌎"
            }
        }
    }
}
