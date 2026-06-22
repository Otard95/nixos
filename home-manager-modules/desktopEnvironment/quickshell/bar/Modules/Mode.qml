import qs
import QtQuick

// Shows the active WM mode/submap. Hidden when in default mode.
Pill {
    visible: WM.activeMode !== ""

    Item {
        implicitWidth:  label.implicitWidth + Theme.innerPadH * 2
        implicitHeight: Theme.barHeight - 10

        Text {
            id: label
            anchors.centerIn: parent
            font.family: Theme.font
            font.pixelSize: Theme.fontSm
            color: Theme.green
            text: WM.activeMode
        }
    }
}
