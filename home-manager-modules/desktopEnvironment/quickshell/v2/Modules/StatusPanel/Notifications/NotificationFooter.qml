import qs
import QtQuick
import QtQuick.Layouts
import "../../../Components"

Rectangle {
    id: root

    implicitHeight: 36
    radius: height / 2
    color: Theme.base

    RowLayout {
        anchors.fill: parent
        spacing: 0

        FooterButton {
            icon: Notifications.dnd ? "notifications_paused" : "notifications_active"
            color: Notifications.dnd ? Theme.yellow : Theme.text
            enabled: Notifications.available
            onClicked: Notifications.toggleDnd()
        }

        StyledText {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            color: Theme.subtext0
            text: Notifications.count === 1
                ? "1 notification"
                : Notifications.count + " notifications"
        }

        FooterButton {
            icon: "clear_all"
            color: Theme.text
            enabled: Notifications.count > 0
            onClicked: Notifications.dismissAll()
        }
    }

    component FooterButton: Item {
        required property string icon
        required property color color
        property bool enabled: true
        signal clicked

        Layout.preferredWidth: 42
        Layout.fillHeight: true
        opacity: enabled ? 1 : 0.35

        MaterialSymbol {
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            iconSize: 19
            color: parent.color
            text: parent.icon
        }

        MouseArea {
            anchors.fill: parent
            enabled: parent.enabled
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: parent.clicked()
        }
    }
}
