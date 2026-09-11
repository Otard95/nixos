import qs
import QtQuick

// Floating dialog that overlays the status panel. Owns the scrim, placement,
// sizing, and in/out animation so each concrete dialog only supplies content.
// Place one inside the panel content, fill the parent, and set `open`.
Item {
    id: root

    property bool open: false
    default property alias contentData: contentHost.data

    property real dialogWidth: 400
    // 0 derives the height from the content; set a value to fix it.
    property real dialogHeight: 0
    property real contentPadding: 18
    property real slideDistance: 40
    property color cardColor: Theme.mix(Theme.mantle, Theme.accent, 0.03)

    signal dismissed

    function close(): void {
        root.open = false;
    }

    anchors.fill: parent
    z: 100
    // Keep the node alive until the close animation finishes.
    visible: open || scrim.opacity > 0

    // Escape is handled centrally by the panel so it can prioritise the top
    // layer (password over dialog over panel). No per-dialog focus grab here.

    Rectangle {
        id: scrim

        anchors.fill: parent
        color: Theme.alpha(Theme.crust, 0.6)
        opacity: root.open ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.dismissed()
        }
    }

    Rectangle {
        id: card

        anchors.horizontalCenter: parent.horizontalCenter
        width: root.dialogWidth
        height: root.dialogHeight > 0 ? root.dialogHeight : contentHost.implicitHeight + root.contentPadding * 2

        color: root.cardColor
        radius: Theme.statusPanelRadius

        readonly property real restY: (root.height - height) / 2
        y: root.open ? restY : restY - root.slideDistance
        opacity: root.open ? 1 : 0

        Behavior on y {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }

        // Swallow clicks so they do not reach the scrim and dismiss.
        MouseArea {
            anchors.fill: parent
        }

        Item {
            id: contentHost

            x: root.contentPadding
            y: root.contentPadding
            width: card.width - root.contentPadding * 2
            // childrenRect.height reflects the actual laid-out children,
            // so the card can size itself from this rather than the other way around.
            implicitHeight: childrenRect.height
        }
    }
}
