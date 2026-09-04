pragma Singleton

import QtQuick
import Quickshell
import "./Notifications" as NotificationTypes

Singleton {
    id: root

    // Selected by the QS_NOTIFICATION_BACKEND environment variable so the system
    // configuration can choose the backend without editing this file. Unset or
    // unknown values fall back to native.
    property string backendMode: {
        const requested = Quickshell.env("QS_NOTIFICATION_BACKEND")
        const allowed = ["mako", "native", "fixture"]
        if (requested === null || requested === "")
            return "native"
        if (allowed.includes(requested))
            return requested
        console.warn("[notifications] unknown QS_NOTIFICATION_BACKEND:",
            requested, "\u2014 using native")
        return "native"
    }
    property NotificationTypes.NotificationBackend impl:
        makoLoader.item ?? fixtureLoader.item ?? nativeLoader.item ?? nullBackend
    property list<NotificationTypes.NotificationEntry> entries: []
    property list<NotificationTypes.NotificationGroup> groupedEntries: []
    property list<NotificationTypes.NotificationEntry> popupEntries: []
    property list<NotificationTypes.NotificationGroup> groupedPopupEntries: []
    property var popupInhibitors: ({})

    readonly property bool available: impl.available
    readonly property bool dnd: impl.dnd
    readonly property bool popupInhibited: Object.keys(popupInhibitors).length > 0
    readonly property list<NotificationTypes.NotificationEntry> notifications: entries
    readonly property list<NotificationTypes.NotificationGroup> groups: groupedEntries
    readonly property list<NotificationTypes.NotificationEntry> popupNotifications: popupEntries
    readonly property list<NotificationTypes.NotificationGroup> popupGroups: groupedPopupEntries
    readonly property int count: entries.length
    readonly property int unreadCount: impl.unreadCount

    function refresh(): void {
        impl.refresh()
    }

    function setDnd(enabled: bool): void {
        impl.setDnd(enabled)
    }

    function toggleDnd(): void {
        impl.toggleDnd()
    }

    function markAllRead(): void {
        impl.markAllRead()
    }

    function dismiss(notificationId: string): void {
        impl.dismiss(notificationId)
    }

    function dismissGroup(groupId: string): void {
        const group = groupedEntries.find(candidate => candidate.groupId === groupId)
        if (group !== undefined)
            dismissMany(group.notifications.map(entry => entry.notificationId))
    }

    function dismissMany(notificationIds: list<string>): void {
        notificationIds.forEach(notificationId => impl.dismiss(notificationId))
    }

    function setPopupInhibitor(inhibitorId: string, active: bool): void {
        if (inhibitorId === ""
                || (popupInhibitors[inhibitorId] === true) === active)
            return
        const next = Object.assign({}, popupInhibitors)
        if (active)
            next[inhibitorId] = true
        else
            delete next[inhibitorId]
        popupInhibitors = next
        impl.setPopupInhibited(Object.keys(next).length > 0)
    }

    function setPopupGroupHovered(notificationIds: list<string>, hovered: bool): void {
        notificationIds.forEach(notificationId => impl.setPopupHovered(notificationId, hovered))
    }

    function dismissAll(): void {
        impl.dismissAll()
    }

    function invokeAction(notificationId: string, actionId: string): void {
        impl.invokeAction(notificationId, actionId)
    }

    function groupIdFor(record: NotificationTypes.NotificationRecord): string {
        if (record.desktopEntry !== "")
            return "desktop-entry:" + record.desktopEntry
        return "app-name:" + record.appName.trim().toLocaleLowerCase()
    }

    function iconFor(record: NotificationTypes.NotificationRecord): string {
        if (record.appIcon !== "")
            return record.appIcon
        return record.desktopEntry.replace(/\.desktop$/i, "")
    }

    function sameObjectList(left, right): bool {
        if (left.length !== right.length)
            return false
        for (let index = 0; index < left.length; index++) {
            if (left[index] !== right[index])
                return false
        }
        return true
    }

    function reconcileActions(
        entry: NotificationTypes.NotificationEntry,
        record: NotificationTypes.NotificationRecord
    ): void {
        const previousById = ({})
        entry.actions.forEach(action => previousById[action.identifier] = action)

        const nextActions = record.actions.map(recordAction => {
            let action = previousById[recordAction.identifier]
            if (action === undefined) {
                action = actionEntryComponent.createObject(entry, {
                    identifier: recordAction.identifier,
                    text: recordAction.text
                })
            } else {
                action.text = recordAction.text
                delete previousById[recordAction.identifier]
            }
            return action
        })

        if (!sameObjectList(entry.actions, nextActions))
            entry.actions = nextActions
        Object.values(previousById).forEach(action => action.destroy())
    }

    function updateEntry(
        entry: NotificationTypes.NotificationEntry,
        record: NotificationTypes.NotificationRecord,
        groupId: string,
        appIcon: string
    ): void {
        entry.groupId = groupId
        entry.appName = record.appName
        entry.appIcon = appIcon
        entry.category = record.category
        entry.summary = record.summary
        entry.body = record.body
        entry.image = record.image
        entry.urgency = record.urgency
        entry.time = record.time
        entry.dismissible = record.dismissible
        reconcileActions(entry, record)
    }

    function reconcile(): void {
        const previousEntriesById = ({})
        const previousGroupsById = ({})
        entries.forEach(entry => previousEntriesById[entry.notificationId] = entry)
        groupedEntries.forEach(group => previousGroupsById[group.groupId] = group)

        const groupDataById = ({})
        const nextEntries = impl.notifications.map(record => {
            const groupId = groupIdFor(record)
            const appIcon = iconFor(record)
            let entry = previousEntriesById[record.notificationId]

            if (entry === undefined) {
                entry = entryComponent.createObject(root, {
                    notificationId: record.notificationId,
                    groupId: groupId,
                    appName: record.appName
                })
            } else {
                delete previousEntriesById[record.notificationId]
            }
            updateEntry(entry, record, groupId, appIcon)

            if (groupDataById[groupId] === undefined) {
                groupDataById[groupId] = {
                    appName: record.appName,
                    appIcon: appIcon,
                    time: record.time,
                    notifications: []
                }
            }

            const groupData = groupDataById[groupId]
            groupData.notifications.push(entry)
            if (record.time >= groupData.time) {
                groupData.appName = record.appName
                groupData.appIcon = appIcon
                groupData.time = record.time
            }
            return entry
        })

        const nextGroups = Object.keys(groupDataById).map(groupId => {
            const data = groupDataById[groupId]
            data.notifications.sort((a, b) => b.time - a.time)

            let group = previousGroupsById[groupId]
            if (group === undefined) {
                group = groupComponent.createObject(root, {
                    groupId: groupId,
                    appName: data.appName
                })
            } else {
                delete previousGroupsById[groupId]
            }

            group.appName = data.appName
            group.appIcon = data.appIcon
            group.time = data.time
            if (!sameObjectList(group.notifications, data.notifications))
                group.notifications = data.notifications
            return group
        })
        nextGroups.sort((a, b) => b.time - a.time)

        if (!sameObjectList(entries, nextEntries))
            entries = nextEntries
        if (!sameObjectList(groupedEntries, nextGroups))
            groupedEntries = nextGroups
        Object.values(previousGroupsById).forEach(group => group.destroy(250))
        Object.values(previousEntriesById).forEach(entry => entry.destroy(250))
        reconcilePopups()
    }

    function reconcilePopups(): void {
        const popupIds = ({})
        impl.popupNotificationIds.forEach(notificationId => popupIds[notificationId] = true)
        const nextPopupEntries = entries.filter(entry => popupIds[entry.notificationId] === true)
        const previousGroupsById = ({})
        groupedPopupEntries.forEach(group => previousGroupsById[group.groupId] = group)
        const groupDataById = ({})

        nextPopupEntries.forEach(entry => {
            if (groupDataById[entry.groupId] === undefined) {
                groupDataById[entry.groupId] = {
                    appName: entry.appName,
                    appIcon: entry.appIcon,
                    time: entry.time,
                    notifications: []
                }
            }
            const data = groupDataById[entry.groupId]
            data.notifications.push(entry)
            if (entry.time >= data.time) {
                data.appName = entry.appName
                data.appIcon = entry.appIcon
                data.time = entry.time
            }
        })

        const nextPopupGroups = Object.keys(groupDataById).map(groupId => {
            const data = groupDataById[groupId]
            data.notifications.sort((a, b) => b.time - a.time)
            let group = previousGroupsById[groupId]
            if (group === undefined) {
                group = groupComponent.createObject(root, {
                    groupId: groupId,
                    appName: data.appName
                })
            } else {
                delete previousGroupsById[groupId]
            }
            group.appName = data.appName
            group.appIcon = data.appIcon
            group.time = data.time
            if (!sameObjectList(group.notifications, data.notifications))
                group.notifications = data.notifications
            return group
        })
        nextPopupGroups.sort((a, b) => b.time - a.time)

        if (!sameObjectList(popupEntries, nextPopupEntries))
            popupEntries = nextPopupEntries
        if (!sameObjectList(groupedPopupEntries, nextPopupGroups))
            groupedPopupEntries = nextPopupGroups
        Object.values(previousGroupsById).forEach(group => group.destroy(250))
    }

    NotificationTypes.NullNotificationStrategy {
        id: nullBackend
    }

    LazyLoader {
        id: makoLoader
        active: root.backendMode === "mako"
        NotificationTypes.MakoStrategy {}
    }

    LazyLoader {
        id: fixtureLoader
        active: root.backendMode === "fixture"
        NotificationTypes.NotificationFixtureStrategy {}
    }

    LazyLoader {
        id: nativeLoader
        active: root.backendMode === "native"
        NotificationTypes.QuickshellStrategy {}
    }

    Component {
        id: entryComponent
        NotificationTypes.NotificationEntry {}
    }

    Component {
        id: actionEntryComponent
        NotificationTypes.NotificationActionEntry {}
    }

    Component {
        id: groupComponent
        NotificationTypes.NotificationGroup {}
    }

    Connections {
        target: root.impl
        function onNotificationsChanged(): void {
            root.reconcile()
        }
        function onPopupNotificationIdsChanged(): void {
            root.reconcilePopups()
        }
        function onNotificationUpdated(notificationId: string): void {
            root.reconcile()
        }
    }

    onImplChanged: {
        impl.setPopupInhibited(Object.keys(popupInhibitors).length > 0)
        reconcile()
    }
    Component.onCompleted: reconcile()
}
