import qs
import QtQuick
import "../../Components"

Item {
    id: root

    required property string icon
    required property real value

    readonly property color colPrimary: value >= 0.9 ? Theme.red : Theme.accent

    implicitWidth: 52
    implicitHeight: 24

    CircularProgressIcon {
        x: 0
        width: 24
        height: 24
        anchors.verticalCenter: parent.verticalCenter
        icon: root.icon
        value: root.value
        color: root.colPrimary
    }

    StyledText {
        x: 27
        anchors.verticalCenter: parent.verticalCenter
        color: Theme.accentText
        font.pixelSize: Theme.fontS
        text: Math.round(Math.max(0, Math.min(1, root.value)) * 100)
    }
}
