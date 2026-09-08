import qs
import QtQuick
import "../../../Components"
import Quickshell.Networking

OverlayDialog {
    id: root

    required property var network

    cardColor: Theme.crust

    property bool connecting: false
    property bool wrongPassword: false

    onOpenChanged: {
        if (!open) {
            pskField.text = ""
            root.wrongPassword = false
            root.connecting = false
        }
    }

    Connections {
        target: root.network
        enabled: root.open

        function onConnectionFailed(reason) {
            root.connecting = false
            if (reason === ConnectionFailReason.NoSecrets) {
                root.wrongPassword = true
                pskField.text = ""
            }
        }

        function onConnectedChanged() {
            if (root.network?.connected) {
                root.connecting = false
                root.dismissed()
            }
        }
    }

    Column {
        width: parent.width
        spacing: 14

        // Title
        Item {
            width: parent.width
            height: 48

            StyledText {
                anchors.centerIn: parent
                color: Theme.text
                font.pixelSize: Theme.fontL
                font.weight: Theme.weightBold
                text: root.network?.name ?? ""
            }
        }

        // Wrong-password hint
        StyledText {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            visible: root.wrongPassword
            color: Theme.red
            font.pixelSize: Theme.fontS
            text: "Incorrect password"
        }

        // Password field
        Rectangle {
            width: parent.width
            height: 40
            radius: 10
            color: Theme.surface0
            border.width: root.wrongPassword ? 1 : 0
            border.color: Theme.red

            Behavior on border.width { NumberAnimation { duration: 150 } }

            TextInput {
                id: pskField
                anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
                verticalAlignment: Text.AlignVCenter
                echoMode: TextInput.Password
                passwordCharacter: "●"
                color: Theme.text
                font.family: Theme.font
                font.pixelSize: Theme.fontS
                renderType: Text.QtRendering
                selectionColor: Theme.alpha(Theme.accent, 0.4)
                selectedTextColor: Theme.text
                enabled: !root.connecting
                Keys.onReturnPressed: root.submit()
            }

            StyledText {
                anchors { fill: parent; leftMargin: 12 }
                visible: pskField.text.length === 0 && !root.connecting
                color: Theme.subtext0
                text: "Password"
            }

            StyledText {
                anchors.centerIn: parent
                visible: root.connecting
                color: Theme.subtext0
                text: "Connecting…"
            }
        }

        // Buttons
        Row {
            anchors.right: parent.right
            spacing: 8
            bottomPadding: 4

            Rectangle {
                height: 32
                width: cancelLabel.implicitWidth + 24
                radius: height / 2
                color: Theme.alpha(Theme.surface0, 0.7)
                StyledText {
                    id: cancelLabel
                    anchors.centerIn: parent
                    color: Theme.subtext1
                    text: "Cancel"
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.dismissed()
                }
            }

            Rectangle {
                height: 32
                width: connectLabel.implicitWidth + 24
                radius: height / 2
                color: root.connecting
                    ? Theme.alpha(Theme.surface0, 0.5)
                    : Theme.alpha(Theme.accent, 0.25)
                StyledText {
                    id: connectLabel
                    anchors.centerIn: parent
                    color: root.connecting ? Theme.subtext0 : Theme.accent
                    font.weight: Theme.weightBold
                    text: "Connect"
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    enabled: !root.connecting
                    onClicked: root.submit()
                }
            }
        }
    }

    function submit(): void {
        root.wrongPassword = false
        root.connecting = true
        NetworkSource.connectNetworkWithPsk(root.network, pskField.text)
    }
}
