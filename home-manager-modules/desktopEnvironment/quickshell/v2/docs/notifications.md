# Notification implementation — current state

This document supersedes the earlier animation handover. The top-level
positioning defect described there is resolved. The document now records what
is complete, what is partial, and what remains, for any future agent picking
up notification work.

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

The UI imports only the `Notifications` singleton. The backend boundary is
enforced: no UI file reads Mako JSON, runs `makoctl`, or accesses native
Quickshell notification objects directly. Backend construction is conditional;
Mako remains the default, and the native `NotificationServer` is not constructed
unless native mode is explicitly selected.

Source types (`Sources/Notifications/`):
`NotificationBackend`, `NotificationRecord`, `NotificationAction`,
`NotificationEntry`, `NotificationActionEntry`, `NotificationGroup`

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
- Application icon with desktop-entry fallback, then Material symbol fallback.
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
- Initial focused-monitor overlay popup host using the shared notification
  delegates and a rendered-content input mask.
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
- Initial urgency/read policy: critical notifications bypass DND, low urgency is
  center-only and unread, and transient entries remain in memory until panel
  close marks them read and removes them.

The default remains Mako. An initial controlled native ownership test passed,
and Mako ownership was restored after the test.

## What is partial or backend-limited

- **Timestamps** are first-observed Mako poll times, not sender arrival times.
- **Images** are typed and have a UI slot but Mako's `list -j` does not expose
  image data. Application icons work; notification images need a native backend.
- **Unread count** resets when a status panel closes. Per-entry read tracking is
  deferred.
- **Actions** rely on Mako's semantics and only work for live entries.

## Native test findings

The second native ownership test confirmed sender close, hidden replacement,
default timeout, transient-under-DND, resident actions, markup, `image-path`,
`image-data`, grouped dismissal, timer IDs, and malformed-history recovery. It
fixed a cross-reload persistence write race and null-delegate teardown warnings.

Open native items:

- **Sender images.** `NotificationImageCache` copies the sender file on
  receipt, downscales it with `ffmpeg`, persists the thumbnail, and deletes it
  on dismissal. This adds an `ffmpeg` handover dependency. It cannot capture
  apps that delete their temporary file before the QML receipt handler runs
  (for example Satty), because Quickshell reads `image-path` lazily. A failed
  capture falls back to the app icon. `image-data` and persistent files work.
- **Group images.** Single-notification groups show the image as the group
  icon; multi-notification groups show per-item thumbnails when expanded.
- **Upstream action-text bug.** Quickshell 0.3.0 drops action-label-only
  replacement changes through an inverted `setText` guard.
- **Link cursor.** Rich-text links activate but lack a pointer cursor.
- **Idle-notification handover.** hypridle resume must use `CloseNotification`,
  not `makoctl`. This belongs in the user's Nix configuration.

## What is not implemented

- Advanced icon treatment: urgency shapes, image masking, app-icon badges,
  summary-derived Material icon guessing.
- Lock-screen popup inhibition. Validated that the Hyprland lock surface covers
  the popup layer, so content is hidden while locked. An explicit inhibitor is
  optional; popup timers still run while locked.
- Remaining native edge cases in the required test matrix.
- Permanent native selection and removal of the Nix-managed Mako service.
- **Directional swipe actions (native-daemon dependent):** swipe right dismisses;
  swipe left postpones the notification. A postponed notification is retained by
  Quickshell and reintroduced after a configurable delay as though newly
  received, including normal ordering, unread, and popup behavior.

## Next substantial priority

Run the remaining ownership cases before permanent handover. Priorities are
sender close, hidden replacement, default timeout, transient under DND,
resident actions, image and markup handling, grouped dismissal, malformed
history, and timer notification IDs. Lock detection remains deferred.

The initial controlled test passed for ownership transfer, urgency, DND, panel
inhibition, replacement, timeout, hover, transient retention, actions, reload,
and restart persistence. Editing `shell.qml` caused an in-process reload with a
stable PID and `lastGeneration` replay. A service restart restored actionless
history under a new daemon-session ID without unread or popup state.

The restart test also found a shared `DocumentStore` readiness bug. The store
published `ready` before assigning its loaded document. It now assigns document
and error state first, so consumers cannot finalize from stale defaults.

The full checklist is in
[`notification-presistence-reconsiliation.md`](../notification-presistence-reconsiliation.md).
Directional dismiss/postpone gestures can follow after native state passes the
ownership and restart tests.

## Deferred

- Urgency shapes, image masking, icon badges — needs a visual design pass.
- Chromium body cleanup and embedded-image placement — not testable without
  image data from the backend.
- `Qt5Compat` opacity masks.
- Full translation infrastructure.
