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

    visible: Notifications.dnd || Notifications.count > 0
    implicitWidth: Theme.fontL
    implicitHeight: Theme.fontL

    MaterialSymbol {
        id: icon
        anchors.centerIn: parent
        text: Notifications.dnd ? "notifications_paused" : (root.unreadCount > 0 && root.indicatorType === NotificationStatus.Dot ? "notifications_unread" : "notifications")
        iconSize: Theme.fontL
        color: Notifications.dnd ? Theme.yellow : Theme.accentText
    }

    Rectangle {
        id: badge
        visible: root.indicatorType === NotificationStatus.Number && !Notifications.dnd && root.unreadCount > 0
        anchors {
            top: parent.top
            right: parent.right
            topMargin: 7
            rightMargin: -7
        }
        width: Math.max(height, countText.implicitWidth + 4)
        height: 12
        radius: height / 2
        color: Theme.accentText

        StyledText {
            id: countText

            anchors.centerIn: parent
            text: root.unreadCount > 99 ? "99+" : root.unreadCount
            color: Theme.crust
            font.pixelSize: 9
            font.weight: Theme.weightBold
        }
    }
}
