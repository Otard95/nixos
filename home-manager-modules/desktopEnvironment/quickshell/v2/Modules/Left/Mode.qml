import qs
import QtQuick

Item {
    id: root
    visible: WM.activeMode !== ""
    implicitWidth: label.implicitWidth + Theme.innerPadH * 2
    implicitHeight: Theme.barHeight

        StyledText {
            id: label
            anchors.centerIn: parent
            font.family: Theme.font
            font.pixelSize: Theme.fontS
            color: Theme.green
            text: WM.activeMode
        }
}
