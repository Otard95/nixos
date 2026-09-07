# Notification implementation — current state

This document gives the current notification state. Use
[`notification-daemon-plan.md`](notification-daemon-plan.md) for the complete
implementation and test record.

## Commits since the initial baseline (`6a5b558`)

```
2295dd7  chore(scripts): Add notification fixture tooling
9ce1ed4  refactor(notifications): Reconcile typed entries and groups by identity
e6ca7b1  feat(notifications): Animate expand/collapse and stabilise list geometry
d088645  feat(notifications): Position groups from instant heights via a reactive map
19afb07  feat(notifications): Add swipe dismissal
0c8be5d  docs(notifications): Update status after swipe dismissal implementation
0d95d27  feat(notifications): Add resisted swipe breakaway
c4d17a7  feat(notifications): Chain nearby elements during swipe
866e1e8  feat(notifications): Use hysteresis for swipe breakaway
```

## Architecture (stable)

```
MakoStrategy / NotificationFixtureStrategy / QuickshellStrategy
    → list<NotificationRecord> + popup IDs
Notifications facade
    → center and popup lists of NotificationEntry/NotificationGroup
NotificationList / NotificationPopupHost
    → NotificationListView → NotificationGroup → NotificationItem
```

The UI imports only the `Notifications` singleton. No UI file reads Mako JSON,
runs `makoctl`, or accesses a native Quickshell notification object directly.
A conditional loader constructs only the selected backend.

Source types (`Sources/Notifications/`):
`NotificationBackend`, `NotificationRecord`, `NotificationAction`,
`NotificationEntry`, `NotificationActionEntry`, `NotificationGroup`

## Backend selection

`QS_NOTIFICATION_BACKEND` selects the backend at Quickshell process start.

| Value | Backend | D-Bus behavior |
|---|---|---|
| `native` | `QuickshellStrategy` | Owns `org.freedesktop.Notifications`. |
| `mako` | `MakoStrategy` | Reads Mako state. Mako must own the name. |
| `fixture` | `NotificationFixtureStrategy` | Does not create a notification server. |

An unset or invalid value selects `native`. The native backend is the current
default.

Set the variable in the systemd service environment from the Nix option that
selects the notification provider. When `mako` is not selected, do not install
Mako or its D-Bus activation file. Otherwise D-Bus can start Mako when no daemon
owns the notification name.

## How positioning works (the solved problem)

The top-level list is a `Flickable` + `Repeater`, not a `ListView`. Each
group delegate publishes its instant settled height into a reactive
`groupId → height` map on the list (`reportHeight`). Every group's `y` is a
binding over `Notifications.groups` order and that map — no `itemAt` reads
across sibling delegates, which are method calls and not reactive. A
`Behavior on y` at 200ms `OutCubic`, matched to the group card's own height
animation, keeps neighbours moving in lockstep.

Why instant heights work for lockstep motion: both the card's visual height
animation and the neighbour's `y` animation are driven by the same delta with
the same duration and easing, so they stay at the same fraction of their
respective displacements at every frame and settle simultaneously. A live
(animating) published height would cause the neighbour to chase a moving
target and settle late.

Item layout height is instant (no `Behavior on implicitHeight` on the item).
The group card animates its own visual `implicitHeight` and reveals content
via `clip`. Body text visibility is gated by the `expanded`/`compact` flag
directly, so a group's `settledHeight` is exact the moment its state flips.

ScriptModel reconciliation (not `ListView` transitions) is what makes
delegates persist across reorders. A reorder emits a model move, not a
remove + add, so a group's delegate survives with its `y` binding re-targeting
to the new cumulative offset and animating there.

## How swipe dismissal works

Collapsed groups and expanded individual items support horizontal mouse drag
and trackpad scroll. A `MouseArea` above the top-level `Flickable` intercepts
horizontal wheel events before the Flickable consumes them, preserves vertical
scrolling, hit-tests the group or item under the pointer, and routes the delta
to that delegate. Mouse input uses a local `DragHandler`.

Raw input displacement (`swipeOffset`) is separate from rendered displacement
(`dragOffset`). While attached, a static attraction curve resists movement
toward the resting position. Cursor-space hysteresis detaches at 100px, after
which the card targets raw input directly; attraction reconnects only after the
cursor returns inside 70px. A 50ms target animation smooths both transitions
without frame-driven physics calculations. Releasing while attached snaps back;
releasing while detached animates off-screen and dismisses the group or item.

Nearby groups, or sibling items within an expanded group, follow the active
rendered offset by `0.15 ^ indexDistance`. Their target becomes zero while the
active delegate is detached, so they smoothly return home during breakaway and
reconnect when attraction returns. Expanded group headers move the whole group;
expanded items remain independently swipeable.

The feel is intentionally easy to tune in the swipe owners and coordinators:

```qml
readonly property real detachThreshold: 100
readonly property real dismissThreshold: 70
readonly property real attractionStrength: 32
readonly property int dragSmoothingDuration: 50
readonly property real chainDistanceFactor: 0.15
```

## What is complete

