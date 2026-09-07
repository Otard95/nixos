# Quickshell native notification daemon record

> **Current state:** `native` is the default backend. `QS_NOTIFICATION_BACKEND`
> selects `native`, `mako`, or `fixture`. The Nix notification-provider option
> must remove Mako when it selects `native`.
>
> This document retains implementation checkpoints and research decisions. Use
> [`notifications.md`](notifications.md) for the current behavior and handover
> work.
>
> **Runtime researched:** Quickshell 0.3.0 from Nixpkgs. Re-check version-specific findings before upgrading Quickshell.

## Implementation checkpoint — `ab6f48e`

The first implementation checkpoint is:

```text
ab6f48e feat(notifications): Add popup backend foundation
```

### Completed

- Added `category` to `NotificationEntry` and copied it through the facade, restoring the timer cleanup contract.
- Extended `NotificationBackend` with `popupNotificationIds`, `notificationUpdated`, popup hover control, and popup hide operations. Mako inherits safe empty defaults.
- Added facade-level `popupNotifications`, separately reconciled `popupGroups`, `dismissMany`, and group-hover forwarding. Popup and center groups share stable `NotificationEntry` objects but use separate `NotificationGroup` objects.
- Parameterized `NotificationListView` with an injected typed group list instead of hardcoding `Notifications.groups`.
- Changed rendered group dismissal to dispatch the notification IDs present in that group. A popup group therefore cannot dismiss older center-only entries with the same application group ID.
- Added `NullNotificationStrategy` as the typed fallback while conditional loaders change state.
- Changed Mako construction to a conditional `LazyLoader` and added a separately conditional fixture loader. The default remains `mako`; the fixture backend and popup host do not instantiate `NotificationServer`.
- Added `NotificationFixtureStrategy` with an IPC endpoint for controlled receipt, same-ID replacement, close, and reset. It supports typed actions, urgency, transient/resident flags, DND, popup membership, expiry, and hover pause/resume.
- Added the initial overlay `NotificationPopupHost`, using the existing group/list delegates, focused-monitor placement, and a `Region` input mask limited to the rendered popup list.
- Smoke-tested fixture receipt and same-ID replacement through `notificationFixtures.receive`. The popup host loaded and rendered fixture state without notification-related runtime errors.
- Restart-tested the normal Mako mode. Mako remains active and continues to own `org.freedesktop.Notifications`; Quickshell does not currently construct a notification server.

### Deviations and sequencing changes

- Part of popup-controller behavior was implemented in the fixture backend earlier than sequence step 5. This provides deterministic expiry and hover tests for the popup UI without implying that the fixture scheduler is the final native controller.
- The initial popup host was added during the fixture-backend checkpoint rather than waiting for a separately completed popup-design phase. This was necessary to smoke-test the new popup facade collections end to end.
- At the first checkpoint, backend mode was a local `backendMode` property with only `mako` and `fixture` loaders. Native construction was intentionally deferred until `QuickshellStrategy` existed; the native loader has since been added without changing the Mako default.
- Fixture mode is currently selected by temporarily changing `backendMode` and restarting the managed service. No runtime backend-switch IPC/configuration API was added, avoiding an unnecessary production control surface.
- The popup host currently imports `Quickshell.Hyprland` directly for focused-monitor placement and falls back to the first screen. A backend-neutral focused-screen property has not been added to `WM` yet.
- The proposed separate `NotificationPopup.qml` wrapper was not needed for the first checkpoint; `NotificationPopupHost.qml` directly hosts the reusable `NotificationListView`. This can be split later if popup-specific presentation grows.
- Lock-screen suppression remains deferred. Status-panel inhibition is implemented and passed its native runtime test.

### Native live-binding checkpoint

The next implementation unit added:

- `NativeNotificationBinding.qml`, committed as `f35ef46 feat(notifications): Add native notification binding`.
- A typed `NotificationRecord` owned by each live binding, including native application metadata, category, body, image, urgency, transient/resident state, and copied actions.
- Zero-delay coalescing for the multiple native property signals emitted by one replacement.
- In-place action reconciliation and explicit backend update notification without changing the record ID or arrival timestamp.
- Native action lookup/invocation and close forwarding.
- `QuickshellStrategy.qml`, committed as `5e261e0 feat(notifications): Add native notification strategy`; it remains uninstantiated in the default Mako mode.
- A `NotificationServer` handler whose first operation is `notification.tracked = true`.
- Live binding/record lookup by numeric protocol ID represented as a string, unread handling, native dismissal/action dispatch, sender-close cleanup, reload-generation suppression, image mapping, DND collection, and inhibited transient expiry.
- The planned capability set and `keepOnReload: true`.

The strategy was syntax-loaded inside a temporary inactive `Component`; this parsed the complete strategy without constructing `NotificationServer`. Mako remained active and retained `org.freedesktop.Notifications` throughout validation.

### Native live-binding deviations and limitations

- The initial strategy checkpoint established popup membership without scheduling expiry. The dedicated native popup controller has since added timeout, hover, and visible-replacement deadline behavior.
- `lastGeneration` notifications are retained without unread or popup state, but durable identity and original timestamps cannot be restored until persistence and daemon-session reconciliation are implemented.
- `persistenceSupported` is configured according to the final planned capability set even though the strategy is not selectable yet. Native mode must not be used as the session daemon until persistence is implemented and tested.
- Close reasons are received by each binding but are not exposed through the backend contract because all native close reasons currently require the same local removal path.
- Duplicate protocol IDs are treated as an invariant violation and dismissed. Ordinary Freedesktop replacements do not take this path because Quickshell updates the existing native object without re-emitting `NotificationServer.notification`.

