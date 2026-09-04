import qs
import QtQuick
import QtQuick.Layouts
import "../../../Components"

Item {
    id: root

    required property string label
    required property string icon
    property bool selected: false

    signal clicked

    implicitWidth: 78
    implicitHeight: 66

    ColumnLayout {
        anchors.fill: parent
        spacing: 3

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: 42
            implicitHeight: 34
            radius: height / 2
            color: root.selected ? Theme.alpha(Theme.accent, 0.22) : mouse.containsMouse ? Theme.surface0 : "transparent"

            MaterialSymbol {
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                iconSize: 20
                color: root.selected ? Theme.accent : Theme.subtext0
                text: root.icon
            }
        }

        StyledText {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            color: root.selected ? Theme.text : Theme.subtext0
            font.pixelSize: Theme.fontS
            text: root.label
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
