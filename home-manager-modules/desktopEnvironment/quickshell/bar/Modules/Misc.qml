import qs
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pipewire

Item {
    id: root

    // Pull in 6px from each side to sit tighter against neighbouring pills.
    readonly property int sideInset: 6
    implicitWidth:  row.implicitWidth - sideInset * 2
    implicitHeight: Theme.barHeight - 10

    required property var panelWindow

    // ── Idle inhibitor ────────────────────────────────────────────────
    property bool idleInhibit: false

    IdleInhibitor {
        window:  root.panelWindow
        enabled: root.idleInhibit
    }

    // ── DND — via Notifications singleton ────────────────────────────
    readonly property bool dnd: Notifications.dnd

    // ── Mic in use ────────────────────────────────────────────────────
    PwNodeLinkTracker {
        id: micTracker
        node: Pipewire.defaultAudioSource
    }

    // Only count links where the target is a software stream (an app
    // actually recording), not hardware monitor/loopback connections.
    // Exclude known peak meter apps that connect to the mic just for
    // level display, not actual recording.
    // Exclude peak meter apps that connect to the mic just for level
    // display — they aren't actually recording.
    readonly property var micMeterApps: ["PulseAudio Volume Control", "pavucontrol"]

    readonly property bool micInUse: {
        for (const lg of micTracker.linkGroups) {
            if (!lg.target?.isStream) continue
            if (micMeterApps.some(n => lg.target.name.includes(n))) continue
            return true
        }
        return false
    }

    // ── Layout ────────────────────────────────────────────────────────
    Row {
        id: row
        anchors.centerIn: parent
        // Offset outward so the row is centred despite the reduced implicitWidth.
        x: (parent.width - row.implicitWidth) / 2
        y: (parent.height - row.implicitHeight) / 2
        spacing: 2

            // Mic in use indicator
            Text {
                visible: root.micInUse
                anchors.verticalCenter: parent.verticalCenter
                font.family: Theme.font
                font.pixelSize: Theme.fontMd
                color: Theme.red
                text: "󰍬"
            }

            // Mako DND toggle
            Text {
                anchors.verticalCenter: parent.verticalCenter
                font.family: Theme.font
                font.pixelSize: Theme.fontMd
                color: root.dnd ? Theme.yellow : Theme.subtext1
                text: root.dnd ? "󰂛" : "󰂚"

                MouseArea {
                    anchors.fill: parent
                    onClicked: Notifications.toggle()
                }
            }

            // Idle inhibitor toggle
            Text {
                anchors.verticalCenter: parent.verticalCenter
                font.family: Theme.font
                font.pixelSize: Theme.fontMd
                color: root.idleInhibit ? Theme.yellow : Theme.subtext1
                text: root.idleInhibit ? "󰈈" : "󰈉"

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.idleInhibit = !root.idleInhibit
                }
            }
    }
}
