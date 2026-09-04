import qs
import QtQuick
import QtQuick.Layouts
import "../../Components"

MouseArea {
    id: root

    visible: BatterySource.available
    implicitWidth: 34
    implicitHeight: Theme.barHeight - 8
    hoverEnabled: true

    readonly property real percentage: BatterySource.percentage
    readonly property real charge: Math.max(0, Math.min(1, percentage / 100))
    readonly property bool charging: BatterySource.charging
    readonly property bool low: charge <= 0.15
    readonly property color accent: charging ? Theme.green : low ? Theme.red : Theme.withSaturation(Theme.withLightness(Theme.accent, 0.85), 1)

    Item {
        id: indicator
        anchors.centerIn: parent
        width: root.implicitWidth
        height: 22

        Canvas {
            id: progressCanvas
            anchors.fill: parent
            contextType: "2d"

            function roundedRect(ctx, x, y, width, height, radius) {
                ctx.beginPath();
                ctx.moveTo(x + radius, y);
                ctx.lineTo(x + width - radius, y);
                ctx.arcTo(x + width, y, x + width, y + radius, radius);
                ctx.lineTo(x + width, y + height - radius);
                ctx.arcTo(x + width, y + height, x + width - radius, y + height, radius);
                ctx.lineTo(x + radius, y + height);
                ctx.arcTo(x, y + height, x, y + height - radius, radius);
                ctx.lineTo(x, y + radius);
                ctx.arcTo(x, y, x + radius, y, radius);
                ctx.closePath();
            }

            onPaint: {
                const ctx = getContext("2d");
                ctx.reset();
                roundedRect(ctx, 0, 0, width, height, height / 2);
                ctx.clip();
                ctx.fillStyle = Theme.alpha(root.accent, 0.45);
                ctx.fillRect(0, 0, width, height);
                ctx.fillStyle = root.accent;
                ctx.fillRect(0, 0, width * root.charge, height);
            }

            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()
        }

        Connections {
            target: root
            function onChargeChanged() {
                progressCanvas.requestPaint();
            }
            function onAccentChanged() {
                progressCanvas.requestPaint();
            }
        }

        Item {
            anchors.fill: parent

            RowLayout {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.bottom
                    bottomMargin: (parent.height - height) / 2
                }
                spacing: 0

                MaterialSymbol {
                    visible: root.charging && root.charge < 1
                    text: "bolt"
                    color: Theme.crust
                    iconSize: 12
                    Layout.alignment: Qt.AlignVCenter
                    Layout.leftMargin: -2
                    Layout.rightMargin: -2
                }

                StyledText {
                    text: Math.round(root.percentage)
                    color: Theme.crust
                    font.family: Theme.font
                    font.pixelSize: Theme.fontS
                    font.weight: Theme.weightBold
                    Layout.alignment: Qt.AlignVCenter
                }
            }
        }
    }
}
