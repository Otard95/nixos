import qs
import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../../Components"
import "../../../Sources/Notifications" as NotificationTypes

Rectangle {
    id: root

    required property NotificationTypes.NotificationGroup group
    property bool popup: false
    property bool expanded: false
    property bool animationReady: false

    readonly property int urgencyLevel: {
        let highest = 0
        for (const entry of group.notifications) {
            if (entry && entry.urgency > highest)
                highest = entry.urgency
        }
        return highest
    }
    readonly property color popupTint:
        urgencyLevel === 2 ? Theme.red : Theme.accent

    readonly property real dismissThreshold: 70
    readonly property real detachThreshold: 100
    readonly property real dismissOvershoot: 20
    readonly property real attractionStrength: 32
    readonly property int dragSmoothingDuration: 50
    property real swipeOffset: 0
    property real dragOffset: 0
    property real chainOffset: 0
    property bool dragging: false
    property bool passedThreshold: false
    property string activeItemDragId: ""
    property int activeItemDragIndex: -1
    property real activeItemDragOffset: 0
    property bool activeItemPassedThreshold: false
    readonly property real chainDistanceFactor: 0.15

    // Instant, non-animated final height. The layout container positions groups
    // from this so neighbours reserve final space immediately; the card's own
    // visual height animates toward it separately.
    readonly property real settledHeight: expanded
        ? groupContent.implicitHeight + 16
        : Math.min(80, groupContent.implicitHeight + 16)

    implicitHeight: settledHeight
    radius: Theme.innerRadius

    Behavior on implicitHeight {
        enabled: root.animationReady
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }
    color: Theme.base
    clip: true
    border.width: popup ? 2 : 0
    border.color: popup ? Theme.alpha(popupTint, 0.85) : "transparent"
    transform: Translate { x: root.dragOffset + root.chainOffset }

    Behavior on chainOffset {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    Behavior on dragOffset {
        enabled: !dismissAnimation.running
        NumberAnimation {
            duration: root.dragging ? root.dragSmoothingDuration : 200
            easing.type: Easing.OutCubic
        }
    }

    NumberAnimation {
        id: dismissAnimation
        target: root
        property: "dragOffset"
        duration: 200
        easing.type: Easing.OutCubic
        onFinished: Notifications.dismissMany(
            root.group.notifications.map(entry => entry.notificationId))
    }

    HoverHandler {
        id: popupHover
        enabled: root.popup
        onHoveredChanged: Notifications.setPopupGroupHovered(
            root.group.notifications.map(entry => entry.notificationId), hovered)
    }

    DragHandler {
        enabled: !root.expanded && !dismissAnimation.running
        target: null
        xAxis.enabled: true
        yAxis.enabled: false
        onActiveChanged: {
            if (active)
                root.beginSwipe()
            else
                root.finishSwipe()
        }
        onTranslationChanged: {
            if (active)
                root.setSwipeOffset(translation.x)
        }
    }

    function beginSwipe(): void {
        gestureEndTimer.stop()
        root.dragging = true
    }

    function applySwipeDelta(delta: real): void {
        if (dismissAnimation.running)
            return
        root.beginSwipe()
        root.setSwipeOffset(root.swipeOffset + delta)
        gestureEndTimer.restart()
    }

    function setSwipeOffset(offset: real): void {
        root.swipeOffset = offset
        const distance = Math.abs(offset)
        if (!root.passedThreshold && distance >= root.detachThreshold)
            root.passedThreshold = true
        else if (root.passedThreshold && distance <= root.dismissThreshold)
            root.passedThreshold = false
        root.dragOffset = root.passedThreshold ? offset : root.visualOffset(offset)
    }

    // A static curve gives spring-like resistance without time-dependent state.
    function visualOffset(offset: real): real {
        const distance = Math.abs(offset)
        const direction = offset < 0 ? -1 : 1
        const attraction = root.attractionStrength
            * (1 - Math.exp(-distance / root.attractionStrength))
        return direction * Math.max(0, distance - attraction)
    }

    function finishSwipe(): void {
        root.dragging = false
        if (root.passedThreshold) {
            root.commitDismiss()
        } else {
            root.swipeOffset = 0
            root.dragOffset = 0
        }
    }

    function reportItemDrag(notificationId: string, index: int, active: bool,
                            dragOffset: real, passedThreshold: bool): void {
        if (!active) {
            if (activeItemDragId === notificationId) {
                activeItemDragId = ""
                activeItemDragIndex = -1
                activeItemDragOffset = 0
                activeItemPassedThreshold = false
            }
            return
        }

        activeItemDragId = notificationId
        activeItemDragIndex = index
        activeItemDragOffset = dragOffset
        activeItemPassedThreshold = passedThreshold
    }

    function itemChainOffset(notificationId: string, index: int): real {
        if (activeItemDragId === "" || activeItemDragId === notificationId
                || activeItemPassedThreshold)
            return 0
        const distance = Math.abs(index - activeItemDragIndex)
        return activeItemDragOffset * Math.pow(chainDistanceFactor, distance)
    }

    function itemAt(groupLocalY: real): Item {
        for (let i = 0; i < notificationsRepeater.count; i++) {
            const item = notificationsRepeater.itemAt(i)
            if (!item) continue
            const top = item.mapToItem(root, 0, 0).y
            if (groupLocalY >= top && groupLocalY < top + item.height)
                return item
        }
        return null
    }

    Timer {
        id: gestureEndTimer
        interval: 100
        onTriggered: root.finishSwipe()
    }

    ColumnLayout {
        id: groupContent
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 8
        }
        spacing: 3

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            NotificationAppIcon {
                Layout.alignment: Qt.AlignTop
                appIcon: root.group.appIcon
                appName: root.group.appName
                category: root.group.notifications[0]?.category ?? ""
                image: root.group.notifications.length === 1
                    ? root.group.notifications[0]?.image ?? ""
                    : ""
                urgency: root.group.notifications[0]?.urgency ?? 1
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                spacing: 2

                RowLayout {
                    id: groupHeader

                    Layout.fillWidth: true
                    spacing: 5

                    DragHandler {
                        enabled: root.expanded && !dismissAnimation.running
                        target: null
                        xAxis.enabled: true
                        yAxis.enabled: false
                        onActiveChanged: {
                            if (active)
                                root.beginSwipe()
                            else
                                root.finishSwipe()
                        }
                        onTranslationChanged: {
                            if (active)
                                root.setSwipeOffset(translation.x)
                        }
                    }

                    StyledText {
                        Layout.fillWidth: true
                        color: Theme.subtext0
                        font.pixelSize: Theme.fontS
                        elide: Text.ElideRight
                        text: root.group.appName
                    }

                    StyledText {
                        color: Theme.overlay1
                        font.pixelSize: Theme.fontS
                        text: root.friendlyTime(root.group.time, Time.date)
                    }

                    Rectangle {
                        implicitWidth: countRow.implicitWidth + 24
                        implicitHeight: 20
                        radius: height / 2
                        color: expandMouse.containsMouse ? Theme.surface1 : Theme.surface0

                        Row {
                            id: countRow
                            anchors.centerIn: parent
                            spacing: 1

                            StyledText {
                                visible: root.group.notifications.length > 1
                                color: Theme.subtext0
                                text: root.group.notifications.length
                            }

                            MaterialSymbol {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 15
                                height: 15
                                verticalAlignment: Text.AlignVCenter
                                iconSize: 15
                                color: Theme.subtext0
                                text: root.expanded ? "expand_less" : "expand_more"
                            }
                        }

                        MouseArea {
                            id: expandMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.expanded = !root.expanded
                        }
                    }
                }

                // A layout-driven Repeater, not a ListView. Item height depends
                // on wrapped body text, whose height settles after the delegate
                // width is known. A ListView positions delegates from a height
                // read too early and does not reliably push the item below down
                // when the text grows, so expanded items overlap. A ColumnLayout
                // recomputes every position synchronously on any height change.
                ColumnLayout {
                    id: notificationsList

                    Layout.fillWidth: true
                    spacing: root.expanded ? 5 : 3

                    Repeater {
                        id: notificationsRepeater

                        model: ScriptModel {
                            values: root.expanded
                                ? root.group.notifications.slice()
                                : root.group.notifications.slice(0, 2)
                        }

                        delegate: NotificationItem {
                            required property int index
                            required property NotificationTypes.NotificationEntry modelData

                            Layout.fillWidth: true
                            Layout.preferredHeight: implicitHeight
                            notification: modelData
                            expanded: root.expanded
                            compact: !root.expanded
                            chainOffset: modelData === null
                                ? 0
                                : root.itemChainOffset(modelData.notificationId, index)
                            showSummary: true
                            showImage: root.group.notifications.length > 1
                            preview: !root.expanded && index === 1
                            opacity: preview && root.group.notifications.length > 2 ? 0.5 : 1

                            onDraggingChanged: {
                                if (modelData !== null) {
                                    root.reportItemDrag(modelData.notificationId,
                                        index, dragging, dragOffset,
                                        passedThreshold)
                                }
                            }
                            onDragOffsetChanged: {
                                if (dragging && modelData !== null) {
                                    root.reportItemDrag(modelData.notificationId,
                                        index, true, dragOffset, passedThreshold)
                                }
                            }
                            onPassedThresholdChanged: {
                                if (dragging && modelData !== null) {
                                    root.reportItemDrag(modelData.notificationId,
                                        index, true, dragOffset, passedThreshold)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton | Qt.MiddleButton
        onClicked: mouse => {
            if (mouse.button === Qt.MiddleButton)
                Notifications.dismissMany(
                    root.group.notifications.map(entry => entry.notificationId))
            else
                root.expanded = !root.expanded
        }
    }

    Component.onCompleted: animationReady = true
    Component.onDestruction: {
        if (root.popup && popupHover.hovered)
            Notifications.setPopupGroupHovered(
                root.group.notifications.map(entry => entry.notificationId), false)
    }

    function commitDismiss(): void {
        gestureEndTimer.stop()
        const dir = root.swipeOffset < 0 ? -1 : 1
        dismissAnimation.to = dir * (root.width + root.dismissOvershoot)
        dismissAnimation.start()
    }

    function friendlyTime(timestamp: double, now: date): string {
        if (timestamp <= 0)
            return ""

        const notificationDate = new Date(timestamp)
        const today = new Date(now.getFullYear(), now.getMonth(), now.getDate())
        const notificationDay = new Date(
            notificationDate.getFullYear(),
            notificationDate.getMonth(),
            notificationDate.getDate())
        const elapsed = now.getTime() - timestamp
        const dayDifference = Math.round(
            (today.getTime() - notificationDay.getTime()) / 86400000)

        if (dayDifference === 0) {
            if (elapsed < 60000)
                return "Now"
            if (elapsed < 3600000)
                return Math.floor(elapsed / 60000) + "m"
            return Math.floor(elapsed / 3600000) + "h"
        }
        if (dayDifference === 1)
            return "Yesterday"
        if (notificationDate.getFullYear() === now.getFullYear())
            return notificationDate.toLocaleDateString(Qt.locale(), "MMMM d")
        return notificationDate.toLocaleDateString(Qt.locale(), "MMMM d, yyyy")
    }
}