### Conditional native-loader checkpoint

`Sources/Notifications.qml` now declares a third conditional `LazyLoader` for `QuickshellStrategy`. It participates in the same typed null-backend fallback as Mako and fixture mode, while `backendMode` still defaults to `mako`.

A managed-service restart confirmed that merely declaring the inactive loader does not construct `NotificationServer`: both services remained active and Mako retained `org.freedesktop.Notifications`.

### Native popup-controller checkpoint

`NotificationPopupController.qml` now owns popup membership and uses one centralized deadline scheduler. `QuickshellStrategy` delegates popup creation, hiding, hover state, replacement updates, and timeout handling to it.

Implemented policy:

- explicit positive timeouts use the sender-provided millisecond value;
- `-1` uses the local five-second default;
- `0` has no automatic timeout;
- critical notifications have no automatic timeout;
- hover pauses and resumes the remaining duration;
- replacement restarts the timeout only while the popup is still visible;
- hidden replacements do not reappear;
- DND hides existing popups and disabling it does not replay them;
- non-transient timeout removes only popup membership;
- transient timeout removes only popup membership; the center retains the entry until it is read;
- actions hide popup membership before native invocation;
- native closure removes all scheduler state for the notification.

The controller first passed syntax checks through the inactive native loader. The later controlled ownership test verified its runtime deadline and hover behavior.

### Initial urgency, transient, and read policy

Critical notifications bypass DND but not status-panel inhibition. They do not expire automatically. Low-urgency notifications enter the center, remain unread, and persist unless transient, but they do not create popups.

Transient notifications always enter the in-memory center and never persist. When allowed, they create popups. Popup timeout hides only the popup. A transient entry remains in the center until read.

Closing a status panel marks all notifications as read. This read action expires and removes live transient entries. This simple global rule can later become per-entry read tracking.

Visible replacements are checked against the current policy. A replacement hides its popup if it becomes low urgency or DND makes it ineligible. A hidden replacement does not create a new popup.

Fixture tests confirmed low-urgency suppression, critical DND bypass, transient retention while inhibited, and transient removal after `markAllRead()`.

### Replay completion finding

Quickshell 0.3.0 has no public `replayComplete` signal, but its implementation provides a usable version-specific barrier. `NotificationServerQml::onPostReload()` calls `NotificationServer::switchGeneration()`. That function emits `trackedNotificationsChanged` through its clear hook immediately before synchronously looping over retained notifications and emitting each one with `lastGeneration` set.

Therefore, a zero-delay reconciliation pass scheduled from `trackedNotificationsChanged` runs only after the synchronous replay loop returns to the event loop. This can serve as `nativeReplayComplete` for both cases: a reload with retained notifications and a process start/restart with an empty replay set. The signal itself is not the completion point; the deferred callback is.

This behavior is implementation-specific to the researched Quickshell 0.3.0 code and must be regression-tested and rechecked after upgrades. Ordering against `PersistentProperties.loaded` and `DocumentStore.ready` still needs an order-independent state machine, but absence of a public completion signal no longer requires an arbitrary time-based grace period.

### Persistence reconciliation decision

Persistence will use incremental, order-independent reconciliation rather than gating correctness on native replay completion:

1. Every native handler sets `notification.tracked = true` first.
2. A `NativeNotificationBinding` is created immediately so arrival time, replacements, and sender closure are observed while initialization is pending.
3. Bindings remain staged until both `PersistentProperties.loaded` and `DocumentStore.ready` establish `sessionIdentityReady` and `historyStoreReady`.
4. Initial processing indexes persisted candidates by `(originatingDaemonSessionId, originatingProtocolId)`, reconciles staged `lastGeneration` bindings, classifies ordinary bindings as new, restores unmatched persisted candidates as history, and publishes the merged result.
5. Reconciliation remains open afterward so a late `lastGeneration` binding can still upgrade a matching restored record.

The replay-complete barrier is retained as a version-specific diagnostic and potential presentation optimization, not a correctness requirement. Replay is synchronous and normally completes before rendering, so no loading UI will be added initially. If persistence loading causes a visible empty-state flash, expose an initialization property and add a small loading placeholder later.

The current `receive()` will be split into immediate binding creation and later classification/publication. Raw native objects will not be queued without bindings. Live records retain numeric protocol IDs as strings; restored records use `history:<durable-id>`. Restored actions remain empty, transient records are not serialized, and live versus historical dismissal/action behavior remains distinct.

### Native persistence checkpoint

The native strategy now creates each binding immediately and stages it until session identity and history are ready. `PersistentProperties` keeps the daemon-session ID across a configuration reload and creates a new ID after a process restart.

`NotificationHistory.qml` owns a versioned `DocumentStore`. It validates unique durable IDs and reload keys, limits history to 200 entries and 30 days, and delays writes for 150 ms. Invalid documents remain unchanged. The store excludes actions, unread state, popup state, transient notifications, native references, and process-backed images.

Initial reconciliation processes staged replay bindings before ordinary bindings. It matches replay bindings by daemon session and protocol ID, restores unmatched entries as actionless history, and publishes one sorted record list. Reconciliation remains active for late replay bindings. Pending bindings observe replacements and sender closure.

Live and restored records use separate lookups and operations. Live records keep numeric protocol IDs as strings and call native dismissal or actions. Restored records use `history:<durable-id>`, have no actions, and use local dismissal. The strategy writes bounded history after receipt, replacement, closure, dismissal, and initial reconciliation.

