import qs
import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../Components"

MouseArea {
    id: root

    required property var panelWindow

    visible: BatterySource.available
    implicitWidth: 34
    implicitHeight: Theme.barHeight - 8
    hoverEnabled: true

    readonly property real percentage: BatterySource.percentage
    readonly property real charge: Math.max(0, Math.min(1, percentage / 100))
    readonly property bool charging: BatterySource.charging
    readonly property bool low: charge <= 0.15
    readonly property color accent: charging ? Theme.green : low ? Theme.red : Theme.withSaturation(Theme.withLightness(Theme.accent, 0.85), 1)
    readonly property bool hasTimeEstimate: (BatterySource.state === BatterySource.Charging
        || BatterySource.state === BatterySource.Discharging)
        && BatterySource.timeRemaining > 0

    property bool popupOpen: false
    property real indicatorX: 0

    function formatDuration(seconds) {
        const total = Math.max(0, Math.floor(Number(seconds) || 0))
        const hours = Math.floor(total / 3600)
        const minutes = Math.floor(total % 3600 / 60)
        return hours > 0 ? `${hours}h, ${minutes}m` : `${minutes}m`
    }

    onEntered: {
        closeTimer.stop()
        indicatorX = mapToItem(panelWindow.contentItem, 0, 0).x
        popupOpen = true
    }
    onExited: closeTimer.restart()

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

    Timer {
        id: closeTimer
        interval: 150
        repeat: false
        onTriggered: root.popupOpen = false
    }

    PopupWindow {
        id: popup

        anchor.window: root.panelWindow
        anchor.rect.x: root.indicatorX + root.width / 2 - width / 2
        anchor.rect.y: Theme.barHeight + 6
        visible: root.hasTimeEstimate && (root.popupOpen || popupBackground.opacity > 0)
        color: "transparent"
        implicitWidth: popupBackground.implicitWidth
        implicitHeight: popupBackground.implicitHeight

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: closeTimer.stop()
            onExited: closeTimer.restart()
        }

        Rectangle {
            id: popupBackground
            anchors.fill: parent
            color: Theme.base
            radius: Theme.outerRadius
            implicitWidth: popupContent.implicitWidth + 32
            implicitHeight: popupContent.implicitHeight + 32

            property real yOffset: root.popupOpen ? 0 : -12
            opacity: root.popupOpen ? 1.0 : 0.0
            transform: Translate { y: popupBackground.yOffset }

            Behavior on opacity {
                NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
            }
            Behavior on yOffset {
                NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
            }

            ColumnLayout {
                id: popupContent
                anchors.centerIn: parent
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    MaterialSymbol {
                        text: "battery_android_full"
                        iconSize: Theme.fontL + 2
                        color: Theme.accent
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: "Battery"
                        color: Theme.text
                        font.pixelSize: Theme.fontL
                        font.weight: Theme.weightBold
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    MaterialSymbol {
                        text: "schedule"
                        iconSize: Theme.fontM + 1
                        color: Theme.subtext0
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: root.charging ? "Time to full:" : "Time to empty:"
                        color: Theme.subtext1
                    }

                    StyledText {
                        text: root.formatDuration(BatterySource.timeRemaining)
                        color: Theme.text
                        font.weight: Theme.weightBold
                    }
                }
            }
        }
    }
}
