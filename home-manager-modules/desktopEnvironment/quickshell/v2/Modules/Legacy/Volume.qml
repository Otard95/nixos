import qs
import QtQuick
import "../../Components"

Pill {
    id: root

    readonly property real step: 0.02

    Item {
        implicitWidth: row.implicitWidth + Theme.innerPadH * 2
        implicitHeight: Theme.barHeight - 10

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 6

            // ── Speaker ───────────────────────────────────────
            Item {
                implicitWidth: sinkRow.implicitWidth
                implicitHeight: Theme.barHeight - 10

                Row {
                    id: sinkRow
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4

                    MaterialSymbol {
                        anchors.verticalCenter: parent.verticalCenter
                        iconSize: Theme.fontM
                        color: VolumeSource.sinkMuted ? Theme.surface2 : Theme.text

                        text: {
                            if (!VolumeSource.sinkAvailable || VolumeSource.sinkMuted)
                                return "volume_off";
                            return VolumeSource.sinkVolume < 0.5 ? "volume_down" : "volume_up";
                        }
                    }

                    StyledText {
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: Theme.font
                        font.pixelSize: Theme.fontS
                        color: VolumeSource.sinkMuted ? Theme.surface2 : Theme.text
                        text: VolumeSource.sinkAvailable ? VolumeSource.sinkPercent + "%" : ""
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: VolumeSource.toggleSinkMute()
                    onWheel: event => {
                        VolumeSource.stepSinkVolume(event.angleDelta.y > 0 ? root.step : -root.step);
                    }
                }
            }

            // ── Mic ───────────────────────────────────────────
            Item {
                visible: VolumeSource.sourceAvailable
                implicitWidth: visible ? sourceRow.implicitWidth : 0
                implicitHeight: Theme.barHeight - 10

                Row {
                    id: sourceRow
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4

                    MaterialSymbol {
                        anchors.verticalCenter: parent.verticalCenter
                        iconSize: Theme.fontM
                        color: VolumeSource.sourceMuted ? Theme.surface2 : Theme.text
                        text: VolumeSource.sourceMuted ? "mic_off" : "mic"
                    }

                    StyledText {
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: Theme.font
                        font.pixelSize: Theme.fontS
                        color: VolumeSource.sourceMuted ? Theme.surface2 : Theme.text
                        text: VolumeSource.sourceAvailable ? VolumeSource.sourcePercent + "%" : ""
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: VolumeSource.toggleSourceMute()
                    onWheel: event => {
                        VolumeSource.stepSourceVolume(event.angleDelta.y > 0 ? root.step : -root.step);
                    }
                }
            }
        }
    }
}
