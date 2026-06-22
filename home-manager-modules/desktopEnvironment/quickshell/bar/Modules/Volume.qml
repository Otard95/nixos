import qs
import QtQuick
import Quickshell.Services.Pipewire

Pill {
    id: root

    readonly property PwNode sink:   Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    PwObjectTracker { objects: [sink, source] }

    Item {
        implicitWidth:  row.implicitWidth + Theme.innerPadH * 2
        implicitHeight: Theme.barHeight - 10

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 6

            // ── Speaker ───────────────────────────────────────
            Item {
                implicitWidth:  sinkRow.implicitWidth
                implicitHeight: Theme.barHeight - 10

                Row {
                    id: sinkRow
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: Theme.font
                        font.pixelSize: Theme.fontLg
                        color: sink?.audio?.muted ? Theme.surface2 : Theme.text

                        text: {
                            if (!sink?.audio) return "󰕿"
                            if (sink.audio.muted) return "󰝟"
                            const vol = sink.audio.volume
                            if (vol < 0.33) return "󰕿"
                            if (vol < 0.66) return "󰖀"
                            return "󰕾"
                        }
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSm
                        color: sink?.audio?.muted ? Theme.surface2 : Theme.text
                        text: sink?.audio ? Math.round(sink.audio.volume * 100) + "%" : ""
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: { if (sink?.audio) sink.audio.muted = !sink.audio.muted }
                    onWheel: (event) => {
                        if (!sink?.audio) return
                        const step = 0.02
                        if (event.angleDelta.y > 0)
                            sink.audio.volume = Math.min(1.0, sink.audio.volume + step)
                        else
                            sink.audio.volume = Math.max(0.0, sink.audio.volume - step)
                    }
                }
            }

            // ── Mic ───────────────────────────────────────────
            Item {
                visible: source?.audio !== undefined && source?.audio !== null
                implicitWidth:  visible ? sourceRow.implicitWidth : 0
                implicitHeight: Theme.barHeight - 10

                Row {
                    id: sourceRow
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: Theme.font
                        font.pixelSize: Theme.fontLg
                        color: source?.audio?.muted ? Theme.surface2 : Theme.text
                        text: source?.audio?.muted ? "󰍭" : "󰍬"
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSm
                        color: source?.audio?.muted ? Theme.surface2 : Theme.text
                        text: source?.audio ? Math.round(source.audio.volume * 100) + "%" : ""
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: { if (source?.audio) source.audio.muted = !source.audio.muted }
                    onWheel: (event) => {
                        if (!source?.audio) return
                        const step = 0.02
                        if (event.angleDelta.y > 0)
                            source.audio.volume = Math.min(1.0, source.audio.volume + step)
                        else
                            source.audio.volume = Math.max(0.0, source.audio.volume - step)
                    }
                }
            }
        }
    }
}
