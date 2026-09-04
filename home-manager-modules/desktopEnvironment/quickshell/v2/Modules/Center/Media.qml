import qs
import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import "../../Components"

WrapperMouseArea {
    id: root

    readonly property var player: MediaSource.activePlayer
    readonly property real progress: MediaSource.progress

    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: mouse => {
        if (mouse.button === Qt.RightButton)
            MediaSource.next();
        else
            MediaSource.togglePlaying();
    }

    RowLayout {
        spacing: 5

        Item {
            implicitWidth: 24
            implicitHeight: 24
            Layout.alignment: Qt.AlignVCenter

            Canvas {
                id: canvas
                anchors.fill: parent
                onPaint: {
                    const ctx = getContext("2d");
                    ctx.reset();
                    const cx = width / 2, cy = height / 2;
                    const r = cx - 2;
                    const lw = 2.5;

                    ctx.lineWidth = lw;
                    ctx.lineCap = "round";

                    ctx.strokeStyle = Theme.alpha(Theme.accent, 0.25);
                    ctx.beginPath();
                    ctx.arc(cx, cy, r, 0, Math.PI * 2);
                    ctx.stroke();

                    if (root.progress > 0) {
                        ctx.strokeStyle = Theme.accent;
                        ctx.beginPath();
                        ctx.arc(cx, cy, r, -Math.PI / 2, -Math.PI / 2 + Math.PI * 2 * root.progress);
                        ctx.stroke();
                    }
                }
                Connections {
                    target: root
                    function onProgressChanged() {
                        canvas.requestPaint();
                    }
                }
            }

            MaterialSymbol {
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: root.player?.isPlaying ? "pause" : "play_arrow"
                iconSize: 13
                color: Theme.text
            }
        }

        StyledText {
            Layout.alignment: Qt.AlignVCenter
            Layout.maximumWidth: 180
            elide: Text.ElideRight
            color: Theme.accentText
            font.pixelSize: Theme.fontS
            text: root.player?.trackTitle ? (root.player.trackArtist ? root.player.trackTitle + " • " + root.player.trackArtist : root.player.trackTitle) : "No media"
        }
    }
}
