import qs
import QtQuick
import Quickshell
import ".."
import "../../../../Components"

// Single audio dialog with three tabs: Output, Input, Devices. Opened by the
// Audio toggle (span-2, info area) at the Output tab; the other tabs are
// reached via the in-dialog tab bar. Card profiles live under the Devices tab
// but stay hidden until AudioProfileSource has a real backend.
OverlayDialog {
    id: root
    onDismissed: close()

    dialogWidth: 420

    // Active tab: "output" | "input" | "devices".
    property string tab: "output"

    function openTab(name: string): void {
        root.tab = name;
        root.open = true;
    }

    Column {
        width: parent.width
        spacing: 10

        // Title
        Item {
            width: parent.width
            height: 30

            StyledText {
                anchors.centerIn: parent
                color: Theme.text
                font.pixelSize: Theme.fontL
                font.weight: Theme.weightBold
                text: "Audio"
            }
        }

        // Tab bar
        Row {
            id: tabBar
            width: parent.width
            spacing: 6

            property real tabWidth: (width - spacing * 2) / 3

            Repeater {
                model: [
                    { id: "output",  label: "Output" },
                    { id: "input",   label: "Input" },
                    { id: "devices", label: "Devices" }
                ]

                Rectangle {
                    required property var modelData
                    readonly property bool current: root.tab === modelData.id

                    width: tabBar.tabWidth
                    height: 34
                    radius: height / 2
                    color: current ? Theme.alpha(Theme.accent, 0.2) : Theme.base

                    StyledText {
                        anchors.centerIn: parent
                        color: parent.current ? Theme.accent : Theme.subtext0
                        font.weight: parent.current ? Theme.weightBold : Theme.weightNormal
                        text: parent.modelData.label
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.tab = parent.modelData.id
                    }
                }
            }
        }

        // Tab content — Loader keeps the card sized to the active tab only.
        Loader {
            width: parent.width
            sourceComponent: root.tab === "output" ? outputTab
                : root.tab === "input" ? inputTab
                : devicesTab
        }

        // Footer separator
        Rectangle {
            width: parent.width
            height: 1
            color: Theme.surface0
        }

        // Footer
        Item {
            width: parent.width
            height: 44

            Rectangle {
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                height: 32
                width: doneLabel.implicitWidth + 24
                radius: height / 2
                color: Theme.alpha(Theme.accent, 0.2)

                StyledText {
                    id: doneLabel
                    anchors.centerIn: parent
                    color: Theme.accent
                    font.weight: Theme.weightBold
                    text: "Done"
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.dismissed()
                }
            }
        }
    }

    // ── Output tab ─────────────────────────────────────────────────────
    Component {
        id: outputTab

        Column {
            width: parent.width
            spacing: 8

            StyledSlider {
                width: parent.width
                trackSize: StyledSlider.Wide
                trackColor: Theme.base
                value: Audio.sinkVolume
                onMoved: Audio.setSinkVolume(value)

                markers: [
                    SliderMarker {
                        value: 0.75
                        divider: true
                        icon: "hearing"
                    },
                    SliderMarker {
                        value: 1
                        icon: Audio.sinkMuted ? "volume_off" : "volume_up"
                    }
                ]
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.surface0
            }

            StreamList {
                width: parent.width
                streams: Audio.outputStreams
                kind: "output"
                emptyText: "No apps playing audio"
            }
        }
    }

    // ── Input tab ──────────────────────────────────────────────────────
    Component {
        id: inputTab

        Column {
            width: parent.width
            spacing: 8

            StyledSlider {
                width: parent.width
                trackSize: StyledSlider.Wide
                trackColor: Theme.base
                value: Audio.sourceVolume
                onMoved: Audio.setSourceVolume(value)

                markers: [
                    SliderMarker {
                        value: 1
                        icon: Audio.sourceMuted ? "mic_off" : "mic"
                    }
                ]
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.surface0
            }

            StreamList {
                width: parent.width
                streams: Audio.inputStreams
                kind: "input"
                emptyText: "No apps recording"
            }
        }
    }

    // ── Devices tab ────────────────────────────────────────────────────
    Component {
        id: devicesTab

        Column {
            width: parent.width
            spacing: 6

            DeviceSection {
                width: parent.width
                title: "Output"
                devices: Audio.sinks
                isSelected: n => Audio.isDefaultSink(n)
                onPick: n => Audio.setDefaultSink(n)
            }

            DeviceSection {
                width: parent.width
                title: "Input"
                devices: Audio.sources
                isSelected: n => Audio.isDefaultSource(n)
                onPick: n => Audio.setDefaultSource(n)
            }

            // Card profiles — hidden until a backend exists (Null strategy).
            StyledText {
                width: parent.width
                visible: AudioProfileSource.available
                topPadding: 6
                color: Theme.subtext0
                font.pixelSize: Theme.fontS
                text: "Profiles"
            }
        }
    }

    // ── Local reusable pieces ──────────────────────────────────────────
    component StreamList: Column {
        id: streamList
        property var streams: []
        property string kind: "output"
        property string emptyText: ""

        spacing: 4

        StyledText {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            topPadding: 20
            bottomPadding: 20
            visible: streamList.streams.length === 0
            color: Theme.subtext0
            font.pixelSize: Theme.fontS
            text: streamList.emptyText
        }

        ListView {
            width: parent.width
            height: streamList.streams.length === 0 ? 0 : 220
            clip: true
            spacing: 4
            interactive: contentHeight > height

            model: ScriptModel {
                values: streamList.streams
            }

            delegate: AudioStreamRow {
                required property var modelData
                node: modelData
                kind: streamList.kind
            }
        }
    }

    component DeviceSection: Column {
        id: section
        property string title: ""
        property var devices: []
        property var isSelected: (n) => false
        signal pick(var node)

        spacing: 2

        StyledText {
            width: parent.width
            topPadding: 4
            color: Theme.subtext0
            font.pixelSize: Theme.fontS
            font.weight: Theme.weightBold
            text: section.title
        }

        ListView {
            width: parent.width
            height: Math.min(section.devices.length, 4) * 44
            clip: true
            interactive: contentHeight > height

            model: ScriptModel {
                values: section.devices
            }

            delegate: AudioDeviceRow {
                required property var modelData
                node: modelData
                selected: section.isSelected(modelData)
                onClicked: section.pick(modelData)
            }
        }
    }
}
