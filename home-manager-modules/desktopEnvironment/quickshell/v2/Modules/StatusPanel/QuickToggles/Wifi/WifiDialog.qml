import qs
import QtQuick
import Quickshell
import ".."

OverlayDialog {
    id: root
    onDismissed: close()

    // Holds the network currently waiting for a password. Kept here so it
    // survives list model resets caused by scan updates.
    property var askingPasswordFor: null

    // Stable view of the network list, built once per open:
    //   1. open   — clear, scan, append-only as results arrive (no reorder)
    //   2. +3s    — sort once, stop scanning; list is frozen from here
    // A frozen list means no scroll jumps and no churn. The trade is that
    // networks appearing after the window are missed until the dialog reopens
    // — acceptable, since the ones you care about show up in the first scan.
    property var networkSnapshot: []
    property bool scanWindowActive: false

    Timer {
        id: scanWindow
        interval: 3000
        onTriggered: {
            root.scanWindowActive = false;
            root.sortSnapshot();
            NetworkSource.setScanning(false);
        }
    }

    // Append-only during the scan window: existing rows keep their position,
    // new rows are added at the end. No sort, no removal.
    Connections {
        target: NetworkSource
        function onWifiNetworksChanged() {
            if (root.open && root.scanWindowActive && root.askingPasswordFor === null)
                root.mergeSnapshot();
        }
        // Reconcile only once we are actually connected (ssid becomes
        // non-empty). Switching networks changes ssid twice — "" on drop, then
        // the new name — and the drop should not trigger its own scan cycle.
        function onSsidChanged() {
            if (root.open && root.askingPasswordFor === null && NetworkSource.ssid !== "")
                root.beginScanWindow();
        }
    }

    function mergeSnapshot(): void {
        const fresh = NetworkSource.friendlyWifiNetworks;
        const kept = root.networkSnapshot.filter(n => fresh.includes(n));
        const added = fresh.filter(n => !kept.includes(n));
        root.networkSnapshot = kept.concat(added);
    }

    // Sort the existing snapshot in place: connected first, then by signal.
    // Reorders only — keeps the same set of objects, so it is safe after the
    // scan window when the source list has collapsed to known-only.
    function sortSnapshot(): void {
        root.networkSnapshot = root.networkSnapshot.slice().sort((a, b) => {
            if (a.connected !== b.connected)
                return a.connected ? -1 : 1;
            return b.signalStrength - a.signalStrength;
        });
    }

    // Close the password prompt. If the network never actually connected, drop
    // the stray NM profile the connect attempt created so `known` stays honest
    // (only networks we completed remain known). Success leaves it in place.
    function closePasswordPrompt(): void {
        const net = root.askingPasswordFor;
        if (net && !net.connected)
            NetworkSource.forgetNetwork(net);
        root.askingPasswordFor = null;
    }

    onAskingPasswordForChanged: {
        // Pause scanning during auth so NM is not busy. Do not resume after —
        // the scan window is a one-shot per open.
        if (askingPasswordFor !== null) {
            scanWindow.stop();
            root.scanWindowActive = false;
            NetworkSource.setScanning(false);
        }
    }

    // Clear, scan, append as results arrive; the timer sorts and stops at 3s.
    function beginScanWindow(): void {
        root.networkSnapshot = [];   // invalidate the previous scan
        root.scanWindowActive = true;
        NetworkSource.setScanning(true);
        root.mergeSnapshot();        // show known/cached networks immediately
        scanWindow.restart();
    }

    onOpenChanged: {
        if (open) {
            root.beginScanWindow();
        } else {
            scanWindow.stop();
            root.scanWindowActive = false;
            NetworkSource.setScanning(false);
            root.askingPasswordFor = null;
            root.networkSnapshot = [];
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
                text: "Connect to Wi-Fi"
            }
        }

        // Separator — accent-colored while scanning
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
                visible: NetworkSource.scanning

                SequentialAnimation on x {
                    running: NetworkSource.scanning
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

        // AP list
        ListView {
            id: apList
            width: parent.width
            height: 280
            clip: true
            spacing: 4
            topMargin: 8
            bottomMargin: 8

            // ScriptModel launders the JS-array-of-QObjects safely (a raw
            // array crashes delegate incubation when a network object is freed
            // mid-update) and diffs incrementally, so reassigning the snapshot
            // does not recreate every delegate or reset scroll.
            model: ScriptModel {
                values: root.networkSnapshot
            }

            delegate: WifiNetworkRow {
                required property var modelData
                network: modelData
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
