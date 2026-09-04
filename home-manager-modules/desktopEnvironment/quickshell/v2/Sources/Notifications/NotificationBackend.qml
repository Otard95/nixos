import Quickshell

Scope {
    property bool available: false
    property bool dnd: false
    property bool popupInhibited: false
    property list<NotificationRecord> notifications: []
    property list<string> popupNotificationIds: []
    property int unreadCount: 0

    signal notificationUpdated(notificationId: string)
    signal refreshRequested
    signal dndChangeRequested(enabled: bool)
    signal markAllReadRequested
    signal dismissRequested(notificationId: string)
    signal dismissAllRequested
    signal actionInvocationRequested(notificationId: string, actionId: string)

    function refresh(): void {
        refreshRequested()
    }

    function setDnd(enabled: bool): void {
        dndChangeRequested(enabled)
    }

    function toggleDnd(): void {
        setDnd(!dnd)
    }

    function markAllRead(): void {
        markAllReadRequested()
    }

    function dismiss(notificationId: string): void {
        dismissRequested(notificationId)
    }

    function dismissAll(): void {
        dismissAllRequested()
    }

    function invokeAction(notificationId: string, actionId: string): void {
        actionInvocationRequested(notificationId, actionId)
    }

    function setPopupInhibited(enabled: bool): void {
        if (popupInhibited === enabled)
            return
        popupInhibited = enabled
    }

    function setPopupHovered(notificationId: string, hovered: bool): void {}

    function hidePopup(notificationId: string): void {}

    function hideAllPopups(): void {}

}
