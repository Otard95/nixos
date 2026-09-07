import qs
import QtQuick
import QtQuick.Layouts
import "../../Components"

Item {
    id: root

    signal toggleRequested

    default property alias indicators: layout.data

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    RowLayout {
        id: layout
        anchors.fill: parent
        spacing: 14
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        onClicked: root.toggleRequested()
        onWheel: event => VolumeSource.stepSinkVolume(event.angleDelta.y > 0 ? 0.02 : -0.02)
    }
}
