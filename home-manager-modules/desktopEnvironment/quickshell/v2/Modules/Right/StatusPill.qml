import qs
import QtQuick
import QtQuick.Layouts
import "../../Components"

Item {
    id: root

    default property alias indicators: layout.data

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    RowLayout {
        id: layout
        anchors.fill: parent
        spacing: 10
    }

    WheelHandler {
        onWheel: event => VolumeSource.stepSinkVolume(event.angleDelta.y > 0 ? 0.02 : -0.02)
    }
}
