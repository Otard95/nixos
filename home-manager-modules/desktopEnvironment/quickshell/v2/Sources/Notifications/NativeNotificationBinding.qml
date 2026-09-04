import QtQuick
import Quickshell
import Quickshell.Services.Notifications as NativeNotifications

Scope {
    id: root

    required property NativeNotifications.Notification notification
    required property double arrivalTime

    property string durableId: ""
    property string originatingDaemonSessionId: ""
    // Authoritative image override. When active, it wins over the native image,
    // whose sender file may already be deleted. An active empty override clears
    // a broken sender image so the UI can fall back to the app icon.
    property string imageOverride: ""
    property bool imageOverrideActive: false

    readonly property NotificationRecord record: typedRecord
    readonly property string protocolId: String(notification.id)
    readonly property bool lastGeneration: notification.lastGeneration
    readonly property real expireTimeout: notification.expireTimeout

    signal updated(notificationId: string)
    signal closed(notificationId: string, reason: int)

    function urgencyValue(): int {
        if (notification.urgency === NativeNotifications.NotificationUrgency.Low)
            return NotificationRecord.Low
        if (notification.urgency === NativeNotifications.NotificationUrgency.Critical)
            return NotificationRecord.Critical
        return NotificationRecord.Normal
    }

    function categoryValue(): string {
        return String(notification.hints?.category ?? "")
    }

    function reconcileActions(): void {
        const previousById = ({})
        typedRecord.actions.forEach(action => previousById[action.identifier] = action)

        const nextActions = notification.actions.map(nativeAction => {
            let action = previousById[nativeAction.identifier]
            if (action === undefined) {
                action = actionComponent.createObject(typedRecord, {
                    identifier: nativeAction.identifier,
                    text: nativeAction.text
                })
            } else {
                action.text = nativeAction.text
                delete previousById[nativeAction.identifier]
            }
            return action
        })

        typedRecord.actions = nextActions
        Object.values(previousById).forEach(action => action.destroy())
    }

    function synchronize(emitUpdate: bool): void {
        typedRecord.appName = notification.appName || "Unknown"
        typedRecord.appIcon = notification.appIcon || ""
        typedRecord.desktopEntry = notification.desktopEntry || ""
        typedRecord.category = categoryValue()
        typedRecord.summary = notification.summary || ""
        typedRecord.body = notification.body || ""
        typedRecord.image = imageOverrideActive
            ? imageOverride
            : (notification.image || "")
        typedRecord.urgency = urgencyValue()
        typedRecord.isTransient = notification.transient
        typedRecord.resident = notification.resident
        reconcileActions()

        if (emitUpdate)
            updated(typedRecord.notificationId)
    }

    function scheduleUpdate(): void {
        updateTimer.restart()
    }

    function invokeAction(actionId: string): bool {
        const action = notification.actions.find(candidate =>
            candidate.identifier === actionId)
        if (action === undefined)
            return false
        action.invoke()
        return true
    }

    NotificationRecord {
        id: typedRecord

        notificationId: root.protocolId
        appName: root.notification.appName || "Unknown"
        time: root.arrivalTime
    }

    Component {
        id: actionComponent
        NotificationAction {}
    }

    Timer {
        id: updateTimer
        interval: 0
        onTriggered: root.synchronize(true)
    }

    Connections {
        target: root.notification
        ignoreUnknownSignals: true

        function onAppNameChanged(): void { root.scheduleUpdate() }
        function onAppIconChanged(): void { root.scheduleUpdate() }
        function onDesktopEntryChanged(): void { root.scheduleUpdate() }
        function onHintsChanged(): void { root.scheduleUpdate() }
        function onSummaryChanged(): void { root.scheduleUpdate() }
        function onBodyChanged(): void { root.scheduleUpdate() }
        function onImageChanged(): void { root.scheduleUpdate() }
        function onUrgencyChanged(): void { root.scheduleUpdate() }
        function onTransientChanged(): void { root.scheduleUpdate() }
        function onResidentChanged(): void { root.scheduleUpdate() }
        function onActionsChanged(): void { root.scheduleUpdate() }
        function onExpireTimeoutChanged(): void { root.scheduleUpdate() }

        function onClosed(reason): void {
            updateTimer.stop()
            root.closed(root.protocolId, reason)
        }
    }

    Component.onCompleted: synchronize(false)
}
