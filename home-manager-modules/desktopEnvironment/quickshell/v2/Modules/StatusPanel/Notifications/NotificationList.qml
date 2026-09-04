import qs
import QtQuick
import QtQuick.Layouts
import "../../../Components"

Rectangle {
    id: root

    color: Theme.mantle
    radius: Theme.innerRadius
    clip: true

    ColumnLayout {
        anchors {
            fill: parent
            margins: 6
        }
        spacing: 6

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            NotificationListView {
                id: listView
                anchors.fill: parent
                groups: Notifications.groups
                visible: Notifications.count > 0
            }

            // The Flickable inside NotificationListView accepts all wheel events,
            // preventing them from reaching any WheelHandler on or below it.
            // This overlay sits above the Flickable in z-order and intercepts
            // horizontal scroll before the Flickable can consume it.
            // acceptedButtons: Qt.NoButton ensures clicks and drags pass through.
            MouseArea {
                anchors.fill: listView
                visible: listView.visible
                z: 1
                acceptedButtons: Qt.NoButton
                onWheel: wheel => {
                    const dx = wheel.pixelDelta.x !== 0
                        ? wheel.pixelDelta.x
                        : wheel.angleDelta.x / 4
                    const dy = wheel.pixelDelta.y !== 0
                        ? wheel.pixelDelta.y
                        : wheel.angleDelta.y / 4

                    if (Math.abs(dx) <= Math.abs(dy)) {
                        wheel.accepted = false
                        return
                    }

                    const group = listView.groupAt(wheel.y + listView.contentY)
                    if (!group) {
                        wheel.accepted = false
                        return
                    }

                    if (group.expanded) {
                        const item = group.itemAt(wheel.y + listView.contentY - group.y)
                        if (item)
                            item.applySwipeDelta(-dx)
                        else
                            group.applySwipeDelta(-dx)
                    } else {
                        group.applySwipeDelta(-dx)
                    }
                    wheel.accepted = true
                }
            }

            Column {
                visible: Notifications.count === 0
                anchors.centerIn: parent
                spacing: 4

                MaterialSymbol {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 36
                    height: 36
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    iconSize: 30
                    color: Theme.overlay0
                    text: Notifications.available ? "notifications_none" : "notifications_off"
                }

                StyledText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Theme.overlay1
                    text: Notifications.available ? "Nothing" : "Notification service unavailable"
                }
            }
        }

        NotificationFooter {
            Layout.fillWidth: true
        }
    }
}
