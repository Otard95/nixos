import qs
import QtQuick
import Quickshell
import Quickshell.Services.Notifications as NativeNotifications

NotificationBackend {
    id: root

    available: true
    popupNotificationIds: popupController.notificationIds

    property bool sessionIdentityReady: false
    readonly property bool historyStoreReady: history.ready
    property bool initComplete: false
    property bool initializingBatch: false
    property bool discardHistoryOnInitialization: false

    property list<NativeNotificationBinding> pendingBindings: []
    property list<NativeNotificationBinding> bindings: []
    property list<NotificationRecord> historicalRecords: []
    property var liveBindingsByProtocolId: ({})
    property var historicalRecordsByNotificationId: ({})
    property var restoredByReloadKey: ({})
    property var pendingPersistedByReloadKey: ({})
    property var pendingClosedLastGenerationIds: ({})
    property var unreadIds: ({})

    onHistoryStoreReadyChanged: tryCompleteInitialization()
    onPopupInhibitedChanged: {
        if (popupInhibited)
            hideAllPopups()
    }
    onDndChangeRequested: enabled => {
        console.log("[notifications] dnd:", enabled)
        dnd = enabled
        if (enabled)
            hideNonCriticalPopups()
    }
    onMarkAllReadRequested: {
        const transientIds = bindings
            .filter(binding => binding.record.isTransient)
            .map(binding => binding.protocolId)
        console.log("[notifications] markAllRead, expiring transients:",
            JSON.stringify(transientIds))
        unreadIds = ({})
        unreadCount = 0
        bindings.filter(binding => binding.record.isTransient)
            .forEach(binding => binding.notification.expire())
    }
    onDismissRequested: notificationId => dismissRecord(notificationId)
    onDismissAllRequested: dismissAllRecords()
    onActionInvocationRequested: (notificationId, actionId) => {
        const binding = bindingFor(notificationId)
        if (binding === null)
            return
        hidePopup(notificationId)
        binding.invokeAction(actionId)
    }

    function generateIdentifier(prefix: string): string {
        const words = []
        for (let index = 0; index < 4; index++) {
            words.push(Math.floor(Math.random() * 0x100000000)
                .toString(16).padStart(8, "0"))
        }
        return prefix + "-" + Date.now().toString(36) + "-" + words.join("")
    }

    function reloadKey(sessionId: string, protocolId: string): string {
        return JSON.stringify([sessionId, protocolId])
    }

    function bindingFor(notificationId: string): NativeNotificationBinding {
        return liveBindingsByProtocolId[notificationId] ?? null
    }

    function acceptNotification(notification: NativeNotifications.Notification): void {
        const notificationId = String(notification.id)
        if (liveBindingsByProtocolId[notificationId] !== undefined) {
            console.warn("Received duplicate native notification ID:", notificationId)
            notification.dismiss()
            return
        }

        const binding = bindingComponent.createObject(root, {
            notification: notification,
            arrivalTime: Date.now()
        })
        if (binding === null) {
            console.warn("Failed to bind native notification:", notificationId)
            notification.dismiss()
            return
        }

        liveBindingsByProtocolId[notificationId] = binding
        console.log("[notifications] accepted", notificationId,
            "app:", notification.appName,
            "urgency:", notification.urgency,
            "transient:", binding.record.isTransient,
            "resident:", binding.record.resident,
            "lastGen:", notification.lastGeneration,
            "initComplete:", initComplete)

        if (initComplete)
            processBinding(binding)
        else
            pendingBindings.push(binding)
    }

    function tryCompleteInitialization(): void {
        if (initComplete || !sessionIdentityReady || !historyStoreReady)
            return

        initializingBatch = true
        const candidates = ({})
        if (!discardHistoryOnInitialization) {
            let sourceEntries = history.entries
            let sourceName = "file"
            if (sessionProperties.pendingHistoryJson !== "") {
                try {
                    const pending = JSON.parse(
                        sessionProperties.pendingHistoryJson)
                    if (Array.isArray(pending)) {
                        sourceEntries = pending
                        sourceName = "pending"
                    }
                } catch (error) {
                    console.warn("[notifications] invalid pending history:",
                        error)
                }
            }
            history.bounded(sourceEntries).forEach(entry =>
                candidates[reloadKey(entry.originatingDaemonSessionId,
                    entry.originatingProtocolId)] = entry)
        }
        pendingPersistedByReloadKey = candidates

        Object.keys(pendingClosedLastGenerationIds).forEach(protocolId => {
            const key = reloadKey(sessionProperties.daemonSessionId, protocolId)
            delete pendingPersistedByReloadKey[key]
        })

        const staged = pendingBindings.slice()
        pendingBindings = []
        // Prevent future new-record policies from evicting history before it reconnects.
        staged.forEach(binding => {
            if (binding.lastGeneration)
                processBinding(binding)
        })
        staged.forEach(binding => {
            if (!binding.lastGeneration)
                processBinding(binding)
        })

        const restored = Object.values(pendingPersistedByReloadKey)
            .map(entry => createHistoricalRecord(entry))
        pendingPersistedByReloadKey = ({})
        historicalRecords.push(...restored)
        pendingClosedLastGenerationIds = ({})

        initializingBatch = false
        initComplete = true
        publishRecords()
        persistRecords()

        const keepKeys = bindings.map(binding => binding.durableId)
        historicalRecords.forEach(record => keepKeys.push(
            historicalRecordsByNotificationId[record.notificationId]
                .entry.durableId))
        imageCache.sweep(keepKeys)
    }

    function handleImageCached(key: string, url: string): void {
        const binding = bindings.find(candidate =>
            candidate.durableId === key)
        if (binding === undefined)
            return
        binding.imageOverride = url
        binding.imageOverrideActive = true
        binding.record.image = url
        notificationUpdated(binding.protocolId)
        persistRecords()
    }

    function handleImageFailed(key: string): void {
        const binding = bindings.find(candidate =>
            candidate.durableId === key)
        if (binding === undefined)
            return
        // Clear the broken sender image so the UI falls back to the app icon.
        binding.imageOverride = ""
        binding.imageOverrideActive = true
        binding.record.image = ""
        notificationUpdated(binding.protocolId)
        persistRecords()
    }

    function processBinding(binding: NativeNotificationBinding): void {
        if (binding.lastGeneration)
            reconcileLastGeneration(binding)
        else
            publishNewBinding(binding, true)
    }

    function reconcileLastGeneration(binding: NativeNotificationBinding): void {
        const key = reloadKey(sessionProperties.daemonSessionId,
            binding.protocolId)
        const persisted = pendingPersistedByReloadKey[key]
        if (persisted !== undefined) {
            delete pendingPersistedByReloadKey[key]
            applyPersistedIdentity(binding, persisted)
            publishNewBinding(binding, false)
            return
        }

        const restored = restoredByReloadKey[key]
        if (restored !== undefined) {
            delete restoredByReloadKey[key]
            delete historicalRecordsByNotificationId[
                restored.record.notificationId]
            historicalRecords.splice(
                historicalRecords.indexOf(restored.record), 1)
            applyPersistedIdentity(binding, restored.entry)
            publishNewBinding(binding, false)
            restored.record.destroy(250)
            return
        }

        publishNewBinding(binding, false)
    }

    function applyPersistedIdentity(binding: NativeNotificationBinding,
                                    persisted): void {
        binding.durableId = persisted.durableId
        binding.originatingDaemonSessionId =
            persisted.originatingDaemonSessionId
        binding.record.time = persisted.time
        // The native object still reports the sender's temporary image path,
        // which no longer exists. Restore the cached thumbnail instead.
        if (persisted.image !== undefined && persisted.image !== "") {
            binding.imageOverride = persisted.image
            binding.imageOverrideActive = true
            binding.record.image = persisted.image
        }
    }

    function publishNewBinding(binding: NativeNotificationBinding,
                               newlyReceived: bool): void {
        if (binding.durableId === "")
            binding.durableId = generateIdentifier("notification")
        if (binding.originatingDaemonSessionId === "")
            binding.originatingDaemonSessionId =
                sessionProperties.daemonSessionId

        bindings.unshift(binding)

        if (newlyReceived) {
            unreadIds[binding.protocolId] = true
            unreadCount = Object.keys(unreadIds).length
            const critical = binding.record.urgency
                === NotificationRecord.Critical
            const low = binding.record.urgency === NotificationRecord.Low
            const popupAllowed = !popupInhibited && !low && (!dnd || critical)
            console.log("[notifications] publish", binding.protocolId,
                "urgency:", binding.record.urgency,
                "transient:", binding.record.isTransient,
                "resident:", binding.record.resident,
                "low:", low, "dnd:", dnd, "inhibited:", popupInhibited,
                "popup:", popupAllowed)
            if (popupAllowed)
                popupController.show(binding.protocolId,
                    binding.expireTimeout, critical)
            imageCache.cache(binding.durableId, binding.record.image)
        } else {
            console.log("[notifications] publish (replay)", binding.protocolId,
                "urgency:", binding.record.urgency)
        }

        if (!initializingBatch) {
            publishRecords()
            persistRecords()
        }
    }

    function createHistoricalRecord(entry): NotificationRecord {
        const notificationId = "history:" + entry.durableId
        const record = historicalRecordComponent.createObject(root, {
            notificationId: notificationId,
            appName: entry.appName,
            appIcon: entry.appIcon,
            desktopEntry: entry.desktopEntry,
            category: entry.category,
            summary: entry.summary,
            body: entry.body,
            image: entry.image ?? "",
            urgency: entry.urgency,
            time: entry.time,
            resident: entry.resident
        })
        const metadata = { record: record, entry: entry }
        historicalRecordsByNotificationId[notificationId] = metadata
        restoredByReloadKey[reloadKey(entry.originatingDaemonSessionId,
            entry.originatingProtocolId)] = metadata
        return record
    }

    function publishRecords(): void {
        const records = bindings.map(binding => binding.record)
        records.push(...historicalRecords)
        records.sort((left, right) => right.time - left.time)
        notifications = records
    }

    function removeClosed(notificationId: string, reason: int): void {
        console.log("[notifications] closed", notificationId, "reason:", reason)
        const binding = bindingFor(notificationId)
        if (binding === null)
            return

        const wasPending = pendingBindings.includes(binding)
        const wasPublished = bindings.includes(binding)
        delete liveBindingsByProtocolId[notificationId]
        delete unreadIds[notificationId]

        unreadCount = Object.keys(unreadIds).length
        popupController.hide(notificationId)
        if (wasPending)
            pendingBindings.splice(pendingBindings.indexOf(binding), 1)
        if (wasPublished)
            bindings.splice(bindings.indexOf(binding), 1)

        if (wasPending && binding.lastGeneration)
            pendingClosedLastGenerationIds[notificationId] = true
        imageCache.remove(binding.durableId)
        if (wasPublished) {
            publishRecords()
            persistRecords()
        }
        binding.destroy()
    }

    function dismissRecord(notificationId: string): void {
        const binding = bindingFor(notificationId)
        if (binding !== null) {
            binding.notification.dismiss()
            return
        }

        const historical = historicalRecordsByNotificationId[notificationId]
        if (historical === undefined)
            return
        removeHistoricalRecord(historical.record, historical.entry)
    }

    function removeHistoricalRecord(record: NotificationRecord, entry): void {
        delete historicalRecordsByNotificationId[record.notificationId]
        delete restoredByReloadKey[reloadKey(
            entry.originatingDaemonSessionId,
            entry.originatingProtocolId)]
        imageCache.remove(entry.durableId)
        historicalRecords.splice(historicalRecords.indexOf(record), 1)
        publishRecords()
        persistRecords()
        record.destroy(250)
    }

    function dismissAllRecords(): void {
        const currentBindings = Object.values(liveBindingsByProtocolId)
        const currentHistorical = historicalRecords.slice()
        hideAllPopups()
        historicalRecords = []
        historicalRecordsByNotificationId = ({})
        restoredByReloadKey = ({})
        publishRecords()
        if (initComplete)
            history.clear()
        else
            discardHistoryOnInitialization = true
        imageCache.sweep([])
        currentHistorical.forEach(record => record.destroy(250))
        currentBindings.forEach(binding => binding.notification.dismiss())
    }

    function handleUpdated(notificationId: string): void {
        const binding = bindingFor(notificationId)
        if (binding === null || !bindings.includes(binding))
            return
        notificationUpdated(notificationId)
        const critical = binding.record.urgency
            === NotificationRecord.Critical
        const low = binding.record.urgency === NotificationRecord.Low
        const popupEligible = !low && !popupInhibited && (!dnd || critical)
        const popupVisible = popupController.notificationIds
            .includes(notificationId)
        console.log("[notifications] updated", notificationId,
            "urgency:", binding.record.urgency,
            "popupEligible:", popupEligible,
            "popupVisible:", popupVisible,
            "popupRestarted:", popupEligible && popupVisible)
        if (popupEligible)
            popupController.restartVisible(notificationId,
                binding.expireTimeout, critical)
        else
            popupController.hide(notificationId)
        persistRecords()
    }

    function handlePopupTimeout(notificationId: string): void {
        console.log("[notifications] popup timeout", notificationId)
        const binding = bindingFor(notificationId)
        if (binding === null) {
            popupController.hide(notificationId)
            return
        }
        popupController.hide(notificationId)
    }

    function setPopupHovered(notificationId: string, hovered: bool): void {
        popupController.setHovered(notificationId, hovered)
    }

    function hidePopup(notificationId: string): void {
        popupController.hide(notificationId)
    }

    function hideNonCriticalPopups(): void {
        popupController.notificationIds.forEach(notificationId => {
            const binding = bindingFor(notificationId)
            if (binding?.record.urgency !== NotificationRecord.Critical)
                popupController.hide(notificationId)
        })
    }

    function hideAllPopups(): void {
        popupController.hideAll()
    }

    function persistedEntry(record: NotificationRecord, durableId: string,
                            sessionId: string, protocolId: string): var {
        return {
            durableId: durableId,
            originatingDaemonSessionId: sessionId,
            originatingProtocolId: protocolId,
            appName: record.appName,
            appIcon: record.appIcon,
            desktopEntry: record.desktopEntry,
            category: record.category,
            summary: record.summary,
            body: record.body,
            image: imageCache.isCached(record.image) ? record.image : "",
            urgency: record.urgency,
            time: record.time,
            resident: record.resident
        }
    }

    function handleHistorySaved(): void {
        sessionProperties.pendingHistoryJson = ""
    }

    function persistRecords(): void {
        if (!initComplete || !history.ready)
            return

        const liveEntries = bindings
            .filter(binding => !binding.record.isTransient)
            .map(binding => persistedEntry(binding.record, binding.durableId,
                binding.originatingDaemonSessionId, binding.protocolId))
        const restoredEntries = historicalRecords.map(record => {
            const metadata = historicalRecordsByNotificationId[
                record.notificationId].entry
            return persistedEntry(record, metadata.durableId,
                metadata.originatingDaemonSessionId,
                metadata.originatingProtocolId)
        })
        liveEntries.push(...restoredEntries)
        const pendingEntries = history.bounded(liveEntries)
        sessionProperties.pendingHistoryJson = JSON.stringify(pendingEntries)
        history.replaceEntries(pendingEntries)
    }

    NotificationHistory {
        id: history
        onSaved: root.handleHistorySaved()
    }

    NotificationImageCache {
        id: imageCache
        onReady: (key, url) => root.handleImageCached(key, url)
        onFailed: key => root.handleImageFailed(key)
    }

    PersistentProperties {
        id: sessionProperties
        reloadableId: "notificationDaemonSession"

        property string daemonSessionId:
            root.generateIdentifier("daemon-session")
        property string pendingHistoryJson: ""

        onLoaded: {
            root.sessionIdentityReady = true
            root.tryCompleteInitialization()
        }
    }

    NotificationPopupController {
        id: popupController
        onTimeoutRequested: notificationId =>
            root.handlePopupTimeout(notificationId)
    }

    Component {
        id: bindingComponent

        NativeNotificationBinding {
            onUpdated: notificationId => root.handleUpdated(notificationId)
            onClosed: (notificationId, reason) =>
                root.removeClosed(notificationId, reason)
        }
    }

    Component {
        id: historicalRecordComponent
        NotificationRecord {}
    }

    NativeNotifications.NotificationServer {
        id: server

        actionsSupported: true
        actionIconsSupported: false
        bodySupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: false
        imageSupported: true
        inlineReplySupported: false
        persistenceSupported: true
        keepOnReload: true

        onNotification: notification => {
            notification.tracked = true
            root.acceptNotification(notification)
        }
    }
}
