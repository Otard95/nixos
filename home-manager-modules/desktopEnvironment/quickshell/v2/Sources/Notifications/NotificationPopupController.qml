import QtQuick
import Quickshell

Scope {
    id: root

    property int defaultTimeout: 5000
    property list<string> notificationIds: []
    property var deadlines: ({})
    property var remaining: ({})
    property var hovered: ({})

    signal timeoutRequested(notificationId: string)

    function effectiveTimeout(requestedTimeout: real, critical: bool): real {
        if (critical)
            return 0
        return requestedTimeout < 0 ? defaultTimeout : requestedTimeout
    }

    function show(notificationId: string, requestedTimeout: real,
                  critical: bool): void {
        if (!notificationIds.includes(notificationId))
            notificationIds = [notificationId, ...notificationIds]
        schedule(notificationId,
            effectiveTimeout(requestedTimeout, critical))
    }

    function restartVisible(notificationId: string, requestedTimeout: real,
                            critical: bool): void {
        if (!notificationIds.includes(notificationId))
            return
        schedule(notificationId,
            effectiveTimeout(requestedTimeout, critical))
    }

    function schedule(notificationId: string, timeout: real): void {
        delete deadlines[notificationId]
        delete remaining[notificationId]

        if (timeout > 0) {
            if (hovered[notificationId] === true)
                remaining[notificationId] = timeout
            else
                deadlines[notificationId] = Date.now() + timeout
        }

        rescheduleTimer()
    }

    function setHovered(notificationId: string, isHovered: bool): void {
        if (!notificationIds.includes(notificationId)
                || hovered[notificationId] === isHovered)
            return

        if (isHovered) {
            hovered[notificationId] = true
            if (deadlines[notificationId] !== undefined) {
                remaining[notificationId] = Math.max(1,
                    deadlines[notificationId] - Date.now())
                delete deadlines[notificationId]
            }
        } else {
            delete hovered[notificationId]
            if (remaining[notificationId] !== undefined) {
                deadlines[notificationId] = Date.now()
                    + remaining[notificationId]
                delete remaining[notificationId]
            }
        }

        rescheduleTimer()
    }

    function hide(notificationId: string): void {
        if (notificationIds.includes(notificationId))
            notificationIds = notificationIds.filter(id =>
                id !== notificationId)
        clearSchedule(notificationId)
    }

    function hideAll(): void {
        notificationIds = []
        deadlines = ({})
        remaining = ({})
        hovered = ({})
        deadlineTimer.stop()
    }

    function clearSchedule(notificationId: string): void {
        delete deadlines[notificationId]
        delete remaining[notificationId]
        delete hovered[notificationId]
        rescheduleTimer()
    }

    function rescheduleTimer(): void {
        const scheduledIds = Object.keys(deadlines)
        if (scheduledIds.length === 0) {
            deadlineTimer.stop()
            return
        }

        const nextDeadline = scheduledIds.reduce((earliest, notificationId) =>
            Math.min(earliest, deadlines[notificationId]), Infinity)
        deadlineTimer.interval = Math.max(1, nextDeadline - Date.now())
        deadlineTimer.restart()
    }

    function expireDue(): void {
        const now = Date.now()
        const dueIds = Object.keys(deadlines).filter(notificationId =>
            deadlines[notificationId] <= now)
        if (dueIds.length === 0) {
            rescheduleTimer()
            return
        }

        dueIds.forEach(notificationId => delete deadlines[notificationId])
        dueIds.forEach(notificationId => timeoutRequested(notificationId))
        rescheduleTimer()
    }

    Timer {
        id: deadlineTimer
        repeat: false
        onTriggered: root.expireDue()
    }
}
