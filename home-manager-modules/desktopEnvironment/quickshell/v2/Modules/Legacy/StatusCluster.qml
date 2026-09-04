import qs
import QtQuick
import QtQuick.Layouts
import "../../Components"

Item {
    id: root

    implicitWidth: indicators.implicitWidth
    implicitHeight: Theme.barHeight - 8
    Layout.alignment: Qt.AlignVCenter

    Row {
        id: indicators
        anchors.centerIn: parent
        spacing: 10

        MaterialSymbol {
            id: speaker
            anchors.verticalCenter: parent.verticalCenter
            color: VolumeSource.sinkMuted ? Theme.overlay1 : Theme.text
            iconSize: Theme.fontM
            text: {
                if (!VolumeSource.sinkAvailable || VolumeSource.sinkMuted)
                    return "volume_off"
                return VolumeSource.sinkVolume < 0.5 ? "volume_down" : "volume_up"
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                onClicked: VolumeSource.toggleSinkMute()
                onWheel: event => VolumeSource.stepSinkVolume(event.angleDelta.y > 0 ? 0.02 : -0.02)
            }
        }

        MaterialSymbol {
            visible: VolumeSource.sourceAvailable
            anchors.verticalCenter: parent.verticalCenter
            color: VolumeSource.sourceMuted ? Theme.overlay1 : Theme.text
            iconSize: Theme.fontM
            text: VolumeSource.sourceMuted ? "mic_off" : "mic"

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                onClicked: VolumeSource.toggleSourceMute()
                onWheel: event => VolumeSource.stepSourceVolume(event.angleDelta.y > 0 ? 0.02 : -0.02)
            }
        }

        StyledText {
            visible: Keyboard.available
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.text
            font.pixelSize: Theme.fontS
            text: Keyboard.shortName
        }

        MaterialSymbol {
            visible: Notifications.dnd
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.yellow
            iconSize: Theme.fontM
            text: "notifications_off"

            MouseArea {
                anchors.fill: parent
                onClicked: Notifications.toggleDnd()
            }
        }

        MaterialSymbol {
            visible: IdleInhibit.active
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.yellow
            iconSize: Theme.fontM
            text: "coffee"

            MouseArea {
                anchors.fill: parent
                onClicked: IdleInhibit.toggle()
            }
        }
    }
}
