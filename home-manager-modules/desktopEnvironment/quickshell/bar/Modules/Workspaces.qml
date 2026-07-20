import qs
import QtQuick

OuterPill {
    required property var screen

    Item {
        implicitWidth: row.implicitWidth + Theme.innerPadH * 2
        implicitHeight: Theme.barHeight

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 10

            Repeater {
                model: WM.workspacesByMonitor[screen.name] ?? []

                delegate: Item {
                    required property var modelData

                    implicitWidth: circle.width + 8
                    implicitHeight: Theme.barHeight

                    Rectangle {
                        id: circle
                        anchors.centerIn: parent
                        width: 15
                        height: 15
                        radius: width / 2

                        color: modelData.focused ? Theme.peach : modelData.active ? Theme.text : Theme.overlay1

                        Text {
                            anchors.fill: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: modelData.id < 0 ? "·" : modelData.id
                            color: Theme.crust
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSm
                            font.bold: true
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: modelData.activate()
                    }
                }
            }
        }
    }
}
