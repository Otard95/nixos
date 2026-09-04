Yes. The upstream implementation makes Quickshell itself the notification daemon via `NotificationServer`; it is not merely a UI client.

## Upstream root

```text
/home/otard/.config/quickshell/dots-hyprland/dots/.config/quickshell/ii
```

## Core daemon/service

### `services/Notifications.qml`

This is the central implementation.

It:

- Instantiates `Quickshell.Services.Notifications.NotificationServer`
- Owns the desktop notification service
- Tracks incoming notifications
- Wraps them in a local `Notif` object
- Stores notification metadata:
  - ID
  - application name/icon
  - summary/body
  - image
  - urgency
  - actions
  - timestamp
- Marks incoming notifications as tracked
- Handles popup state and expiry timers
- Maintains unread count
- Groups notifications by application
- Sorts groups by latest notification time
- Dismisses individual or all notifications
- Invokes sender-provided actions
- Persists notifications to JSON
- Restores notification history on startup
- Uses `idOffset` to avoid collisions between restored and newly received IDs

Important section:

```text
services/Notifications.qml:150
```

contains the `NotificationServer`.

The persistence file is loaded and written through a `FileView` near the end of the file. Its path comes from:

```text
modules/common/Directories.qml:39
```

which resolves to:

```text
${XDG_CACHE_HOME}/notifications/notifications.json
```

Restored notifications intentionally have no usable actions because their original sender objects no longer exist.

## Popup host

### `modules/ii/notificationPopup/NotificationPopup.qml`

This creates the actual popup window using a Wayland `PanelWindow`.

It:

- Displays while `Notifications.popupList` is non-empty
- Hides while the screen is locked
- Places popups on the focused or configured monitor
- Uses an overlay layer-shell surface
- Reuses `NotificationListView` with `popup: true`

The popup is loaded by:

```text
panelFamilies/IllogicalImpulseFamily.qml
```

There is also an alternate Waffle implementation:

```text
modules/waffle/notificationPopup/WaffleNotificationPopup.qml
panelFamilies/WaffleFamily.qml
```

## Shared notification model/view structure

### `modules/common/widgets/NotificationListView.qml`

Selects either the normal notification list or popup list:

```qml
Notifications.appNameList
Notifications.popupAppNameList
```

Each delegate is a `NotificationGroup`.

### `modules/common/widgets/NotificationGroup.qml`

Groups notifications from one application.

It handles:

- Collapsed/expanded state
- Showing the newest one or two notifications when collapsed
- Expansion and collapse
- Right-click expansion
- Middle-click dismissal
- Horizontal swipe dismissal
- Popup timeout cancellation while hovered
- Group-level layout and animation

### `modules/common/widgets/NotificationItem.qml`

Renders an individual notification.

It handles:

- Summary and body text
- Rich-text body rendering
- External links
- Notification actions
- Close action
- Copy-to-clipboard behavior
- Individual swipe dismissal
- Middle-click dismissal
- Notification image display

### Supporting widgets

```text
modules/common/widgets/NotificationAppIcon.qml
modules/common/widgets/NotificationActionButton.qml
modules/common/widgets/NotificationGroupExpandButton.qml
modules/common/widgets/DragManager.qml
modules/common/widgets/StyledListView.qml
modules/common/widgets/PagePlaceholder.qml
```

These provide icons, action buttons, expand controls, drag behavior, list behavior, and the empty-state placeholder.

## Sidebar notification center

### `modules/ii/sidebarRight/notifications/NotificationList.qml`

Composes the sidebar notification panel:

```text
Scrollable NotificationListView
Empty-state PagePlaceholder
Footer ButtonGroup
```

The footer provides:

- Silent/DND toggle
- Notification count
- Clear-all button

The sidebar is included through the broader sidebar composition:

```text
modules/ii/sidebarRight/SidebarRightContent.qml
modules/ii/sidebarRight/CenterWidgetGroup.qml
```

## Notification utility functions

### `modules/common/functions/NotificationUtils.qml`

Provides:

- Friendly timestamps:
  - `Now`
  - minutes/hours
  - `Yesterday`
  - calendar dates
- Chromium notification body cleanup
- Embedded-image line normalization
- Summary-based Material icon selection

## High-level architecture

```text
NotificationServer
        │
        ▼
services/Notifications.qml
  - tracking
  - persistence
  - grouping
  - unread count
  - popup timers
  - actions/dismissal
        │
        ├── modules/ii/notificationPopup/NotificationPopup.qml
        │       └── NotificationListView
        │
        └── modules/ii/sidebarRight/notifications/NotificationList.qml
                └── NotificationListView
                        └── NotificationGroup
                                └── NotificationItem
```

## Conclusion

The upstream has a complete Quickshell-owned notification daemon and notification UI. The essential file is:

```text
services/Notifications.qml
```

The implementation is split into:

1. **Daemon/state management:** `services/Notifications.qml`
2. **Persistence path:** `modules/common/Directories.qml`
3. **Popup host:** `modules/ii/notificationPopup/NotificationPopup.qml`
4. **Sidebar center:** `modules/ii/sidebarRight/notifications/NotificationList.qml`
5. **Shared delegates/widgets:** `modules/common/widgets/Notification*.qml`
6. **Formatting/helpers:** `modules/common/functions/NotificationUtils.qml`

This differs from the current local setup, where Mako owns `org.freedesktop.Notifications` and Quickshell only adapts to Mako’s output.