The inactive native loader first parsed the complete implementation. The later native ownership test verified history restoration and hot-reload reconciliation.

The original persistence checklist is
[`notification-persistence.md`](notification-persistence.md).

### Status-panel popup inhibition checkpoint

`StatusPanelState` now tracks each status-panel instance with a lifetime-unique ID. Its non-persistent `anyOpen` property stays true until all panel instances close or leave the component tree.

The notification facade now owns a reason-based inhibitor map. The `status-panel` reason follows `StatusPanelState.anyOpen`. A later lock-state source can add `session-lock` without clearing an active panel reason.

The backend contract now exposes popup inhibition. Native and fixture backends hide visible popups when inhibition starts and block new popups while it remains active. They continue to collect normal center entries and do not replay hidden popups when inhibition ends. Mako receives the state but keeps its existing external-daemon behavior.

The implementation uses new map objects where QML bindings need change signals. Internal non-reactive collections continue to use direct mutation.

### Lock detection deferred — lock surface covers popups (validated)

A controlled lock test confirmed that the Hyprland lock surface (hyprlock) fully covers the overlay popup layer. Popups present before the lock, and popups created while locked, are hidden by the lock surface. No notification content was visible while locked.

Consequence: an explicit lock-state inhibitor is not required for basic privacy under this compositor. It remains optional for stricter behavior.

Remaining caveats, not yet addressed:

- Popup timeout timers keep running while locked. A short-lived popup sent during lock can expire unseen. Pausing popup deadlines while locked would need the deferred lock-state source.
- Persistent popups (`expire-time=0`) remain and become visible immediately on unlock, which is expected after the user authenticates.
- This is compositor-specific. A different compositor or lock method must be re-tested.

### Initial controlled native ownership test

The controlled test temporarily selected native mode and stopped Mako. Quickshell waited while Mako owned `org.freedesktop.Notifications`, then claimed the name after Mako stopped.

Runtime checks passed for normal, low, and critical urgency; DND; status-panel inhibition; same-ID replacement; sender timeouts; zero timeout; hover pause and resume; transient center retention and read removal; action dispatch; native dismissal; hot-reload replay; and full-restart history restoration.

Editing `shell.qml` caused an in-process reload. The process ID stayed stable, the live notification replayed with `lastGeneration: true`, and no popup replayed. A managed service restart created a new daemon session and restored persisted records with `history:` IDs, no unread state, and no popup state.

The restart test found a shared `DocumentStore` readiness bug. The store set `ready=true` before assigning its loaded document, so notification initialization could consume empty defaults. `DocumentStore` now assigns the document and error state before publishing readiness.

After the test, the configuration returned to Mako mode. Quickshell and Mako are active, and Mako owns the D-Bus name. Test-only IPC and shell edits were removed. Native lifecycle logs remain for later diagnosis.

### Second native ownership test

A second controlled test extended coverage with per-decision logging and a test IPC probe. All cases used non-sensitive notifications.

Passed cases:

- Sender close through `CloseNotification`, reported as `CloseRequested`.
- Hidden replacement did not create a new popup.
- Default timeout used the local five-second value.
- Transient under DND stayed in the center and created no popup.
- Resident action kept the notification after a direct D-Bus action invocation.
- Markup rendered bold, italic, and links, and stripped `<script>` content.
- `image-path` with a persistent file rendered the image.
- `image-data` mapped to the `image://qsimage` provider and rendered.
- Grouped popup dismissal did not affect center-only entries.
- Timer category and numeric IDs mapped correctly and dismissed by ID.
- A malformed history file was not overwritten and the backend stayed live.

Fixed during this test:

- Hot reload could destroy live entries while a debounced or active history write was still pending. The next generation then restored a stale record and produced a visible duplicate. The strategy now buffers the latest bounded history snapshot as a JSON string in reload-preserved `PersistentProperties` and reads it when a write is still pending. The buffer clears after the store confirms the save.
- Notification delegates read a destroyed model entry during whole-generation teardown, which logged null-property errors. The delegates now read the entry defensively.

Known limitations found:

- **Upstream action-text bug.** Quickshell 0.3.0 and current master invert the guard in `NotificationAction::setText`, so a replacement that changes only an action label is dropped inside Quickshell before QML can read it. A replacement that changes the action identifier still works. This is not fixable in QML without direct D-Bus interception.
- **Transient sender images.** Partly addressed. The receipt-time image cache copies and downscales any sender file that still exists when the QML receipt handler runs, then persists the thumbnail. It does not help applications that delete their temporary file before the handler runs. Satty writes a temporary file, calls `Notify`, and deletes the file the instant the call returns. Quickshell reads `image-path` lazily, not during the D-Bus call, so the file is already gone. Mako reads it eagerly inside the call and therefore shows it. A failed capture now clears the broken image and falls back to the app icon. A real fix needs an upstream eager `image-path` read in Quickshell's C++ notification server. `image-data` and files that persist are cached correctly.
- **Group images.** A group with more than one notification shows only one group icon. Per-notification images are not shown in expanded groups yet.
- **Link cursor.** Rich-text links activate correctly, but the pointer cursor over a link is not resolved yet. Low priority.
- **Idle-notification handover.** The user's hypridle resume command used `makoctl dismiss`, which fails in native mode. The fix is a backend-neutral `CloseNotification` call and belongs in the user's Nix configuration. `notify-send` cannot close a notification.

### Receipt-time image cache

