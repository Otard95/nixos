import qs
import QtQuick

Rectangle {
    id: root

    property int columns: 4
    property real cellSpacing: 6
    default property alias toggles: flow.data

    implicitHeight: flow.implicitHeight + 12
    color: Theme.mantle
    radius: Theme.innerRadius

    Flow {
        id: flow

        property real cellWidth: (width - (root.columns - 1) * spacing) / root.columns

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: 6
        }
        height: implicitHeight
        spacing: root.cellSpacing
    }
}
