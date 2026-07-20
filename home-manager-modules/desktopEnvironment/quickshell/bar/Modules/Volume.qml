import qs
import QtQuick

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

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: Theme.font
                        font.pixelSize: Theme.fontMd
                        color: VolumeSource.sinkMuted ? Theme.surface2 : Theme.text

                        text: {
                            if (!VolumeSource.sinkAvailable)
                                return "󰕿";
                            if (VolumeSource.sinkMuted)
                                return "󰝟";
                            const vol = VolumeSource.sinkVolume;
                            if (vol < 0.33)
                                return "󰕿";
                            if (vol < 0.66)
                                return "󰖀";
                            return "󰕾";
                        }
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSm
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

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: Theme.font
                        font.pixelSize: Theme.fontMd
                        color: VolumeSource.sourceMuted ? Theme.surface2 : Theme.text
                        text: VolumeSource.sourceMuted ? "󰍭" : "󰍬"
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSm
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
