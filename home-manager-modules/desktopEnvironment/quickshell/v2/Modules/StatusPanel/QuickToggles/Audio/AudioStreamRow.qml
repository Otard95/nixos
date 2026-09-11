import qs
import QtQuick
import "../../../../Components"

// One per-app audio stream: label + mute toggle + volume slider.
Item {
    id: root

    required property var node
    // "output" (playback apps) or "input" (recording apps) — picks the icon.
    property string kind: "output"

    readonly property bool valid: !!node
    readonly property bool muted: Audio.nodeMuted(node)

    readonly property string muteIcon: kind === "input"
        ? (muted ? "mic_off" : "mic")
        : (muted ? "volume_off" : "volume_up")

    width: parent?.width ?? 0
    height: valid ? 60 : 0
    visible: valid

    Column {
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        spacing: 2

        Row {
            width: parent.width
            spacing: 8

            MaterialSymbol {
                id: icon
                anchors.verticalCenter: parent.verticalCenter
                iconSize: 20
                color: root.muted ? Theme.overlay1 : Theme.subtext1
                text: root.muteIcon

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Audio.toggleNodeMute(root.node)
                }
            }

            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - icon.width - parent.spacing
                color: Theme.text
                font.pixelSize: Theme.fontS
                elide: Text.ElideRight
                text: Audio.nodeLabel(root.node)
            }
        }

        StyledSlider {
            width: parent.width
            trackSize: StyledSlider.Thin
            trackColor: Theme.base
            value: Audio.nodeVolume(root.node)
            onMoved: Audio.setNodeVolume(root.node, value)
        }
    }
}
