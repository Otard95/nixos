import QtQuick
import Quickshell
import Quickshell.Io

NotificationBackend {
    id: root

    available: true

    property int nextId: 1
    property var unreadIds: ({})
    property var popupDeadlines: ({})
    property var popupRemaining: ({})
    property var popupHovered: ({})

    onPopupInhibitedChanged: {
        if (popupInhibited)
            hideAllPopups()
    }
    onDndChangeRequested: enabled => {
        dnd = enabled
        if (enabled)
            hideNonCriticalPopups()
    }
    onMarkAllReadRequested: {
        unreadIds = ({})
        unreadCount = 0
        notifications.filter(record => record.isTransient)
            .forEach(record => remove(record.notificationId))
    }
    onDismissRequested: notificationId => remove(notificationId)
    onDismissAllRequested: {
        notifications = []
        popupNotificationIds = []
        unreadIds = ({})
        unreadCount = 0
        popupDeadlines = ({})
        popupRemaining = ({})
        popupHovered = ({})
    }
    onActionInvocationRequested: (notificationId, actionId) => {
        console.info("Fixture notification action invoked:", notificationId, actionId)
        hidePopup(notificationId)
    }

    function urgencyValue(value): int {
        if (value === "low" || value === NotificationRecord.Low)
            return NotificationRecord.Low
        if (value === "critical" || value === NotificationRecord.Critical)
            return NotificationRecord.Critical
        return NotificationRecord.Normal
    }

    function findRecord(notificationId: string): NotificationRecord {
        return notifications.find(record => record.notificationId === notificationId) ?? null
    }

    function copyActions(record: NotificationRecord, rawActions): void {
        const previous = record.actions.slice()
        record.actions = (rawActions ?? []).map(rawAction =>
            actionComponent.createObject(record, {
                identifier: String(rawAction.id ?? rawAction.identifier ?? ""),
                text: String(rawAction.label ?? rawAction.text ?? "")
            }))
        previous.forEach(action => action.destroy())
    }

    function updateRecord(record: NotificationRecord, raw): void {
        record.appName = String(raw.appName ?? "Fixture")
        record.appIcon = String(raw.icon ?? raw.appIcon ?? "")
        record.desktopEntry = String(raw.desktopEntry ?? "")
        record.category = String(raw.category ?? "")
        record.summary = String(raw.summary ?? "Fixture notification")
        record.body = String(raw.body ?? "")
        record.image = String(raw.image ?? "")
        record.urgency = urgencyValue(raw.urgency)
        record.isTransient = raw.transient === true
        record.resident = raw.resident === true
        record.dismissible = raw.dismissible !== false
        copyActions(record, raw.actions)
    }

    function receive(raw): string {
        const replacementId = String(raw.replacesId ?? "")
        let record = replacementId === "" ? null : findRecord(replacementId)
        if (record !== null) {
            updateRecord(record, raw)
            notificationUpdated(record.notificationId)
            if (popupNotificationIds.includes(record.notificationId)) {
                const critical = record.urgency === NotificationRecord.Critical
                const low = record.urgency === NotificationRecord.Low
                if (low || popupInhibited || (dnd && !critical))
                    hidePopup(record.notificationId)
                else
                    schedulePopup(record, Number(raw.timeout ?? -1))
            }
            return record.notificationId
        }

        const notificationId = String(raw.id ?? nextId++)
        if (findRecord(notificationId) !== null)
            return receive(Object.assign({}, raw, { replacesId: notificationId }))

        record = recordComponent.createObject(root, {
            notificationId: notificationId,
            appName: String(raw.appName ?? "Fixture"),
            time: Date.now()
        })
        updateRecord(record, raw)
        notifications = [record, ...notifications]
        unreadIds = Object.assign({}, unreadIds, { [notificationId]: true })
        unreadCount = Object.keys(unreadIds).length

        const critical = record.urgency === NotificationRecord.Critical
        const low = record.urgency === NotificationRecord.Low
        if (!popupInhibited && !low && (!dnd || critical)
                && raw.popup !== false) {
            popupNotificationIds = [notificationId, ...popupNotificationIds]
            schedulePopup(record, Number(raw.timeout ?? -1))
        }
        return notificationId
    }

    function receiveJson(payload: string): string {
        try {
            return receive(JSON.parse(payload))
        } catch (error) {
            console.warn("Invalid notification fixture JSON:", error)
            return ""
        }
    }

    function schedulePopup(record: NotificationRecord, requestedTimeout: real): void {
        const timeout = requestedTimeout < 0 ? 5000 : requestedTimeout
        const deadlines = Object.assign({}, popupDeadlines)
        const remaining = Object.assign({}, popupRemaining)
        delete deadlines[record.notificationId]
        delete remaining[record.notificationId]
        if (timeout > 0 && record.urgency !== NotificationRecord.Critical)
            deadlines[record.notificationId] = Date.now() + timeout
        popupDeadlines = deadlines
        popupRemaining = remaining
    }

    function setPopupHovered(notificationId: string, hovered: bool): void {
        if (popupHovered[notificationId] === hovered)
            return
        const nextHovered = Object.assign({}, popupHovered, { [notificationId]: hovered })
        const deadlines = Object.assign({}, popupDeadlines)
        const remaining = Object.assign({}, popupRemaining)
        if (hovered && deadlines[notificationId] !== undefined) {
            remaining[notificationId] = Math.max(0, deadlines[notificationId] - Date.now())
            delete deadlines[notificationId]
        } else if (!hovered && remaining[notificationId] !== undefined) {
            deadlines[notificationId] = Date.now() + remaining[notificationId]
            delete remaining[notificationId]
        }
        popupHovered = nextHovered
        popupDeadlines = deadlines
        popupRemaining = remaining
    }

    function hidePopup(notificationId: string): void {
        popupNotificationIds = popupNotificationIds.filter(id => id !== notificationId)
        const deadlines = Object.assign({}, popupDeadlines)
        const remaining = Object.assign({}, popupRemaining)
        const hovered = Object.assign({}, popupHovered)
        delete deadlines[notificationId]
        delete remaining[notificationId]
        delete hovered[notificationId]
        popupDeadlines = deadlines
        popupRemaining = remaining
        popupHovered = hovered
    }

    function hideNonCriticalPopups(): void {
        popupNotificationIds.slice().forEach(notificationId => {
            const record = findRecord(notificationId)
            if (record?.urgency !== NotificationRecord.Critical)
                hidePopup(notificationId)
        })
    }

    function hideAllPopups(): void {
        popupNotificationIds = []
        popupDeadlines = ({})
        popupRemaining = ({})
        popupHovered = ({})
    }

    function remove(notificationId: string): void {
        const record = findRecord(notificationId)
        if (record === null)
            return
        hidePopup(notificationId)
        notifications = notifications.filter(candidate => candidate !== record)
        const nextUnread = Object.assign({}, unreadIds)
        delete nextUnread[notificationId]
        unreadIds = nextUnread
        unreadCount = Object.keys(nextUnread).length
        record.destroy()
    }

    Timer {
        interval: 100
        repeat: true
        running: root.popupNotificationIds.length > 0
        onTriggered: {
            const now = Date.now()
            Object.keys(root.popupDeadlines).forEach(notificationId => {
                if (root.popupDeadlines[notificationId] > now)
                    return
                root.hidePopup(notificationId)
            })
        }
    }

    IpcHandler {
        target: "notificationFixtures"

        function receive(payload: string): string {
            return root.receiveJson(payload)
        }

        function close(notificationId: string): void {
            root.remove(notificationId)
        }

        function clear(): void {
            root.dismissAll()
        }

        function setDnd(enabled: bool): void {
            root.setDnd(enabled)
        }

        function markRead(): void {
            root.markAllRead()
        }

        function snapshot(): string {
            return JSON.stringify({
                dnd: root.dnd,
                popupInhibited: root.popupInhibited,
                unreadCount: root.unreadCount,
                notificationIds: root.notifications.map(record =>
                    record.notificationId),
                transientIds: root.notifications
                    .filter(record => record.isTransient)
                    .map(record => record.notificationId),
                popupIds: root.popupNotificationIds
            })
        }
    }

    Component {
        id: recordComponent
        NotificationRecord {}
    }

    Component {
        id: actionComponent
        NotificationAction {}
    }
}
