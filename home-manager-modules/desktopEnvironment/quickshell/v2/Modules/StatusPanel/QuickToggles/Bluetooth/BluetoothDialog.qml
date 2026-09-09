import qs
import QtQuick
import Quickshell
import ".."

// Bluetooth device list. Unlike WifiDialog there is no frozen scan window:
// pairing is interactive, so the list stays live (ScriptModel over the source's
// sorted view). Discovery runs only while the dialog is open.
OverlayDialog {
    id: root
    onDismissed: close()

    // Which row is expanded to show its actions. One at a time.
    property var expandedDevice: null

    onOpenChanged: {
        if (open) {
            BluetoothSource.setDiscovering(true)
        } else {
            BluetoothSource.setDiscovering(false)
            root.expandedDevice = null
        }
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
                text: "Bluetooth"
            }
        }

        // Separator — accent-colored sweep while discovering
        Item {
            width: parent.width * 0.5
            anchors.horizontalCenter: parent.horizontalCenter
            height: 3
            clip: true

            Rectangle {
                width: parent.width
                height: parent.height
                radius: height / 2
                color: Theme.surface0
            }

            Rectangle {
                id: scanBar
                width: parent.width * 0.35
                height: parent.height
                radius: height / 2
                color: Theme.accent
                visible: BluetoothSource.discovering

                SequentialAnimation on x {
                    running: BluetoothSource.discovering
                    loops: Animation.Infinite
                    NumberAnimation {
                        from: -scanBar.width
                        to: scanBar.parent.width
                        duration: 1200
                        easing.type: Easing.InOutCubic
                    }
                    PauseAnimation {
                        duration: 0
                    }
                }
            }
        }

        // Empty hint
        StyledText {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            visible: BluetoothSource.friendlyDevices.length === 0
            color: Theme.subtext0
            font.pixelSize: Theme.fontS
            text: BluetoothSource.enabled ? "Searching for devices…" : "Bluetooth is off"
        }

        // Device list
        ListView {
            id: deviceList
            width: parent.width
            height: 280
            clip: true
            spacing: 4
            topMargin: 8
            bottomMargin: 8

            // ScriptModel launders the QObject list safely — devices come and
            // go during discovery, and a raw array crashes delegate incubation
            // when one is freed mid-update.
            model: ScriptModel {
                values: BluetoothSource.friendlyDevices
            }

            delegate: BluetoothDeviceRow {
                required property var modelData
                device: modelData
                dialog: root
            }
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
}
