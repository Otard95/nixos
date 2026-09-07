# Sidebar notification-list study

## Source references

### Upstream QML

Upstream root:

```text
/home/otard/.config/quickshell/dots-hyprland/dots/.config/quickshell/ii
```

Notification service and popup host:

```text
services/Notifications.qml
modules/ii/notificationPopup/NotificationPopup.qml
modules/common/Directories.qml
```

Right-sidebar composition:

```text
modules/ii/sidebarRight/SidebarRightContent.qml
modules/ii/sidebarRight/CenterWidgetGroup.qml
modules/ii/sidebarRight/notifications/NotificationList.qml
modules/ii/sidebarRight/notifications/NotificationStatusButton.qml
```

Shared notification widgets:

```text
modules/common/widgets/NotificationListView.qml
modules/common/widgets/NotificationGroup.qml
modules/common/widgets/NotificationItem.qml
modules/common/widgets/NotificationActionButton.qml
modules/common/widgets/NotificationAppIcon.qml
modules/common/widgets/NotificationGroupExpandButton.qml
modules/common/widgets/StyledListView.qml
modules/common/widgets/DragManager.qml
modules/common/widgets/PagePlaceholder.qml
modules/common/functions/NotificationUtils.qml
```

### Local QML and system configuration

Local root:

```text
/home/otard/.config/quickshell/default
```

Relevant files:

```text
Sources/Notifications.qml
Sources/Notifications/MakoStrategy.qml
Sources/Notifications/DunstStrategy.qml
Modules/Right/StatusPill.qml
Modules/StatusPanel/StatusPanelContent.qml
Theme.qml
qmldir
```

Current Mako configuration:

```text
/home/otard/.config/mako/config
```

Current notification-daemon state can be inspected with:

```bash
systemctl --user status mako.service
busctl --user list | grep org.freedesktop.Notifications
makoctl list -j
makoctl history -j
```

### External documentation

Quickshell notification APIs:

- [Quickshell Notifications module](https://quickshell.org/docs/v0.3.1/types/Quickshell.Services.Notifications/)
- [NotificationServer](https://quickshell.org/docs/v0.3.1/types/Quickshell.Services.Notifications/NotificationServer/)
- [Notification](https://quickshell.org/docs/v0.3.1/types/Quickshell.Services.Notifications/Notification/)

Protocol semantics:

- [Desktop Notifications Specification](https://specifications.freedesktop.org/notification/latest/)
- [D-Bus protocol and notification IDs/actions](https://specifications.freedesktop.org/notification/latest/protocol.html)

Mako backend and CLI:

- [Mako upstream repository](https://github.com/emersion/mako)
- [makoctl manual](https://man.archlinux.org/man/makoctl.1.en)

Qt view primitives used by the local port:

- [ListView](https://doc.qt.io/qt-6/qml-qtquick-listview.html)
- [ScrollBar](https://doc.qt.io/qt-6/qml-qtquick-controls-scrollbar.html)

The documentation links describe current APIs; the checked-out upstream QML at
the paths above remains the authority for the exact visual behavior being
ported.

## Critical architectural difference

Upstream Quickshell is itself the notification daemon. Its
`services/Notifications.qml` owns a `NotificationServer`, tracks incoming
notifications, invokes actions, persists history, manages popup timeouts, and
provides the sidebar's grouped model.

The local system currently uses Mako:

- `mako.service` is active.
- Mako owns `org.freedesktop.Notifications` on the user D-Bus.
- `Sources/Notifications.qml` currently controls Mako's do-not-disturb mode; it
  does not receive or store notifications.

Only one process can own the standard notification service. A local
`NotificationServer` cannot operate faithfully while Mako owns that D-Bus name.
Do not disable Mako until Quickshell has both a working notification service and
popup UI, or incoming notifications will have no visible daemon.

## Upstream component hierarchy

```text
SidebarRightContent
└── CenterWidgetGroup
    └── NotificationList
        ├── NotificationListView
        │   └── NotificationGroup (one per application)
        │       ├── NotificationAppIcon
        │       ├── NotificationGroupExpandButton
        │       └── NotificationItem (one per notification)
        │           └── NotificationActionButton
        ├── PagePlaceholder
        └── status ButtonGroup
            ├── pause notifications
            ├── notification count
            └── clear all
```

The same `NotificationListView` is reused by the separate popup window with
`popup: true`.

## Sidebar container

`CenterWidgetGroup.qml` is only a rounded layer-1 rectangle. It gives the
notification list a 5px inner margin and fills the flexible center of the
sidebar between quick controls and the bottom widgets.

Locally, this should replace the current expanding spacer above the calendar:

```text
quick sliders
quick toggles
notification list  ← fills remaining height
calendar           ← fixed bottom section
```

Using the current panel color hierarchy:

```text
panel               crust
notification section mantle
notification groups base
nested items/actions surface0
active/urgent state accent or red-derived color
```

## `NotificationList`

The top-level list component contains three parts.

### Scrollable list

`NotificationListView` fills the area above the footer. Upstream uses an
`OpacityMask` to round the scrolling viewport, but `Qt5Compat.GraphicalEffects`
is unavailable locally. The first local version should use normal clipping and
rounded delegates rather than copy this dependency.

### Empty state

When the notification list is empty, upstream shows a centered placeholder
with a notification icon and “Nothing”. Its `PagePlaceholder` and
`MaterialShape` dependencies are much larger than the behavior requires. A
small local empty-state component is sufficient.

### Footer controls

A 36px-high pill-style button group contains:

- notification pause/DND toggle,
- disabled text button showing the count,
- clear-all button.

The local footer should bind only to `NotificationsSource` properties and
methods; it must not run `makoctl` or manipulate notification objects directly.

## `NotificationListView`

Upstream models the list by application name rather than individual
notifications:

```qml
model: Notifications.appNameList
```

Each delegate receives a group object:

```text
appName
appIcon
latest time
grouped notifications[]
```

Groups are sorted by their latest notification time, newest first.

The upstream base `StyledListView` adds:

- wheel/touchpad scrolling,
- vertical scrollbar,
- add/remove/displacement animations,
- shared horizontal-drag state for neighboring delegates.

A local `NotificationListView` can start from `ListView` plus a standard
`ScrollBar`. Drag coordination belongs in a small reusable helper rather than
in the notification source.

## `NotificationGroup`

Notifications from the same application are grouped similarly to Android.

### Collapsed state

- Height is capped at 80px.
- Shows the newest one or two notifications.
- The second visible item is faded when more than two exist.
- Header displays the application name for multi-notification groups.
- A count/chevron button indicates expansion.

### Expanded state

- Shows every notification in the group, newest first.
- Individual notification bodies and actions become available.
- Group height animates to its full content height.

### Input behavior

- Expand button: expand/collapse.
- Right click on collapsed group: expand/collapse.
- Middle click: dismiss the whole group.
- Horizontal mouse drag or trackpad scroll while collapsed: dismiss the whole
  group after 70px of raw displacement.

The local implementation maps raw displacement through a static attraction
curve. Movement is resisted before the threshold; the attraction then decays
sharply over a 4px breakaway distance. This produces spring-like pull and a
continuous release without a time-dependent physics simulation. Neighboring
group movement remains as the final interaction-polish step.

## `NotificationItem`

Each item receives a notification wrapper containing:

```text
notificationId
appName
appIcon
summary
body
image
actions[]
time
urgency
live notification object, when available
```

### Collapsed content

- Summary and a one-line body preview.
- Body markup is processed and line breaks are normalized.
- Long text is elided.

### Expanded content

- Wrapped rich-text body.
- Hyperlinks open externally.
- Horizontally scrollable action row.
- Close action.
- Sender-provided notification actions.
- Copy-body action with temporary confirmation icon.

### Dismissal

When a group is expanded, individual items become horizontally swipeable.
Middle click also dismisses the item. The dismissal animation moves the item
past the list edge before deleting it from the service.

## Application icon behavior

Upstream chooses, in order:

1. notification image,
2. application icon,
3. guessed Material icon from summary text.

Critical notifications use an emphasized shape/color. Notification images also
show a small application-icon badge.

The upstream implementation depends on `MaterialShape`, `IconImage`,
`StyledImage`, and `OpacityMask`. The local version should initially use:

- `IconImage` or `Quickshell.iconPath()` for application icons,
- a verified Material icon fallback,
- a simple rounded Catppuccin container,
- urgency color without upstream's random Material shapes.

Image masking should not reintroduce unavailable Qt5 graphical effects.

## Friendly time and body processing

Upstream's `NotificationUtils` provides two useful independent behaviors.

### Time labels

```text
< 1 minute       Now
same day         12m / 3h
yesterday        Yesterday
older            August 30
```

### Body normalization

- Cleans the extra origin line used by some Chromium notifications.
- Places embedded images on their own line.
- Preserves rich-text links in expanded content.

These can become small local helper functions without importing upstream's
configuration or translation framework.

## Upstream notification service

Upstream wraps each incoming notification in a typed `Notif` object and exposes
one authoritative list.

Responsibilities include:

- owning `Quickshell.Services.Notifications.NotificationServer`,
- tracking notification objects,
- copying action identifiers/text into persistent wrappers,
- popup visibility and timeout timers,
- unread count,
- DND/silent state,
- grouping by application,
- sorting groups by latest time,
- dismissing one or all notifications,
- invoking sender actions,
- persistent JSON history,
- avoiding ID collisions after restoring saved history.

Notification actions are only meaningful while the original sender and tracked
notification object still exist. Restored historical entries therefore discard
action data.

## Local backend options

### Option A: Quickshell becomes the notification daemon

This most closely matches upstream.

**Benefits**

- Real-time push instead of polling.
- Complete notification objects and image data.
- Reliable sender action invocation.
- Exact dismiss semantics.
- Unified sidebar list, popups, unread count, and persistence.
- No dependence on parsing a daemon-specific CLI format.

**Costs**

- Mako must be disabled so Quickshell can own
  `org.freedesktop.Notifications`.
- Local popup notifications must be implemented before switching.
- Quickshell service reliability becomes notification-daemon reliability.
- DND becomes internal popup inhibition rather than Mako mode control.
- Requires a migration plan for Mako configuration and history.

This is the correct path for full upstream behavior.

### Option B: Keep Mako and use a source adapter

Current Mako supports:

```text
makoctl list -j
makoctl history -j
makoctl dismiss -n ID
makoctl dismiss --all
makoctl invoke -n ID ACTION
makoctl mode ...
```

Its JSON exposes fields including:

```text
id, app_name, app_icon, category, desktop_entry,
summary, body, urgency, actions
```

**Benefits**

- Preserves the existing notification daemon and popups.
- No D-Bus ownership migration.
- Sidebar can display real current/history data relatively quickly.

**Limitations**

- Requires polling unless an additional Mako event hook is configured.
- Current JSON output does not provide arrival timestamps in the observed
  format, so friendly ordering/time labels are limited.
- History and current notifications have different action/dismiss semantics.
- `makoctl` exposes no direct clear-history command in its documented CLI.
- Invoking actions on historical entries is not equivalent to invoking live
  tracked notifications.
- Less complete image/persistence behavior than upstream.
- Couples the source model to Mako's JSON schema.

This is a valid lightweight integration, but it cannot provide full upstream
semantics.

### Rejected approach: passive D-Bus monitoring

Observing notification traffic while Mako remains the daemon would duplicate
messages without owning their lifecycle. Dismissal, action invocation,
replacement IDs, persistence, and startup history would remain unreliable. It
adds complexity without the guarantees of either real option.

## Architecture decision

Mako will remain the notification daemon for the initial implementation. The
notification source will use a strict backend interface so that a future native
Quickshell daemon can replace only the backend implementation. The facade and
all UI components must remain unchanged during that migration.

There are two typed boundaries:

```text
MakoStrategy
    inherits NotificationBackend
    exposes list<NotificationRecord>
              ↓
Notifications facade
    normalizes presentation data and creates groups
    exposes list<NotificationEntry> and list<NotificationGroup>
              ↓
Notification UI
```

No boundary uses untyped `var` collections for notifications, actions, or
groups.

### Backend interface

`NotificationBackend.qml` defines the interface implemented by every backend:

```qml
property bool available
property bool dnd
property list<NotificationRecord> notifications
property int unreadCount

function refresh(): void
function setDnd(enabled: bool): void
function markAllRead(): void
function dismiss(notificationId: string): void
function dismissAll(): void
function invokeAction(notificationId: string, actionId: string): void
```

`MakoStrategy.qml` inherits this type. A future
`QuickshellStrategy.qml` will inherit the same type and own a
`NotificationServer`. Backend selection is private to the facade.

`dismissGroup` is intentionally not part of the backend interface. The facade
resolves a group to notification IDs and calls `dismiss` for each one.

### Backend notification types

`NotificationRecord.qml` is the detailed, backend-neutral record passed from a
backend to the facade:

```qml
required property string notificationId
required property string appName
property string appIcon
property string desktopEntry
property string category
property string summary
property string body
property string image
property int urgency
property double time
property bool isTransient
property bool resident
property bool dismissible
property list<NotificationAction> actions
```

Urgency has the fixed values `Low`, `Normal`, and `Critical`.
`NotificationAction.qml` contains:

```qml
required property string identifier
required property string text
```

Notification IDs are opaque strings. Consumers must not perform arithmetic on
them or assume they are IDs from a particular daemon.

A backend may extend `NotificationRecord` with private typed data. For example,
a native backend may retain its live Quickshell `Notification`, while a Mako
record may retain a numeric Mako ID. Derived records are still published as
`list<NotificationRecord>`.

Two rules preserve the boundary:

1. The facade only reads properties declared by `NotificationRecord`; it never
   checks the concrete backend record type.
2. A backend extension cannot change the meaning of an inherited property.

A backend may instead keep a private ID-to-native-object lookup when that gives
cleaner lifecycle management.

### UI notification types

The facade maps backend records into `NotificationEntry.qml`. This is the
smallest stable presentation contract and prevents backend lifecycle data from
reaching delegates:

```qml
required property string notificationId
required property string groupId
required property string appName
property string appIcon
property string summary
property string body
property string image
property int urgency
property double time
property bool dismissible
property list<NotificationActionEntry> actions
```

`NotificationActionEntry.qml` repeats the typed `identifier` and `text`
contract at the presentation boundary, preventing derived backend action objects
from reaching delegates.

`NotificationGroup.qml` contains:

```qml
required property string groupId
required property string appName
property string appIcon
property double time
property list<NotificationEntry> notifications
```

A group ID is derived from `desktopEntry` when available, otherwise from a
normalized application name. Groups and their notifications are sorted newest
first.

### Stable facade interface

The UI imports only the `Notifications` singleton and uses:

```qml
readonly property bool available
readonly property bool dnd
readonly property list<NotificationEntry> notifications
readonly property list<NotificationGroup> groups
readonly property int count
readonly property int unreadCount

function refresh(): void
function setDnd(enabled: bool): void
function toggleDnd(): void
function markAllRead(): void
function dismiss(notificationId: string): void
function dismissGroup(groupId: string): void
function dismissAll(): void
function invokeAction(notificationId: string, actionId: string): void
```

`notifications` means notifications currently retained by the active backend,
not a daemon-specific history view. `unreadCount` means notifications received
since `markAllRead`, rather than the total notification count. Opening the panel
may call `markAllRead`, but that is a UI policy decision. DND suppresses popups
without preventing collection.

Mako cannot provide real arrival timestamps through its current JSON output, so
its adapter may use the time an entry was first observed. Missing timestamps and
images use `0` and an empty string respectively. A native backend can provide
more accurate values without changing either public interface.

## Recommended local component split

```text
Sources/Notifications.qml
Sources/Notifications/
    NotificationBackend.qml
    NotificationRecord.qml
    NotificationAction.qml
    NotificationActionEntry.qml
    NotificationEntry.qml
    NotificationGroup.qml
    MakoStrategy.qml
    QuickshellStrategy.qml       ← future daemon replacement

Modules/StatusPanel/Notifications/
    NotificationList.qml
    NotificationListView.qml
    NotificationGroup.qml
    NotificationItem.qml
    NotificationAppIcon.qml
    NotificationFooter.qml

Components/
    DragManager.qml
```

The source type and visual component that are both named `NotificationGroup`
reside in different directories and serve different purposes: one is model
data, the other is a delegate.

## Implementation status

### Complete for the Mako first draft

- **Strict typed architecture:** `NotificationBackend`, `NotificationRecord`,
  `NotificationAction`, `NotificationEntry`, `NotificationActionEntry`, and
  `NotificationGroup` are implemented. `Notifications.qml` is the stable typed
  facade; UI code does not access Mako commands or Mako JSON.
- **Mako adapter:** polls `makoctl list -j` and `makoctl mode`, normalizes live
  notifications into typed records, tracks first-observed timestamps and unread
  IDs, and serializes Mako commands. It implements DND, refresh, individual and
  all dismissal, and sender action invocation. Its `debugTimeFixtures` switch can
  inject non-dismissible typed records for Now, minutes, hours, Yesterday, an
  older date, and a previous year without changing the facade contract.
- **Facade grouping:** notifications are grouped by desktop entry when supplied,
  otherwise by normalized application name. Groups and entries are newest-first.
  The facade incrementally reconciles typed entries by notification ID and groups
  by group ID, retaining object identity across backend updates. `ScriptModel`
  exposes granular list changes to the group list and nested item repeaters.
  Group dismissal is intentionally implemented by the facade as individual
  backend dismissals.
- **Status-panel list:** the expanding panel region now holds the notification
  list, empty state, vertical scrollbar, and footer. The footer exposes DND,
  active-notification count, and clear-all through the facade only.
- **Groups and items:** collapsed groups use the upstream-style compact 80px
  card: up to two elided one-line previews are shown, and the second is faded
  when more than two notifications exist. Compact previews have no hover or copy
  affordance. Single and multi-notification groups expand via the chevron or
  right click; middle click dismisses a group. Expansion state is retained by
  group ID across polling, updates, reordering, and dismissal. Expanded groups
  retain the same item background. Full-size items support middle-click
  dismissal and show a low-opacity accent background only while hovered.
- **Content and actions:** collapsed items elide bodies; expanded items wrap
  rich-text bodies and expose sender actions where Mako provides them. A sole
  `default`, Activate, Open, View, Show, or Launch-style action becomes the
  notification's left-click action instead of rendering a redundant button;
  other actions remain explicit buttons. Links open externally. The reserved
  right-side copy affordance appears on hover and copies normalized plain text,
  stripping markup while retaining line breaks and common HTML entities.
- **Initial visual treatment:** Catppuccin hierarchy, basic urgency color,
  sender-provided application icons with desktop-entry icon fallback, then a
  generic Material fallback, live-updating Now/minute/hour/Yesterday/date labels
  (including the year when different), and simple add/remove fades are present.
- **Swipe dismissal:** collapsed groups, expanded group headers, and expanded
  items support mouse drag and trackpad horizontal scroll. Raw and rendered
  displacement are separate. A tunable attraction curve and cursor-space
  hysteresis detach at 100px and reattach at 70px; active targets use 50ms
  smoothing, with snap-back on cancellation and off-screen dismiss travel.
  Adjacent groups or sibling items chain from the active rendered position using
  a `0.15 ^ indexDistance` falloff and return home while detached.
- **Fixture tooling:** `scripts/notification-fixtures` sends typed-protocol test
  notifications through Mako from built-in, file, or standard-input JSON
  fixtures. It supports sequential/random ordering, deterministic seeds, and
  fixed/ranged/cycling interval and expiry specifications. The documented
  `notification-grouping-sequence.json` validates insertion, grouping, newest
  ordering, and group reordering with alternating Build Service and Calendar
  notifications.

### In progress

The agreed Mako-compatible notification-list interactions are complete. The
next substantial phase requires a Quickshell-owned daemon and popup host.

### Partial or backend-limited

- **Unread count** is based on live notifications first observed after startup
  and resets through `markAllRead`; the panel does not yet choose a read-on-open
  policy.
- **Timestamps** are Mako poll observation times, not sender arrival times.
- **Actions** are available for live Mako entries only and rely on Mako's action
  semantics.
- **Images** have a typed field and UI slot, but Mako's observed `list -j`
  schema does not expose notification image data. Application icons work; true
  notification images require a native backend or a different supported source.
- **Current list only:** expiry or dismissal by Mako removes an entry from the
  panel. Mako history is deliberately not merged because it has incompatible
  timestamp, action, and clear-history semantics.

### Not implemented

- Upstream body cleanup beyond copy normalization, including Chromium origin-line
  handling and embedded-image placement.
- Summary-derived icon guessing, urgency shapes, notification-image masking, and
  application-icon badges.
- Quickshell-owned daemon behavior: `NotificationServer`, popup host and
  timeouts, persistence/history, accurate arrival times, and native image data.
- Directional swipe actions after the native daemon exists: swipe right
  dismisses; swipe left postpones the notification and reintroduces it after a
  configurable delay as a newly received notification, including normal
  ordering, unread, and popup behavior.

## Next implementation priorities

1. **Quickshell-owned daemon and popup host.** Reach feature parity with Mako
   before switching ownership of `org.freedesktop.Notifications`.
2. **Directional swipe actions.** Once Quickshell owns retained notification
   state, swipe right dismisses and swipe left postpones.

## Features to defer

- **Advanced icon/image treatment:** summary-derived Material fallback selection,
  urgency shapes, image masking, and application-icon badges need a separate
  visual design pass. True image behavior is also limited by Mako's JSON.
- **Body normalization beyond copy:** Chromium origin-line cleanup is not useful
  for the current browser setup, while embedded-image placement cannot be tested
  meaningfully until a backend exposes images.
- Qt5Compat opacity masks and rich image masking.
- Popup hover timeout cancellation, which belongs with a future native popup
  host.
- Full translation infrastructure.

These are polish, backend, or unused-sender concerns rather than prerequisites
for the current Mako first draft.