`NotificationImageCache.qml` solves transient sender images. On receipt of a notification whose image resolves to a local file, it copies the file into a state cache directory, then downscales the copy with `ffmpeg` to a bounded thumbnail. The fast copy captures the file before the sender deletes it; the downscale keeps the cache small.

The cached URL is authoritative. `NativeNotificationBinding` holds a `cachedImageOverride` so the coalesced `synchronize` cannot restore the dead sender path. The cached path is persisted in history, so it survives reload and full restart. `applyPersistedIdentity` restores the override for replayed live notifications.

The cache deletes a file when its notification is dismissed, clears all files on dismiss-all, and sweeps unreferenced files at initialization. `image-data` and persistent `image-path` values bypass the cache and render directly.

The facade `notificationUpdated` signal drives the image refresh. A plain records reassignment with identical objects does not emit a QML list change, so it cannot be used for in-place field updates.

This adds an `ffmpeg` runtime dependency. Record it as a native handover dependency.

### Next implementation step

Add per-item images in expanded groups. The link cursor and the upstream action-text limitation are lower priority. Keep lock detection deferred.

After the remaining parity items, disable the Nix-managed Mako service and change the backend default to native in one coordinated change.

## Where to start

Read these local documents first:

- [`docs/notifications.md`](docs/notifications.md) — current notification implementation and completed UI behavior.
- [`research/upstream-notifications.md`](research/upstream-notifications.md) — detailed comparison with the checked-out upstream shell.
- [`research/notification-overview.md`](research/notification-overview.md) — concise upstream daemon overview.
- [`Sources/DocumentDb/README.md`](Sources/DocumentDb/README.md) — local validated persistence API.
- [`docs/timers.md`](docs/timers.md) — timer integration and notification acknowledgement constraints.

Current local implementation entry points:

- [`Sources/Notifications.qml`](Sources/Notifications.qml) — stable facade, reconciliation, grouping, and backend selection.
- [`Sources/Notifications/NotificationBackend.qml`](Sources/Notifications/NotificationBackend.qml) — backend contract to extend.
- [`Sources/Notifications/MakoStrategy.qml`](Sources/Notifications/MakoStrategy.qml) — currently active backend and useful behavioral reference.
- [`Sources/Notifications/NotificationRecord.qml`](Sources/Notifications/NotificationRecord.qml) — backend-neutral record.
- [`Sources/Notifications/NotificationEntry.qml`](Sources/Notifications/NotificationEntry.qml) — presentation record.
- [`Modules/StatusPanel/Notifications/`](Modules/StatusPanel/Notifications/) — existing notification center UI and reusable delegates.
- [`shell.qml`](shell.qml) — per-screen window composition and popup-host integration point.

## Recommendation

Keep the existing typed architecture, but do **not** implement the daemon as one large `QuickshellStrategy.qml` modeled directly on upstream.

The best structure is:

```text
NotificationServer
        ↓
QuickshellStrategy
  ├── live notification bindings
  ├── retained/history records
  ├── popup lifecycle controller
  └── DocumentStore persistence
        ↓
NotificationBackend contract
        ↓
Notifications facade
  ├── center entries/groups
  └── popup entries/groups
        ↓
center UI / popup host
```

The existing backend/facade separation is substantially better than upstream’s all-in-one singleton and should be preserved.

## Important findings beyond the baseline

### 1. A native strategy cannot be instantiated harmlessly beside Mako

Constructing Quickshell's [`NotificationServer`](https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Notifications/NotificationServer/) immediately attempts to register:

```text
org.freedesktop.Notifications
```

If Mako owns it, Quickshell waits and automatically claims it when Mako disappears. Therefore, merely instantiating a dormant `QuickshellStrategy` could unexpectedly take over after a Mako crash while the facade is still using `MakoStrategy`.

The native backend must be conditionally instantiated, not merely instantiated and left unselected. During final handover, the facade, popup host, and native strategy must already be wired together before stopping Mako.

### 2. Expiry units are now verified

The installed version is:

```text
Quickshell 0.3.0
```

