import qs
import QtQuick
import "../../../Components"

Rectangle {
    id: toggle

    required property string label
    required property string icon
    property int span: 1
    property string status: ""
    property bool shapeOn: false
    property bool active: shapeOn
    property bool interactive: true

    width: parent.cellWidth * span + parent.spacing * (span - 1)
    height: 56
    color: span === 1 && active ? Theme.accent : Theme.base
    opacity: interactive ? 1 : 0.45
    radius: shapeOn ? 18 : height / 2

    Row {
        visible: toggle.span === 2
        anchors {
            fill: parent
            leftMargin: 8
            rightMargin: 10
        }
        spacing: 7

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 40
            height: 40
            radius: toggle.shapeOn ? 12 : height / 2
            color: toggle.active ? Theme.accent : Theme.surface0

            MaterialSymbol {
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                iconSize: 22
                color: toggle.active ? Theme.base : Theme.text
                text: toggle.icon
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 57
            spacing: -2

            StyledText {
                width: parent.width
                color: Theme.text
                font.pixelSize: Theme.fontM
                font.weight: Theme.weightBold
                elide: Text.ElideRight
                text: toggle.label
            }

            StyledText {
                visible: toggle.status !== ""
                width: parent.width
                color: Theme.subtext0
                font.pixelSize: Theme.fontS
                elide: Text.ElideRight
                text: toggle.status
            }
        }
    }

    MaterialSymbol {
        visible: toggle.span === 1
        anchors.fill: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        iconSize: 22
        color: toggle.active ? Theme.base : Theme.text
        text: toggle.icon
    }

    MouseArea {
        anchors.fill: parent
        enabled: toggle.interactive
        cursorShape: Qt.PointingHandCursor
        onClicked: toggle.triggered()
    }

    signal triggered
}