- Strict typed backend/facade/UI boundary.
- Mako polling, DND, individual/group/all dismissal, action invocation.
- Grouping by desktop entry → normalised app name, newest-first.
- Facade reconciliation: entries and groups retained by ID, updated in place,
  removed with a 250ms delay for future exit animations.
- Collapsed groups: compact 80px card (or shorter for single-item groups),
  up to two elided previews, second faded when count > 2.
- Expand/collapse: chevron or right-click, expansion state retained by
  group ID across polls, reorders, and panel close/open.
- Middle-click dismissal at group and item level.
- Expanded items: wrapped rich text, external links, sender action buttons.
  A sole default/open-style action becomes the item's left-click target.
  Copy-to-clipboard with plain-text normalisation.
- App icon resolution: sender image, existing app icon, existing app name,
  category Material icon, then a bell fallback.
- Friendly time labels: Now / Nm / Nh / Yesterday / Month D / Month D, YYYY.
- Top-level reorder/insert/remove: animates cleanly, always settles at correct
  geometry, confirmed by user.
- Swipe dismissal for collapsed groups, expanded group headers, and expanded
  items via mouse drag and trackpad horizontal scroll, including resisted pull,
  hysteretic detach/reattach, cancellation snap-back, off-screen dismiss travel,
  and smoothed chained movement of adjacent groups or sibling items.
- Fixture tooling (`scripts/notification-fixtures`,
  `scripts/notification-grouping-sequence.json`).
- Popup-aware backend and facade contracts, collection-scoped dismissal, and
  separate popup grouping while sharing stable presentation entries.
- Conditional Mako, fixture, and native backend construction with a typed null
  fallback. Declaring the inactive native loader does not claim D-Bus.
- IPC-driven fixture backend for controlled receipt, replacement, actions,
  urgency, transient/resident flags, DND, expiry, and hover behavior.
- Focused-monitor overlay popup host using shared notification delegates and a
  rendered-content input mask. The host has a 400px list width, 6px top inset,
  and no right inset.
- Native live binding and strategy code for tracking, typed field/action mapping,
  coalesced replacement observation, close handling, native dismissal/action
  dispatch, unread state, reload-generation suppression, and protocol IDs.
- Centralized native popup scheduler for sender/default/zero/critical timeouts,
  hover pause/resume, visible replacement restart, and transient popup hiding.
- Versioned native history with session/protocol reconciliation, immediate live
  bindings, pending-state handling, actionless restored records, distinct live
  operations, bounded retention, schema validation, and delayed atomic writes.
- Central multi-monitor status-panel tracking and reason-based popup inhibition.
  Native and fixture backends hide active popups and block new popups until all
  status panels close.
- Urgency/read policy: critical notifications bypass DND, low urgency is
  center-only and unread, and transient entries remain in memory until panel
  close marks them read and removes them.
- Popup borders: accent for normal and low groups. Red for any group that
  contains a critical notification.
- Notification images: a single-item group uses its image as the group icon.
  An expanded multi-item group shows images on individual items only.

The native backend is the current default. It owns the notification D-Bus name
when the system configuration does not install or start Mako.

## Native test results

The controlled tests covered D-Bus ownership, receipt, sender close, user
dismissal, replacement, default and zero timeouts, DND, urgency, panel
inhibition, hover pause, transient retention, resident actions, markup,
`image-data`, persistent `image-path`, grouped dismissal, timer IDs, hot reload,
full restart, and malformed history recovery.

The tests found and fixed a `DocumentStore` readiness race, a cross-reload
history-write race, and null model reads during delegate teardown.

## Limits and deferred work

- **Satty images:** Satty deletes its temporary `image-path` file as `Notify`
  returns. QML cannot copy the file before deletion. The UI falls back to the
  app icon. An upstream Quickshell change must read `image-path` during `Notify`.
- **Action labels:** Quickshell 0.3.0 drops a replacement that changes only an
  action label. Its native `NotificationAction::setText` guard is inverted.
- **Link cursor:** Rich-text links open, but they do not show a pointer cursor.
- **Lock behavior:** Hyprlock covers the popup layer. Popup timers continue
  while locked. Lock-state tracking remains optional.
- **Read state:** Closing a status panel marks all notifications read. Per-item
  read state is deferred.
- **Postpone gesture:** Swipe left can later postpone a native notification.

## Handover work

1. Set `QS_NOTIFICATION_BACKEND` from the Nix notification-provider option.
2. Do not install Mako when the provider is `native`.
3. Make `ffmpeg` available to Quickshell for image-cache downscaling.
4. Change the hypridle resume command to call `CloseNotification`.

The detailed persistence design is in
[`notification-persistence.md`](notification-persistence.md). The complete
implementation record is in
[`notification-daemon-plan.md`](notification-daemon-plan.md).

## Deferred

- Urgency shapes, image masking, icon badges — needs a visual design pass.
- Chromium body cleanup and embedded-image placement — not testable without
  image data from the backend.
- `Qt5Compat` opacity masks.
- Full translation infrastructure.
