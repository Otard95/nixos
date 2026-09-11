import qs
import QtQuick
import "../../../../Components"

// One selectable audio device (sink or source). Click to make it the default.
Item {
    id: root

    required property var node
    property bool selected: false
    signal clicked

    readonly property bool valid: !!node

    width: parent?.width ?? 0
    height: valid ? 44 : 0
    visible: valid

    Rectangle {
        anchors.fill: parent
        radius: 10
        color: root.selected ? Theme.alpha(Theme.accent, 0.18) : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }
    }

    MaterialSymbol {
        id: mark
        anchors {
            left: parent.left
            leftMargin: 12
            verticalCenter: parent.verticalCenter
        }
        iconSize: 20
        color: root.selected ? Theme.accent : Theme.subtext0
        text: root.selected ? "radio_button_checked" : "radio_button_unchecked"
    }

    StyledText {
        anchors {
            left: mark.right
            leftMargin: 10
            right: parent.right
            rightMargin: 12
            verticalCenter: parent.verticalCenter
        }
        color: root.selected ? Theme.text : Theme.subtext1
        font.weight: root.selected ? Theme.weightBold : Theme.weightNormal
        elide: Text.ElideRight
        text: root.node?.description || root.node?.nickname || root.node?.name || ""
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
