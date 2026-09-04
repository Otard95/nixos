import qs
import QtQuick
import QtQuick.Layouts
import "../../../Components"

Item {
    id: root

    readonly property var player: MediaSource.activePlayer
    property bool trackTransitionActive: false

    function beginTrackTransition() {
        trackTransitionActive = true;
        trackTransitionTimer.restart();
    }

    onPlayerChanged: beginTrackTransition()

    Connections {
        target: root.player

        function onTrackChanged() {
            root.beginTrackTransition();
        }
    }

    Timer {
        id: trackTransitionTimer

        interval: 250
        onTriggered: root.trackTransitionActive = false
    }

    function formatTime(seconds) {
        const total = Math.max(0, Math.floor(Number(seconds) || 0));
        const hours = Math.floor(total / 3600);
        const minutes = Math.floor(total % 3600 / 60);
        const remainder = total % 60;
        return hours > 0 ? hours + ":" + minutes.toString().padStart(2, "0") + ":" + remainder.toString().padStart(2, "0") : minutes + ":" + remainder.toString().padStart(2, "0");
    }

    ColumnLayout {
        visible: root.player !== null
        anchors {
            fill: parent
            margins: 14
        }
        spacing: 10

        RowLayout {
            Layout.fillWidth: true

            StyledText {
                Layout.fillWidth: true
                color: Theme.subtext0
                elide: Text.ElideRight
                font.weight: Theme.weightBold
                text: root.player?.identity || "Media player"
            }

            RowLayout {
                spacing: 4

                MiniButton {
                    icon: "chevron_left"
                    enabled: MediaSource.players.length > 1
                    onClicked: MediaSource.selectPreviousPlayer()
                }

                StyledText {
                    color: Theme.overlay0
                    font.pixelSize: Theme.fontS
                    text: (Math.max(0, MediaSource.players.indexOf(root.player)) + 1) + " / " + MediaSource.players.length
                }

                MiniButton {
                    icon: "chevron_right"
                    enabled: MediaSource.players.length > 1
                    onClicked: MediaSource.selectNextPlayer()
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 112
            spacing: 12

            Rectangle {
                Layout.preferredWidth: 112
                Layout.preferredHeight: 112
                radius: Theme.innerRadius
                color: Theme.base
                clip: true

                Image {
                    id: cover
                    anchors.fill: parent
                    source: root.player?.trackArtUrl ?? ""
                    asynchronous: true
                    fillMode: Image.PreserveAspectCrop
                }

                MaterialSymbol {
                    visible: cover.status !== Image.Ready
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    iconSize: 42
                    color: Theme.overlay0
                    text: "music_note"
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 4

                Item {
                    Layout.fillHeight: true
                }

                StyledText {
                    Layout.fillWidth: true
                    color: Theme.text
                    elide: Text.ElideRight
                    font.pixelSize: Theme.fontL
                    font.weight: Theme.weightBold
                    text: root.player?.trackTitle || "Unknown title"
                }

                StyledText {
                    Layout.fillWidth: true
                    color: Theme.subtext0
                    elide: Text.ElideRight
                    text: root.player?.trackArtist || "Unknown artist"
                }

                StyledText {
                    visible: (root.player?.trackAlbum ?? "") !== ""
                    Layout.fillWidth: true
                    color: Theme.overlay0
                    elide: Text.ElideRight
                    font.pixelSize: Theme.fontS
                    text: root.player?.trackAlbum ?? ""
                }

                Item {
                    Layout.fillHeight: true
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            RowLayout {
                Layout.fillWidth: true

                StyledText {
                    color: Theme.overlay0
                    font.pixelSize: Theme.fontS
                    text: root.formatTime(root.player?.position ?? 0)
                }

                Item {
                    Layout.fillWidth: true
                }

                StyledText {
                    color: Theme.overlay0
                    font.pixelSize: Theme.fontS
                    text: root.formatTime(root.player?.length ?? 0)
                }
            }

            StyledSlider {
                Layout.fillWidth: true
                trackSize: root.player?.isPlaying ? StyledSlider.Wavy : StyledSlider.Thin
                animateWave: root.visible && (root.player?.isPlaying ?? false)
                smoothPosition: true
                positionAnimationDuration: root.trackTransitionActive ? 150 : 1000
                from: 0
                to: Math.max(root.player?.length ?? 0, 1)
                value: root.player?.position ?? 0
                enabled: (root.player?.canSeek ?? false) && (root.player?.positionSupported ?? false)
                tooltipFormatter: root.formatTime
                onMoved: {
                    if (root.player?.canSeek && root.player?.positionSupported)
                        root.player.position = value;
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 14

            ControlButton {
                icon: "skip_previous"
                enabled: root.player?.canGoPrevious ?? false
                onClicked: MediaSource.previous()
            }

            ControlButton {
                main: true
                icon: root.player?.isPlaying ? "pause" : "play_arrow"
                enabled: root.player?.isPlaying ? (root.player?.canPause ?? false) : (root.player?.canPlay ?? false)
                onClicked: MediaSource.togglePlaying()
            }

            ControlButton {
                icon: "skip_next"
                enabled: root.player?.canGoNext ?? false
                onClicked: MediaSource.next()
            }
        }
    }

    Column {
        visible: root.player === null
        anchors.centerIn: parent
        spacing: 8

        MaterialSymbol {
            anchors.horizontalCenter: parent.horizontalCenter
            iconSize: 40
            color: Theme.overlay0
            text: "music_note"
        }

        StyledText {
            color: Theme.subtext0
            text: "No active player"
        }
    }

    component ControlButton: Rectangle {
        id: control

        required property string icon
        property bool main: false
        signal clicked

        implicitWidth: main ? 48 : 40
        implicitHeight: width
        radius: width / 2
        color: main ? Theme.accent : controlMouse.containsMouse ? Theme.surface0 : Theme.base
        opacity: enabled ? 1 : 0.4

        MaterialSymbol {
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            iconSize: control.main ? 26 : 22
            color: control.main ? Theme.base : Theme.text
            text: control.icon
        }

        MouseArea {
            id: controlMouse
            anchors.fill: parent
            enabled: control.enabled
            hoverEnabled: true
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: control.clicked()
        }
    }

    component MiniButton: Item {
        id: mini

        required property string icon
        signal clicked

        implicitWidth: 24
        implicitHeight: 24
        opacity: enabled ? 1 : 0.4

        MaterialSymbol {
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            iconSize: 18
            color: miniMouse.containsMouse ? Theme.text : Theme.subtext0
            text: mini.icon
        }

        MouseArea {
            id: miniMouse
            anchors.fill: parent
            enabled: mini.enabled
            hoverEnabled: true
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: mini.clicked()
        }
    }
}
