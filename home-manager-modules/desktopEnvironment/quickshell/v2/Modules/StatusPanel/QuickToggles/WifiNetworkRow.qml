import qs
import QtQuick
import "../../../Components"
import Quickshell.Networking

Item {
    id: root

    required property var network
    required property var dialog

    readonly property bool askingPassword: dialog.askingPasswordFor === root.network

    // Per-row: bind directly on the network object, no source relay needed.
    Connections {
        target: root.network
        function onConnectionFailed(reason) {
            if (reason === ConnectionFailReason.NoSecrets)
                root.dialog.askingPasswordFor = root.network;
        }
    }

    // A snapshot entry can briefly hold a stale/invalid network object (e.g.
    // NM re-creates the WifiNetwork on connect). Collapse the row rather than
    // render a broken ghost; the rescan-on-connect then replaces it.
    readonly property bool valid: !!network && (network.name ?? "") !== ""

    width: parent?.width ?? 0
    height: valid ? 55 : 0
    visible: valid

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: root.network?.connected ? Theme.alpha(Theme.accent, 0.18) : Theme.alpha(Theme.surface0, 0)

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }
    }

    // Main row
    Item {
        id: mainRow
        height: 55
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        opacity: root.network?.stateChanging ? 0.55 : 1.0

        Behavior on opacity {
            NumberAnimation {
                duration: 150
            }
        }

        MaterialSymbol {
            id: sigIcon
            anchors {
                left: parent.left
                leftMargin: 12
                verticalCenter: parent.verticalCenter
            }
            iconSize: 20
            color: root.network?.connected ? Theme.accent : Theme.subtext0
            text: NetworkSource.strengthIcon(root.network?.signalStrength ?? 0)
        }

        MaterialSymbol {
            id: savedIcon
            anchors {
                right: secIcon.visible ? secIcon.left : parent.right
                rightMargin: 6
                verticalCenter: parent.verticalCenter
            }
            // With forget-on-cancel, `known` now only marks networks we
            // actually completed a connection to.
            visible: (root.network?.known ?? false) && !root.network?.connected
            iconSize: 16
            color: Theme.overlay1
            text: "bookmark"
        }

        MaterialSymbol {
            id: secIcon
            anchors {
                right: parent.right
                rightMargin: 12
                verticalCenter: parent.verticalCenter
            }
            visible: (root.network?.connected ?? false) || NetworkSource.isSecure(root.network)
            iconSize: 18
            color: root.network?.connected ? Theme.accent : Theme.subtext0
            text: root.network?.connected ? "check" : "lock"
        }

        StyledText {
            anchors {
                left: sigIcon.right
                leftMargin: 10
                right: savedIcon.visible ? savedIcon.left : (secIcon.visible ? secIcon.left : parent.right)
                rightMargin: (savedIcon.visible || secIcon.visible) ? 8 : 12
                verticalCenter: parent.verticalCenter
            }
            color: root.network?.connected ? Theme.text : Theme.subtext1
            font.weight: root.network?.connected ? Theme.weightBold : Theme.weightNormal
            elide: Text.ElideRight
            text: root.network?.name ?? ""
        }
    }

    MouseArea {
        anchors.fill: mainRow
        cursorShape: Qt.PointingHandCursor
        enabled: root.valid && !root.network?.stateChanging && !root.network?.connected
        onClicked: NetworkSource.connectNetwork(root.network)
    }
}
