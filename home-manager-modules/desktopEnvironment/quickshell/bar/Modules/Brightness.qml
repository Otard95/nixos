import qs
import QtQuick

Pill {
    id: root

    visible: BrightnessSource.available

    Item {
        implicitWidth:  row.implicitWidth + Theme.innerPadH * 2
        implicitHeight: Theme.barHeight - 10

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 4

            Text {
                anchors.verticalCenter: parent.verticalCenter
                font.family: Theme.font
                font.pixelSize: Theme.fontLg
                color: Theme.text
                text: "☀"
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                font.family: Theme.font
                font.pixelSize: Theme.fontSm
                color: Theme.text
                text: BrightnessSource.available ? BrightnessSource.percent + "%" : ""
            }
        }

        MouseArea {
            anchors.fill: parent
            onWheel: (event) => {
                BrightnessSource.set(event.angleDelta.y > 0 ? "2%+" : "2%-")
            }
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
            onClicked: (event) => {
                if (event.button === Qt.LeftButton)
                    BrightnessSource.set("100%")
                else if (event.button === Qt.MiddleButton)
                    BrightnessSource.set("50%")
                else
                    BrightnessSource.set("10%")
            }
        }
    }
}
