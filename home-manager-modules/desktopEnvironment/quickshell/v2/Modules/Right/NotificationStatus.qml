import qs
import QtQuick
import "../../Components"

Item {
    id: root

    enum IndicatorType {
        Number,
        Dot
    }

    property int indicatorType: NotificationStatus.Number
    readonly property int unreadCount: Notifications.unreadCount

    visible: Notifications.dnd || unreadCount > 0
    implicitWidth: visible ? 24 : 0
    implicitHeight: Theme.fontL + 4

    MaterialSymbol {
        anchors {
            left: parent.left
            bottom: parent.bottom
        }
        text: Notifications.dnd ? "notifications_paused" : "notifications"
        iconSize: Theme.fontL
        color: Notifications.dnd ? Theme.yellow : Theme.accentText
    }

    Rectangle {
        visible: !Notifications.dnd && root.unreadCount > 0
        anchors {
            top: parent.top
            right: parent.right
        }
        width: root.indicatorType === NotificationStatus.Dot
            ? height
            : Math.max(height, countText.implicitWidth + 4)
        height: 12
        radius: height / 2
        color: Theme.accentText

        StyledText {
            id: countText

            visible: root.indicatorType === NotificationStatus.Number
            anchors.centerIn: parent
            text: root.unreadCount > 99 ? "99+" : root.unreadCount
            color: Theme.crust
            font.pixelSize: 9
            font.weight: Theme.weightBold
        }
    }
}
