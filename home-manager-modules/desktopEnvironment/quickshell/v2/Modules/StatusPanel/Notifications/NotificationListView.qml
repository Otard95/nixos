import qs
import QtQuick
import QtQuick.Controls
import Quickshell
import "../../../Sources/Notifications" as NotificationTypes

// The list owns vertical position, computed purely from the reactive model
// order and each group's published settled height — never from reading a
// sibling delegate's rendered height. Each group reports its instant final
// height into groupHeights (keyed by groupId); every y is a reactive binding
// on that map plus Notifications.groups, so a resize or reorder reliably
// re-evaluates every affected position. A Behavior on y, matched in duration
// and easing to the group card's own height animation, keeps neighbours moving
// in lockstep with a growing or shrinking group.
Flickable {
    id: root

    required property list<NotificationTypes.NotificationGroup> groups
    property bool popup: false
    property var expandedGroups: ({})
    property var groupHeights: ({})
    property string activeGroupDragId: ""
    property int activeGroupDragIndex: -1
    property real activeGroupDragOffset: 0
    property bool activeGroupPassedThreshold: false
    readonly property real chainDistanceFactor: 0.15
    readonly property int spacing: 6
    readonly property int animationDuration: 200

    function groupExpanded(groupId: string): bool {
        return expandedGroups[groupId] === true
    }

    function setGroupExpanded(groupId: string, expanded: bool): void {
        const next = Object.assign({}, expandedGroups)
        if (expanded)
            next[groupId] = true
        else
            delete next[groupId]
        expandedGroups = next
    }

    function reportHeight(groupId: string, height: real): void {
        if (groupHeights[groupId] === height)
            return
        groupHeights = Object.assign({}, groupHeights, {
            [groupId]: height
        })
    }

    function heightOf(group): real {
        return groupHeights[group.groupId] ?? 80
    }

    function reportGroupDrag(groupId: string, index: int, active: bool,
                             dragOffset: real, passedThreshold: bool): void {
        if (!active) {
            if (activeGroupDragId === groupId) {
                activeGroupDragId = ""
                activeGroupDragIndex = -1
                activeGroupDragOffset = 0
                activeGroupPassedThreshold = false
            }
            return
        }

        activeGroupDragId = groupId
        activeGroupDragIndex = index
        activeGroupDragOffset = dragOffset
        activeGroupPassedThreshold = passedThreshold
    }

    function chainOffsetFor(groupId: string, index: int): real {
        if (activeGroupDragId === "" || activeGroupDragId === groupId
                || activeGroupPassedThreshold)
            return 0
        const distance = Math.abs(index - activeGroupDragIndex)
        return activeGroupDragOffset * Math.pow(chainDistanceFactor, distance)
    }

    function offsetFor(index: int): real {
        let offset = 0
        for (let i = 0; i < index; i++)
            offset += heightOf(root.groups[i]) + spacing
        return offset
    }

    clip: true
    boundsBehavior: Flickable.StopAtBounds
    contentWidth: width
    contentHeight: {
        let total = 0
        for (let i = 0; i < root.groups.length; i++)
            total += heightOf(root.groups[i]) + (i > 0 ? spacing : 0)
        return total
    }

    Repeater {
        id: repeater
        model: ScriptModel {
            values: root.groups.slice()
        }

        delegate: NotificationGroup {
            id: groupDelegate
            required property int index
            required property NotificationTypes.NotificationGroup modelData

            property bool positionReady: false

            width: root.width - (scrollBar.visible ? 8 : 0)
            group: modelData
            popup: root.popup
            chainOffset: root.chainOffsetFor(modelData.groupId, index)
            y: root.offsetFor(index)
            opacity: 0

            Behavior on y {
                enabled: groupDelegate.positionReady
                NumberAnimation {
                    duration: root.animationDuration
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on opacity {
                enabled: groupDelegate.positionReady
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }

            onExpandedChanged: root.setGroupExpanded(modelData.groupId, expanded)
            onSettledHeightChanged: root.reportHeight(modelData.groupId, settledHeight)
            onDraggingChanged: root.reportGroupDrag(
                modelData.groupId, index, dragging, dragOffset,
                passedThreshold)
            onDragOffsetChanged: {
                if (dragging)
                    root.reportGroupDrag(modelData.groupId, index, true,
                                         dragOffset, passedThreshold)
            }
            onPassedThresholdChanged: {
                if (dragging)
                    root.reportGroupDrag(modelData.groupId, index, true,
                                         dragOffset, passedThreshold)
            }
            Component.onCompleted: {
                expanded = root.groupExpanded(modelData.groupId)
                root.reportHeight(modelData.groupId, settledHeight)
                opacity = 1
                positionReady = true
            }
        }
    }

    function groupAt(contentY: real): Item {
        for (let i = 0; i < repeater.count; i++) {
            const item = repeater.itemAt(i)
            if (!item) continue
            if (contentY >= item.y && contentY < item.y + item.settledHeight)
                return item
        }
        return null
    }

    ScrollBar.vertical: ScrollBar {
        id: scrollBar
        policy: ScrollBar.AsNeeded
    }
}