The [`Notification.expireTimeout`](https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Notifications/Notification/#expireTimeout) documentation incorrectly describes the value as seconds. Quickshell's [`Notification::updateProperties`](https://github.com/quickshell-mirror/quickshell/blob/v0.3.0/src/services/notifications/notification.cpp) assigns the D-Bus `INT32 expire_timeout` directly without conversion, so the runtime property is effectively **milliseconds**, matching the [Freedesktop `Notify` protocol](https://specifications.freedesktop.org/notification/latest/protocol.html#command-notify) and QML `Timer.interval`.

No runtime conversion should be applied.

### 3. Replacement notifications need explicit observation

Quickshell handles [`replaces_id`](https://specifications.freedesktop.org/notification/latest/protocol.html#command-notify) in [`NotificationServer::Notify`](https://github.com/quickshell-mirror/quickshell/blob/v0.3.0/src/services/notifications/server.cpp) by updating the existing `Notification` object. It does **not** emit `NotificationServer.notification` again.

Consequences:

- The native strategy must connect to notification property-change signals.
- It must update the existing `NotificationRecord` in place.
- It must explicitly notify the facade because changing a child record does not emit `notificationsChanged` for an unchanged QML list.
- Replacement must preserve record/delegate identity and restart popup policy without remove/add flicker.

A small zero-delay reconciliation timer can coalesce the multiple property signals emitted by one replacement.

Replacement policy is deterministic and does not use content heuristics. A replacement is an update to the same protocol notification, not a newly received notification:

- update the existing record in place;
- preserve its original arrival/order timestamp and unread state;
- optionally record a separate `updatedAt` timestamp;
- if its popup is currently visible, update it and restart the applicable timeout;
- if its popup has already disappeared, do not create a new popup;
- do not increment unread because fields changed.

There is also an apparent Quickshell 0.3.0/0.3.1 source defect in [`NotificationAction::setText()`](https://github.com/quickshell-mirror/quickshell/blob/v0.3.0/src/services/notifications/notification.cpp): the equality condition is reversed. An action label changed by a replacement may remain stale. This should be recorded as an upstream limitation and covered by a regression test.

### 4. Internal IDs should remain compatible with `notify-send --print-id`

The preliminary suggestion of generation-qualified IDs would break [`Sources/Timer.qml`](Sources/Timer.qml), which stores the numeric ID returned by `notify-send --print-id` and later calls:

```qml
Notifications.dismiss(String(notificationId))
```

Use:

```text
live entry:       "<protocol-id>"
restored history: "history:<durable-id>"
```

This avoids collisions without breaking external numeric IDs. The live protocol ID also naturally preserves identity across `replaces_id`.

### 5. The timer/category path is currently incomplete

[`NotificationRecord.qml`](Sources/Notifications/NotificationRecord.qml) contains `category`, but [`NotificationEntry.qml`](Sources/Notifications/NotificationEntry.qml) does not, and [`Sources/Notifications.qml`](Sources/Notifications.qml) does not copy it. Nevertheless, [`Sources/Timer.qml`](Sources/Timer.qml) searches:

```qml
entry.category
```

Before native-daemon work, add `category` to `NotificationEntry` and reconcile it through the facade. Otherwise timer cleanup by category cannot work reliably.

### 6. The existing list cannot be reused by the popup unchanged

[`NotificationListView.qml`](Modules/StatusPanel/Notifications/NotificationListView.qml) hardcodes `Notifications.groups`, and [`NotificationGroup.qml`](Modules/StatusPanel/Notifications/NotificationGroup.qml) directly calls global group dismissal.

For popup groups, this is dangerous: dismissing a popup group could dismiss older center-only notifications from the same application.

Refactor the visual layer so:

- `NotificationListView` accepts a typed `groups` property.
- Group dismissal operates on the IDs actually present in that rendered group.
- Prefer `Notifications.dismissMany(ids)` or delegate signals over globally resolving only `groupId`.
- Center and popup grouping can share the same `NotificationEntry` objects while maintaining separate `NotificationGroup` objects.

## Recommended backend contract extension

Keep the existing center contract and add only backend-neutral popup state:

```qml
property list<string> popupNotificationIds: []

signal notificationUpdated(notificationId: string)

function setPopupHovered(notificationId: string, hovered: bool): void
function hidePopup(notificationId: string): void
function hideAllPopups(): void
```

The facade should expose:

```qml
readonly property list<NotificationEntry> popupNotifications
readonly property list<NotificationGroup> popupGroups

function dismissMany(notificationIds: list<string>): void
function setPopupGroupHovered(notificationIds: list<string>, hovered: bool): void
```

Popup timers and transient/live semantics belong in the native backend or a helper owned by it. Popup QML should never touch native Quickshell `Notification` objects.

## Native record handling

Use a private binding object per live notification:

```text
NativeNotificationBinding
  ├── native Notification
  ├── typed NotificationRecord
  └── Connections to native property/closed signals
```

In `NotificationServer.onNotification`, the first operation must be:

```qml
notification.tracked = true
```

Quickshell discards an untracked notification when the signal handler returns. Tracking must therefore happen before creating bindings, consulting persistence, or applying popup policy. This also applies to an inhibited transient notification: track it first, then call `expire()` so the sender receives the appropriate close reason.

The public list still contains only `NotificationRecord`.

Map:

- `notification.id` → numeric string
- `appName`, `appIcon`, `desktopEntry`
- `hints.category` → `category`
- `summary`, `body`, `image`
- `urgency`
- `transient`, `resident`
- `Date.now()` → original arrival time for a new notification
- optional separate `updatedAt` for replacements
- copied typed actions
- private live-object lookup by notification ID

Operations must distinguish live and restored records internally:

| Operation | Live record | Restored historical record |
|---|---|---|
| Dismiss | Call `Notification.dismiss()` | Remove locally and persist |
| Invoke action | Find and invoke the native action | Unavailable; restored actions are empty |
| Sender close | Remove from the native `closed` handler | Not applicable |
| Popup eligibility | Apply normal popup policy | Never show automatically |
| `dismissMany` / `dismissAll` | Dispatch each record through its appropriate path | Dispatch each record through its appropriate path |

On native `closed`, remove the live lookup, popup membership, unread membership, and retained record. Do not call `dismiss()` again from the close handler.

## Popup and expiration policy

Use one scheduler/controller rather than one loose `Timer` per notification. Track:

```text
notificationId → deadline, remainingMs, hovered
```

Recommended semantics:

- Explicit timeout `> 0`: use that many milliseconds.
- Timeout `-1`: use a configurable default.
- Timeout `0`: no automatic popup timeout.
- Critical notifications: never time out automatically.
- Hover: pause and later resume the remaining duration.
- Replacement: update in place and restart its deadline only when its popup is already visible; do not re-popup a hidden replacement or change its unread state.
- DND or open notification center: inhibit new popups, but retain normal notifications and mark newly received notifications unread.
- Turning inhibition on hides existing popups; turning it off does not replay them.
- Non-transient popup timeout: remove popup membership but retain the notification center entry and live actions.
- Transient popup timeout: call `Notification.expire()` and remove it entirely.
- A transient notification received while popup presentation is inhibited should be expired rather than retained in history.
- Action invocation closes popup membership. Quickshell itself dismisses non-resident notifications; resident notifications remain in the center.
- User dismissal must call `dismiss()`, not `expire()`, so the sender receives the correct close reason.

Unread should be based on newly received IDs regardless of DND. Replacements preserve the existing unread state. Restored records should start read and must never create popups.

## Capabilities to advertise initially

Advertise only what the existing UI genuinely supports:

```qml
actionsSupported: true
bodySupported: true
bodyMarkupSupported: true
bodyHyperlinksSupported: true
imageSupported: true
persistenceSupported: true
```

Initially keep these false:

```qml
actionIconsSupported: false
bodyImagesSupported: false
inlineReplySupported: false
```

`bodyImagesSupported` is distinct from the notification’s main image and remains unsupported.

### Markup policy: YOLO option

The initial implementation will advertise markup and hyperlink support and continue feeding notification bodies to the existing `Text.RichText` renderer without first adding a Freedesktop-subset sanitizer. This deliberately accepts that Qt rich text supports more than the advertised protocol subset and that malformed or unexpected markup may expose behavior we have not handled yet.

If a real notification produces incorrect, unsafe, or surprising behavior, add sanitization or narrow the advertised capabilities then. Keep malformed markup, unsupported tags, embedded images, remote images, and unusual link schemes in the test matrix so failures are visible rather than silently assumed away.

Do not advertise sound support.

## Persistence

Use the local [`DocumentStore`](Sources/DocumentDb/DocumentStore.qml), not upstream’s raw `FileView`. It already provides schema validation, atomic writes, load rejection, and per-shell state/data paths.

Persist a versioned, bounded history document containing:

- durable history ID
- originating protocol ID for hot-reload reconnection only
- originating daemon-session ID paired with that protocol ID
- application/grouping fields
- category
- summary/body
- urgency
- timestamps
- resident/transient-derived presentation data as appropriate

Do not persist:

- actions
- native notification references
- popup membership or timers
- transient notifications
- unread status
- volatile in-memory image-provider URLs

Quickshell image-data URLs are process-backed and generally cannot survive a full restart. Native images will work while live, but restored history should normally clear such image URLs unless they refer to a verified persistent file.

Additional requirements:

- Merge restored history with notifications received before `DocumentStore.ready`; never overwrite early live notifications when loading completes.
- Make this merge order-independent: persistence may load before or after Quickshell re-emits a `lastGeneration` notification.
- A protocol ID alone is not a unique reload key: old history and a current live notification can share it after a full process restart.
- Match a re-emitted notification using the tuple `(originatingDaemonSessionId, originatingProtocolId)`, and only when its native object has `lastGeneration === true`.
- On reconnection, preserve the persisted durable ID and turn the restored record into the live record rather than publishing both.
- Never use an originating protocol ID by itself to deduplicate an ordinary notification after a full process restart; protocol IDs restart and may be reused.
- Do not write defaults over existing history before the store is ready.
- Bound retention, for example by both age and count.
- Invalid history should leave the daemon operational with in-memory defaults, matching `DocumentStore` behavior.

## Reload policy

Set:

```qml
keepOnReload: true
```

This preserves live Quickshell notification objects and action capability across configuration reloads. Handle `lastGeneration` notifications as already-existing live records:

- reconnect them using both the originating daemon-session ID and protocol ID;
- preserve the persisted durable ID;
- support either persistence-first or notification-first arrival order;
- do not duplicate restored history;
- do not increment unread;
- do not show a fresh popup solely because of reload.

The originating protocol ID is a reload-reconnection hint, not a globally durable identity.

### Open implementation checkpoint: daemon-session identity

The daemon needs a session ID that survives QML hot reloads but changes on a full Quickshell process restart. [`PersistentProperties`](https://quickshell.org/docs/v0.3.0/types/Quickshell/PersistentProperties/) is the leading implementation choice because it retains properties across configuration reloads without writing them as durable cross-process state.

Source inspection established a native replay barrier for Quickshell 0.3.0: `trackedNotificationsChanged` is emitted immediately before the synchronous retained-notification replay loop, so a zero-delay callback scheduled from it runs after replay completes. The remaining checkpoint is to verify `PersistentProperties.loaded`/`reloaded` and `DocumentStore.ready` ordering at runtime and implement reconciliation so either can precede replay. The required invariant is fixed even if the session mechanism changes: every live record persisted during a daemon process must carry the same session ID, and a newly started process must generate a different one.

A full process restart is different: only serialized history survives, with no actions.

## Popup host

Add a dedicated [`PanelWindow`](https://quickshell.org/docs/v0.3.0/types/Quickshell/PanelWindow/) loaded from [`shell.qml`](shell.qml):

- overlay layer
- zero exclusive zone
- right/top anchored
- transparent background
- input mask limited to visible popup cards
- target the focused monitor
- render `Notifications.popupGroups`
- suppress visibility while locked

The local shell currently has no obvious screen-lock state source. Lock suppression should be implemented or explicitly verified before declaring parity, because notification content must not leak onto a lock screen.

The status-panel open state is currently local to each per-screen [`StatusPanel`](Modules/StatusPanel/StatusPanel.qml). Popup inhibition needs a central multi-monitor-aware state, such as open panel IDs tracked by [`StatusPanelState`](Sources/StatusPanelState.qml).

## Proposed file split

```text
Sources/Notifications/
    QuickshellStrategy.qml
    NativeNotificationBinding.qml
    NotificationPopupController.qml
    NotificationHistory.qml
    NotificationFixtureStrategy.qml
    NullNotificationStrategy.qml
    NotificationBackend.qml
    NotificationRecord.qml
    ...

Modules/Notifications/
    NotificationPopup.qml
    NotificationPopupHost.qml
```

The existing status-panel delegates should remain shared, after making their model and collection-level actions injectable.

## Backend selection and fixture mode

Backend selection must control construction, not merely which already-created object the facade reads. Provide three modes:

```text
mako      → MakoStrategy
fixture   → NotificationFixtureStrategy
native    → QuickshellStrategy
```

Use a `LazyLoader` or equivalent conditional component loader so only the selected strategy is instantiated. Declaring `Component { QuickshellStrategy {} }` is safe; creating it constructs `NotificationServer` and attempts to claim D-Bus. While a loader is changing, the facade should fall back to a typed null backend rather than dereference `null`.

The default remains `mako` until the final handover. `NotificationFixtureStrategy` must not interact with D-Bus. It should provide typed center records and popup IDs and support controlled receipt, replacement, actions, transient flags, urgency, and expiry so popup behavior can be tested without constructing `NotificationServer`.

## Safer implementation sequence

1. **Fix existing contracts**
   - Add `category` to `NotificationEntry`.
   - Add `dismissMany`.
   - Parameterize list/group components for center versus popup collections.
   - Add popup properties and no-op popup methods to `NotificationBackend`.
2. **Add explicit backend construction and fixture mode**
   - Add the typed null backend, conditional loader, and `NotificationFixtureStrategy`.
   - Confirm fixture and Mako modes do not construct `NotificationServer`.
3. **Build popup UI against controlled fixture data**
   - Validate layout, grouping, hover, actions, swipe scope, input mask, and monitor placement without taking D-Bus ownership.
4. **Implement native live bindings**
   - Set `notification.tracked = true` first on every received notification.
   - Implement receipt, replacement observation, live/restored dispatch, close handling, actions, resident behavior, images, and correct IDs.
   - Keep the strategy file uninstantiated in normal Mako mode.
5. **Implement popup controller**
   - Deadlines, pause/resume, inhibition, critical and transient behavior.
6. **Implement persistence**
   - Resolve and verify the daemon-session identity checkpoint.
   - Restore/merge, bounded retention, order-independent tuple-based hot-reload reconnection, full-restart behavior, and invalid-document handling.
7. **Integrate status-panel and lock inhibition**
8. **Run a controlled ownership test**
   - Start the completely wired native configuration while Mako still owns D-Bus.
   - Stop Mako.
   - Verify Quickshell becomes the owner.
9. **Only then change the normal session configuration**
   - The user will need to disable/remove Mako through the NixOS/Home Manager configuration.
   - Quickshell is already systemd-supervised, which is appropriate for daemon responsibility.

## Required test matrix

Before permanently disabling Mako:

- basic notification receipt
- every received notification is tracked before the handler returns
- same-ID replacement without duplicate or remove/add flicker
- replacement preserves arrival ordering and unread state
- visible replacement refreshes its timeout; hidden replacement does not re-popup
- replacement after popup timeout
- replacement action-label behavior on the installed Quickshell version
- sender-requested close
- user dismissal and correct close reason
- explicit, default, zero, and critical expiry
- transient behavior under normal and DND conditions
- resident and non-resident actions
- image-data and image-path handling
- malformed markup and unsupported tags
- embedded and remote body images while `bodyImagesSupported` is false
- unusual hyperlink schemes and link activation
- DND collection/unread behavior
- hover pause/resume
- opening the status panel while popups are visible
- popup-group dismissal not affecting center-only entries
- multi-monitor focused-screen placement
- lock-screen suppression
- hot reload with `lastGeneration`, tested with persistence loading both before and after native replay
- hot reload preserves the daemon-session ID and durable record identity
- hot reload never duplicates a restored/live pair when protocol IDs collide with older history
- full restart generates a new daemon-session ID and restores history without actions
- full restart permits reuse of an old originating protocol ID without false deduplication
- live versus historical individual, group, and all-dismiss behavior
- malformed persistence document
- timer notification dismissal by numeric ID and category
- Quickshell crash/restart and D-Bus ownership recovery

## Bottom line

The native daemon is a good fit for the current service structure, but it is not just a new backend file. The minimum safe migration also requires:

1. popup-aware backend/facade contracts,
2. replacement observation,
3. persistence/history semantics,
4. collection-scoped popup actions,
5. status-panel/lock inhibition,
6. timer ID/category compatibility, and
7. an explicit D-Bus handover procedure,
8. order-independent hot-reload reconciliation, and
9. construction-safe Mako, fixture, and native backend selection.

## Reference index

### Local code

| Concern | Source of truth |
|---|---|
| Facade and grouping | [`Sources/Notifications.qml`](Sources/Notifications.qml) |
| Backend interface | [`Sources/Notifications/NotificationBackend.qml`](Sources/Notifications/NotificationBackend.qml) |
| Current Mako adapter | [`Sources/Notifications/MakoStrategy.qml`](Sources/Notifications/MakoStrategy.qml) |
| Backend record | [`Sources/Notifications/NotificationRecord.qml`](Sources/Notifications/NotificationRecord.qml) |
| Backend action | [`Sources/Notifications/NotificationAction.qml`](Sources/Notifications/NotificationAction.qml) |
| UI entry/action/group types | [`Sources/Notifications/NotificationEntry.qml`](Sources/Notifications/NotificationEntry.qml), [`NotificationActionEntry.qml`](Sources/Notifications/NotificationActionEntry.qml), [`NotificationGroup.qml`](Sources/Notifications/NotificationGroup.qml) |
| Notification center | [`Modules/StatusPanel/Notifications/NotificationList.qml`](Modules/StatusPanel/Notifications/NotificationList.qml) |
| Group list/reconciliation UI | [`Modules/StatusPanel/Notifications/NotificationListView.qml`](Modules/StatusPanel/Notifications/NotificationListView.qml) |
| Group and item interactions | [`NotificationGroup.qml`](Modules/StatusPanel/Notifications/NotificationGroup.qml), [`NotificationItem.qml`](Modules/StatusPanel/Notifications/NotificationItem.qml) |
| Popup insertion point | [`shell.qml`](shell.qml) |
| Existing panel window | [`Modules/StatusPanel/StatusPanel.qml`](Modules/StatusPanel/StatusPanel.qml) |
| Focused monitor source | [`Sources/WM.qml`](Sources/WM.qml), [`Sources/WM/HyprlandStrategy.qml`](Sources/WM/HyprlandStrategy.qml) |
| Persistence implementation | [`Sources/DocumentDb/DocumentStore.qml`](Sources/DocumentDb/DocumentStore.qml) |
| Timer notification coupling | [`Sources/Timer.qml`](Sources/Timer.qml) |
| Notification fixtures | [`scripts/notification-fixtures`](scripts/notification-fixtures), [`scripts/notification-fixtures.md`](scripts/notification-fixtures.md) |

### Checked-out upstream shell

Upstream root:

```text
/home/otard/.config/quickshell/dots-hyprland/dots/.config/quickshell/ii
```

Relevant files:

```text
services/Notifications.qml
modules/ii/notificationPopup/NotificationPopup.qml
modules/common/widgets/NotificationListView.qml
modules/common/widgets/NotificationGroup.qml
modules/common/widgets/NotificationItem.qml
modules/common/widgets/NotificationActionButton.qml
modules/common/functions/NotificationUtils.qml
modules/common/Directories.qml
```

Treat upstream as a behavioral and visual reference, not as code to copy wholesale. In particular, its notification singleton mixes transport, persistence, grouping, unread state, and popup policy.

### Quickshell 0.3.0 documentation and source

- [Notifications module](https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Notifications/)
- [`NotificationServer`](https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Notifications/NotificationServer/)
- [`Notification`](https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Notifications/Notification/)
- [`NotificationAction`](https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Notifications/NotificationAction/)
- [`NotificationCloseReason`](https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Notifications/NotificationCloseReason/)
- [`NotificationUrgency`](https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Notifications/NotificationUrgency/)
- [`PanelWindow`](https://quickshell.org/docs/v0.3.0/types/Quickshell/PanelWindow/)
- [`Region`](https://quickshell.org/docs/v0.3.0/types/Quickshell/Region/) — input-mask primitive for the popup host.
- [`LazyLoader`](https://quickshell.org/docs/v0.3.0/types/Quickshell/LazyLoader/) — candidate for conditional native-backend instantiation.
- [`PersistentProperties`](https://quickshell.org/docs/v0.3.0/types/Quickshell/PersistentProperties/) — candidate for daemon-session identity across hot reloads.
- [Quickshell v0.3.0 notification server source](https://github.com/quickshell-mirror/quickshell/blob/v0.3.0/src/services/notifications/server.cpp)
- [Quickshell v0.3.0 notification object/action source](https://github.com/quickshell-mirror/quickshell/blob/v0.3.0/src/services/notifications/notification.cpp)
- [Quickshell v0.3.0 QML wrapper and reload behavior](https://github.com/quickshell-mirror/quickshell/blob/v0.3.0/src/services/notifications/qml.cpp)

Version-specific source findings in this document should be rechecked against these files after any Quickshell upgrade.

### Freedesktop protocol

- [Desktop Notifications Specification](https://specifications.freedesktop.org/notification/latest/)
- [D-Bus protocol: `Notify`, replacement IDs, expiry, close and action signals](https://specifications.freedesktop.org/notification/latest/protocol.html)
- [Notification hints: category, desktop entry, resident and transient](https://specifications.freedesktop.org/notification/latest/hints.html)
- [Urgency levels](https://specifications.freedesktop.org/notification/latest/urgency-levels.html)
- [Markup](https://specifications.freedesktop.org/notification/latest/markup.html)
- [Icons and images](https://specifications.freedesktop.org/notification/latest/icons-and-images.html)

### Current runtime and handover inspection

Current local paths and units:

```text
Mako config:              /home/otard/.config/mako/config
Mako unit:                mako.service
Quickshell unit:          quickshell.service
Notification D-Bus name: org.freedesktop.Notifications
```

Useful non-destructive checks:

```bash
quickshell --version
systemctl --user status mako.service
systemctl --user status quickshell.service
busctl --user list | grep org.freedesktop.Notifications
makoctl list -j
makoctl history -j
```

At research time, Mako was active and owned the notification D-Bus name, while Quickshell 0.3.0 was running under `quickshell.service`. Stopping/disabling Mako is intentionally excluded from this document's automated steps; the permanent change belongs in the user's NixOS/Home Manager configuration after the complete handover test passes.
