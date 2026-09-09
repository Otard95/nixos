import qs
import QtQuick
import "../../../../Components"

// One device in the list. Collapsed: icon, name, status/battery, chevron.
// Expanded (click): pair/forget + connect/disconnect actions. Only one row
// is expanded at a time — the dialog owns `expandedDevice`.
Item {
    id: root

    required property var device
    required property var dialog

    readonly property bool valid: !!device
    readonly property bool expanded: dialog.expandedDevice === device
    readonly property bool paired: (device?.paired || device?.bonded) ?? false
    readonly property bool connected: device?.connected ?? false
    readonly property bool busy: BluetoothSource.deviceBusy(device)

    width: parent?.width ?? 0
    height: valid ? column.implicitHeight + 16 : 0
    visible: valid

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: root.connected ? Theme.alpha(Theme.accent, 0.18) : Theme.alpha(Theme.surface0, 0)

        Behavior on color {
            ColorAnimation { duration: 150 }
        }
    }

    Column {
        id: column
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            topMargin: 8
            leftMargin: 12
            rightMargin: 12
        }
        spacing: 8

        // Main row
        Item {
            width: parent.width
            height: 40
            opacity: root.busy ? 0.55 : 1.0

            Behavior on opacity {
                NumberAnimation { duration: 150 }
            }

            MaterialSymbol {
                id: devIcon
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
                iconSize: 22
                color: root.connected ? Theme.accent : Theme.subtext0
                text: BluetoothSource.deviceSymbol(root.device)
            }

            MaterialSymbol {
                id: chevron
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                iconSize: 22
                color: Theme.subtext0
                text: "keyboard_arrow_down"
                rotation: root.expanded ? 180 : 0

                Behavior on rotation {
                    NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                }
            }

            // Battery cluster — only when the device reports a level.
            Row {
                id: battery
                anchors {
                    right: chevron.left
                    rightMargin: 8
                    verticalCenter: parent.verticalCenter
                }
                spacing: 4
                visible: (root.device?.batteryAvailable ?? false)

                readonly property real level: root.device?.battery ?? 0
                readonly property bool low: level < 0.10

                MaterialSymbol {
                    anchors.verticalCenter: parent.verticalCenter
                    iconSize: 18
                    // Vertical battery symbols read upright rotated 90°.
                    color: battery.low ? Theme.red : Theme.subtext0
                    text: BluetoothSource.batteryIcon(battery.level)
                }

                StyledText {
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: Theme.fontS
                    color: battery.low ? Theme.red : Theme.subtext0
                    text: Math.round(battery.level * 100) + "%"
                }
            }

            Column {
                anchors {
                    left: devIcon.right
                    leftMargin: 12
                    right: battery.visible ? battery.left : chevron.left
                    rightMargin: 8
                    verticalCenter: parent.verticalCenter
                }
                spacing: 0

                StyledText {
                    width: parent.width
                    color: root.connected ? Theme.text : Theme.subtext1
                    font.weight: root.connected ? Theme.weightBold : Theme.weightNormal
                    elide: Text.ElideRight
                    text: BluetoothSource.deviceLabel(root.device) || "Unknown device"
                }

                StyledText {
                    width: parent.width
                    visible: text !== ""
                    color: Theme.subtext0
                    font.pixelSize: Theme.fontS
                    elide: Text.ElideRight
                    text: BluetoothSource.stateLabel(root.device)
                }
            }
        }

        // Actions — shown when expanded
        Row {
            width: parent.width
            visible: root.expanded
            bottomPadding: 4
            layoutDirection: Qt.RightToLeft
            spacing: 8

            // Connect / disconnect
            Rectangle {
                height: 30
                width: connectLabel.implicitWidth + 24
                radius: height / 2
                color: Theme.alpha(Theme.accent, 0.22)

                StyledText {
                    id: connectLabel
                    anchors.centerIn: parent
                    color: Theme.accent
                    font.weight: Theme.weightBold
                    text: root.connected ? "Disconnect" : "Connect"
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    enabled: !root.busy
                    onClicked: {
                        if (root.connected)
                            BluetoothSource.disconnectDevice(root.device)
                        else
                            BluetoothSource.connectDevice(root.device)
                    }
                }
            }

            // Pair / forget
            Rectangle {
                height: 30
                width: pairLabel.implicitWidth + 24
                radius: height / 2
                color: root.paired ? Theme.alpha(Theme.red, 0.18) : Theme.alpha(Theme.surface0, 0.7)

                StyledText {
                    id: pairLabel
                    anchors.centerIn: parent
                    color: root.paired ? Theme.red : Theme.subtext1
                    text: root.paired ? "Forget" : "Pair"
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    enabled: !root.busy
                    onClicked: {
                        if (root.paired)
                            BluetoothSource.forgetDevice(root.device)
                        else
                            BluetoothSource.pairDevice(root.device)
                    }
                }
            }
        }
    }

    MouseArea {
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        height: 48
        cursorShape: Qt.PointingHandCursor
        enabled: root.valid
        onClicked: root.dialog.expandedDevice = root.expanded ? null : root.device
    }
}
