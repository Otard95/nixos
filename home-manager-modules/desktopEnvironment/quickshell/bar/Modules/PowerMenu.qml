import qs
import QtQuick
import Quickshell
import Quickshell.Io

Pill {
    id: root

    required property var panelWindow

    property bool menuOpen: false

    Item {
        implicitWidth: icon.implicitWidth + Theme.innerPadH * 2
        implicitHeight: Theme.barHeight - 10

        Text {
            id: icon
            anchors.centerIn: parent
            text: "󰐥"
            color: Theme.red
            font.family: Theme.font
            font.pixelSize: Theme.fontMd
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.menuOpen = !root.menuOpen
        }
    }

    PopupWindow {
        id: popup
        anchor.window: root.panelWindow
        anchor.rect.x: root.panelWindow.width - popupContent.width - Theme.barMarginH
        anchor.rect.y: root.panelWindow.height + 6
        visible: root.menuOpen
        grabFocus: true
        onVisibleChanged: if (!visible)
            root.menuOpen = false

        color: "transparent"

        implicitWidth: popupBg.implicitWidth
        implicitHeight: popupBg.implicitHeight

        Rectangle {
            id: popupBg
            anchors.fill: parent
            color: Theme.base
            radius: Theme.outerRadius
            implicitWidth: popupContent.implicitWidth
            implicitHeight: popupContent.implicitHeight
        }

        Column {
            id: popupContent
            anchors.fill: popupBg
            padding: 8
            spacing: 4

            Repeater {
                model: [
                    {
                        label: "  Lock",
                        cmd: ["hyprlock"]
                    },
                    {
                        label: "  Suspend",
                        cmd: ["systemctl", "suspend"]
                    },
                    {
                        label: "  Logout",
                        cmd: ["uwsm", "stop"]
                    },
                    {
                        label: "  Reboot",
                        cmd: ["systemctl", "reboot"]
                    },
                    {
                        label: "  Shutdown",
                        cmd: ["systemctl", "poweroff"]
                    },
                ]

                delegate: Rectangle {
                    required property var modelData
                    required property int index

                    width: 180
                    height: 32
                    radius: 8
                    color: ma.containsMouse ? Theme.surface1 : "transparent"

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        text: modelData.label
                        color: index >= 3 ? Theme.red : Theme.text
                        font.family: Theme.font
                        font.pixelSize: Theme.fontMd
                    }

                    MouseArea {
                        id: ma
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            root.menuOpen = false;
                            execProc.command = modelData.cmd;
                            execProc.running = true;
                        }
                    }
                }
            }
        }
    }

    Process {
        id: execProc
        running: false
    }
}
