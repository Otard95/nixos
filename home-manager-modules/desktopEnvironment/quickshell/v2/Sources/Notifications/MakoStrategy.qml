import QtQuick
import Quickshell
import Quickshell.Io

NotificationBackend {
    id: root

    property bool debugTimeFixtures: false
    property bool initialized: false
    property var firstSeen: ({})
    property var unreadIds: ({})
    property var commandQueue: []

    onDebugTimeFixturesChanged: refresh()
    onRefreshRequested: refreshProcesses()
    onDndChangeRequested: enabled => {
        if (enabled !== dnd)
            run(["makoctl", "mode", enabled ? "-a" : "-r", "do-not-disturb"])
    }
    onMarkAllReadRequested: {
        unreadIds = ({})
        unreadCount = 0
    }
    onDismissRequested: notificationId => {
        run(["makoctl", "dismiss", "-n", notificationId])
    }
    onDismissAllRequested: run(["makoctl", "dismiss", "--all"])
    onActionInvocationRequested: (notificationId, actionId) => {
        run(["makoctl", "invoke", "-n", notificationId, actionId])
    }

    function refreshProcesses(): void {
        if (!listProc.running)
            listProc.running = true
        if (!modeProc.running)
            modeProc.running = true
    }

    function run(command): void {
        commandQueue = [...commandQueue, command]
        runNext()
    }

    function runNext(): void {
        if (commandProc.running || commandQueue.length === 0)
            return
        commandProc.command = commandQueue[0]
        commandQueue = commandQueue.slice(1)
        commandProc.running = true
    }

    function urgencyValue(value): int {
        if (value === "low")
            return NotificationRecord.Low
        if (value === "critical")
            return NotificationRecord.Critical
        return NotificationRecord.Normal
    }

    function applyNotifications(rawList): void {
        replaceNotifications(rawList)
    }

    function createDebugRecord(
        notificationId: string,
        appName: string,
        summary: string,
        time: double
    ): NotificationRecord {
        return recordComponent.createObject(root, {
            notificationId: notificationId,
            appName: appName,
            appIcon: "accessories-clock",
            desktopEntry: "debug-time-" + notificationId,
            category: "debug.time",
            summary: summary,
            body: "Expected label: " + appName.replace("Time · ", ""),
            time: time,
            dismissible: false
        })
    }

    function createDebugRecords(now: date): list<NotificationRecord> {
        const yesterday = new Date(
            now.getFullYear(), now.getMonth(), now.getDate() - 1, 12)
        const older = new Date(
            now.getFullYear(), now.getMonth(), now.getDate() - 14, 12)
        const previousYear = new Date(
            now.getFullYear() - 1, now.getMonth(), now.getDate(), 12)

        return [
            createDebugRecord("debug-now", "Time · Now", "Observed 30 seconds ago", now.getTime() - 30000),
            createDebugRecord("debug-minutes", "Time · 12m", "Observed 12 minutes ago", now.getTime() - 720000),
            createDebugRecord("debug-hours", "Time · 3h", "Observed 3 hours ago", now.getTime() - 10800000),
            createDebugRecord("debug-yesterday", "Time · Yesterday", "Observed yesterday", yesterday.getTime()),
            createDebugRecord("debug-date", "Time · Older date", "Observed two weeks ago", older.getTime()),
            createDebugRecord("debug-year", "Time · Previous year", "Observed last year", previousYear.getTime())
        ]
    }

    function replaceNotifications(rawList): void {
        const previous = notifications.slice()
        const previousIds = ({})
        const presentIds = ({})
        const nextUnreadIds = Object.assign({}, unreadIds)
        const now = Date.now()

        previous.forEach(record => previousIds[record.notificationId] = true)

        let records = rawList.map(raw => {
            const notificationId = String(raw.id)
            presentIds[notificationId] = true

            if (firstSeen[notificationId] === undefined)
                firstSeen[notificationId] = now
            if (initialized && !previousIds[notificationId])
                nextUnreadIds[notificationId] = true

            const record = recordComponent.createObject(root, {
                notificationId: notificationId,
                appName: raw.app_name || "Unknown",
                appIcon: raw.app_icon || "",
                desktopEntry: raw.desktop_entry || "",
                category: raw.category || "",
                summary: raw.summary || "",
                body: raw.body || "",
                urgency: urgencyValue(raw.urgency),
                time: firstSeen[notificationId]
            })

            const rawActions = raw.actions || {}
            record.actions = Object.keys(rawActions).map(identifier =>
                actionComponent.createObject(record, {
                    identifier: identifier,
                    text: String(rawActions[identifier])
                }))
            return record
        })

        Object.keys(firstSeen).forEach(notificationId => {
            if (!presentIds[notificationId])
                delete firstSeen[notificationId]
        })
        Object.keys(nextUnreadIds).forEach(notificationId => {
            if (!presentIds[notificationId])
                delete nextUnreadIds[notificationId]
        })

        if (debugTimeFixtures)
            records = [...records, ...createDebugRecords(new Date(now))]

        records.sort((a, b) => b.time - a.time
            || Number(b.notificationId) - Number(a.notificationId))

        notifications = records
        unreadIds = nextUnreadIds
        unreadCount = Object.keys(nextUnreadIds).length
        initialized = true
        previous.forEach(record => record.destroy())
    }

    Component {
        id: recordComponent
        NotificationRecord {}
    }

    Component {
        id: actionComponent
        NotificationAction {}
    }

    Timer {
        interval: 2000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    Process {
        id: listProc
        command: ["makoctl", "list", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.applyNotifications(JSON.parse(text))
                    root.available = true
                } catch (error) {
                    console.warn("Failed to parse mako notifications:", error)
                }
            }
        }
        onExited: code => {
            if (code !== 0)
                root.available = false
        }
    }

    Process {
        id: modeProc
        command: ["makoctl", "mode"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.dnd = text.split("\n").includes("do-not-disturb")
            }
        }
        onExited: code => {
            if (code !== 0)
                root.available = false
        }
    }

    Process {
        id: commandProc
        onExited: {
            root.refresh()
            root.runNext()
        }
    }
}
