import qs
import QtQuick
import QtQuick.Layouts
import Quickshell

Pill {
    id: root

    required property var panelWindow

    // ── Derived display properties ─────────────────────────────────────
    readonly property color iconColor: {
        if (!NetworkSource.available)
            return Theme.red;
        if (!NetworkSource.isWifi)
            return Theme.teal;
        const s = NetworkSource.signalStrength;
        return s < 0.25 ? Theme.red : s < 0.50 ? Theme.peach : Theme.teal;
    }

    readonly property string icon: {
        if (!NetworkSource.available)
            return "󰤫";
        if (!NetworkSource.isWifi)
            return "󰈁";
        const s = NetworkSource.signalStrength;
        if (s < 0.25)
            return "󰤯";
        if (s < 0.50)
            return "󰤟";
        if (s < 0.75)
            return "󰤢";
        if (s < 0.90)
            return "󰤥";
        return "󰤨";
    }

    // ── Hover logic ────────────────────────────────────────────────────
    property bool popupOpen: false
    property real pillX: 0

    Timer {
        id: closeTimer
        interval: 150
        repeat: false
        onTriggered: root.popupOpen = false
    }

    // ── Pill content ───────────────────────────────────────────────────
    Item {
        implicitWidth: iconText.implicitWidth + 30
        implicitHeight: Theme.barHeight - 10

        Text {
            id: iconText
            anchors.centerIn: parent
            font.family: Theme.font
            font.pixelSize: Theme.fontMd
            color: root.iconColor
            text: root.icon
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                closeTimer.stop();
                root.pillX = root.mapToItem(root.panelWindow.contentItem, 0, 0).x;
                root.popupOpen = true;
            }
            onExited: closeTimer.restart()
        }
    }

    // ── Hover popup ────────────────────────────────────────────────────
    PopupWindow {
        anchor.window: root.panelWindow
        anchor.rect.x: root.pillX
        anchor.rect.y: Theme.barHeight + 6
        visible: root.popupOpen

        color: "transparent"
        implicitWidth: popupBg.implicitWidth
        implicitHeight: popupBg.implicitHeight

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: closeTimer.stop()
            onExited: closeTimer.restart()
        }

        Rectangle {
            id: popupBg
            anchors.fill: parent
            color: Theme.base
            radius: Theme.outerRadius
            implicitWidth: content.implicitWidth + 32
            implicitHeight: content.implicitHeight + 32

            ColumnLayout {
                id: content
                anchors.centerIn: parent
                spacing: 16

                // ── Disconnected ─────────────────────────────────
                Text {
                    visible: !NetworkSource.available
                    Layout.alignment: Qt.AlignHCenter
                    text: "󰤫  Disconnected"
                    color: Theme.red
                    font.family: Theme.font
                    font.pixelSize: Theme.fontXl
                    font.bold: true
                }

                // ── Connected ────────────────────────────────────
                ColumnLayout {
                    visible: NetworkSource.available
                    spacing: 12

                    // Header: icon + name
                    RowLayout {
                        spacing: 12

                        Text {
                            text: root.icon
                            color: root.iconColor
                            font.family: Theme.font
                            font.pixelSize: 28
                        }

                        ColumnLayout {
                            spacing: 2
                            Text {
                                text: NetworkSource.isWifi ? (NetworkSource.ssid || "Wi-Fi") : "Ethernet"
                                color: Theme.text
                                font.family: Theme.font
                                font.pixelSize: Theme.fontXl
                                font.bold: true
                            }
                            Text {
                                text: NetworkSource.deviceName
                                color: Theme.subtext0
                                font.family: Theme.font
                                font.pixelSize: Theme.fontXs
                            }
                        }
                    }

                    // Signal bars (wifi only)
                    ColumnLayout {
                        visible: NetworkSource.isWifi && NetworkSource.signalStrength > 0
                        spacing: 6

                        Row {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 5

                            Repeater {
                                model: 5
                                delegate: Rectangle {
                                    required property int index
                                    readonly property real threshold: (index + 0.5) / 5.0
                                    readonly property bool lit: NetworkSource.signalStrength >= threshold

                                    width: 10
                                    height: 8 + index * 6
                                    radius: 3
                                    anchors.bottom: parent ? parent.bottom : undefined
                                    color: lit ? root.iconColor : Theme.surface0
                                }
                            }
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: Math.round(NetworkSource.signalStrength * 100) + "% signal"
                            color: Theme.subtext1
                            font.family: Theme.font
                            font.pixelSize: Theme.fontXs
                        }
                    }

                    // Separator
                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: Theme.surface1
                    }

                    // Addresses
                    ColumnLayout {
                        spacing: 6

                        // IPv4
                        RowLayout {
                            visible: NetworkSource.ipv4 !== ""
                            spacing: 8

                            Text {
                                text: "IPv4"
                                color: Theme.overlay1
                                font.family: Theme.font
                                font.pixelSize: Theme.fontXs
                                font.bold: true
                                Layout.preferredWidth: 36
                            }
                            Text {
                                text: NetworkSource.ipv4
                                color: Theme.subtext1
                                font.family: Theme.font
                                font.pixelSize: Theme.fontMd
                            }
                        }

                        // IPv6
                        RowLayout {
                            visible: NetworkSource.ipv6 !== ""
                            spacing: 8

                            Text {
                                text: "IPv6"
                                color: Theme.overlay1
                                font.family: Theme.font
                                font.pixelSize: Theme.fontXs
                                font.bold: true
                                Layout.preferredWidth: 36
                            }
                            Text {
                                text: NetworkSource.ipv6
                                color: Theme.subtext1
                                font.family: Theme.font
                                font.pixelSize: Theme.fontMd
                            }
                        }

                        // MAC
                        RowLayout {
                            spacing: 8

                            Text {
                                text: "MAC"
                                color: Theme.overlay1
                                font.family: Theme.font
                                font.pixelSize: Theme.fontXs
                                font.bold: true
                                Layout.preferredWidth: 36
                            }
                            Text {
                                text: NetworkSource.macAddress
                                color: Theme.surface2
                                font.family: Theme.font
                                font.pixelSize: Theme.fontMd
                            }
                        }
                    }
                }
            }
        }
    }
}
