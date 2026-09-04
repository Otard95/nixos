import qs
import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../../Components"

Rectangle {
    id: root

    signal closeRequested

    property var pendingPowerAction: null
    property real horizontalPadding: 20
    property real verticalPadding: 10

    implicitWidth: actionRow.implicitWidth + horizontalPadding * 2
    implicitHeight: actionRow.implicitHeight + verticalPadding * 2
    color: Theme.mantle
    radius: height / 2

    function runPowerAction(command) {
        powerProcess.command = command;
        powerProcess.running = true;
        closeRequested();
    }

    function confirmPowerAction() {
        if (pendingPowerAction !== null)
            runPowerAction(pendingPowerAction.command);
    }

    onCloseRequested: pendingPowerAction = null

    RowLayout {
        id: actionRow
        anchors.centerIn: parent
        spacing: 14

        Repeater {
            model: root.pendingPowerAction === null ? [
                {
                    icon: "logout",
                    command: ["hyprlock"]
                },
                {
                    icon: "restart_alt",
                    label: "Restart",
                    command: ["systemctl", "reboot"]
                },
                {
                    icon: "power_settings_new",
                    label: "Power off",
                    confirmOnLeft: true,
                    command: ["systemctl", "poweroff"]
                }
            ] : []

            delegate: MaterialSymbol {
                required property var modelData

                iconSize: 22
                color: actionArea.containsMouse ? Theme.text : Theme.subtext0
                text: modelData.icon
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                MouseArea {
                    id: actionArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (parent.modelData.label)
                            root.pendingPowerAction = parent.modelData;
                        else
                            root.runPowerAction(parent.modelData.command);
                    }
                }
            }
        }

        StyledText {
            visible: root.pendingPowerAction !== null
            color: Theme.text
            font.pixelSize: Theme.fontM
            font.weight: Theme.weightBold
            text: root.pendingPowerAction === null ? "" : root.pendingPowerAction.label + "?"
        }

        MaterialSymbol {
            visible: root.pendingPowerAction !== null && root.pendingPowerAction.confirmOnLeft === true
            iconSize: 22
            color: confirmLeftArea.containsMouse ? Theme.red : Theme.subtext0
            text: "check"

            MouseArea {
                id: confirmLeftArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.confirmPowerAction()
            }
        }

        MaterialSymbol {
            visible: root.pendingPowerAction !== null
            iconSize: 22
            color: cancelArea.containsMouse ? Theme.text : Theme.subtext0
            text: "close"

            MouseArea {
                id: cancelArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.pendingPowerAction = null
            }
        }

        MaterialSymbol {
            visible: root.pendingPowerAction !== null && root.pendingPowerAction.confirmOnLeft !== true
            iconSize: 22
            color: confirmRightArea.containsMouse ? Theme.red : Theme.subtext0
            text: "check"

            MouseArea {
                id: confirmRightArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.confirmPowerAction()
            }
        }
    }

    Process {
        id: powerProcess
        running: false
    }
}
