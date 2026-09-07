## Preliminary upstream comparison

The upstream is a real Quickshell notification daemon, not a Mako adapter:

- `NotificationServer` receives D-Bus notifications; setting `notification.tracked = true` keeps them alive.
- Its service owns live notification lifecycle, action invocation, dismissal, grouping, popup membership/timers, unread state, and JSON history.
- Sidebar and popup consume the same grouped data, filtered respectively to all retained notifications and the temporary popup subset.

Our implementation is already better structured for migration:

```text
MakoStrategy → NotificationRecord → Notifications facade
             → NotificationEntry / NotificationGroup → UI
```

A `QuickshellStrategy` can inherit `NotificationBackend` and replace only `MakoStrategy`; the existing panel UI and typed facade can remain intact.

## Native strategy shape

`QuickshellStrategy.qml` should:

1. Instantiate `NotificationServer` and explicitly advertise only the capabilities the popup/UI actually supports:
   actions, body, markup/hyperlinks, images, persistence, and potentially inline reply later.
2. On each notification:
   - set `tracked = true`;
   - create a typed `NotificationRecord` from Quickshell’s `Notification`;
   - retain a private `notificationId → live Notification` lookup;
   - use `Date.now()` as the arrival time;
   - preserve `desktopEntry`, `transient`, `resident`, image, urgency, and actions.
3. Implement existing backend operations against the live lookup:
   - `dismiss()` → `Notification.dismiss()`;
   - `invokeAction()` → matching `NotificationAction.invoke()`;
   - `dismissAll()` → dismiss each live notification;
   - DND → retain notifications but inhibit popup creation.
4. Remove/reconcile records when the native notification emits `closed`.

Historical records should be plain typed data with no live-object lookup and no actions. Dismissing one should remove it locally; action invocation should be unavailable.

## Gaps to account for before implementation

- **Popup state is not in the current backend interface.** The sidebar contract is sufficient, but a native popup host needs a backend-neutral popup subset plus timer/hover control. Add that as a small extension—e.g. popup notification IDs/groups and `setPopupHovered(...)`—rather than letting popup QML touch native notifications.
- **Persistence:** reuse the local schema-validated, atomic `DocumentStore`, rather than upstream’s raw `FileView` JSON. Persist only non-transient presentation records; never persist live actions.
- **ID/reload policy:** upstream offsets IDs restored from disk because Quickshell IDs restart. A local implementation should use stable opaque internal IDs (for example a generation-qualified ID) and define replacement/reload behavior explicitly, instead of copying the offset mechanism.
- **Expiry semantics need a focused test.** The Desktop Notifications protocol expresses expiry in milliseconds, while the Quickshell 0.3.0 documentation labels `expireTimeout` as seconds and upstream passes it directly to a QML `Timer` (milliseconds). Verify actual 0.3.0 runtime behavior before adopting upstream’s timer logic.
- **Hover behavior:** upstream stops a popup timer on hover, but hides the popup immediately when the pointer leaves rather than resuming the remaining duration. We should decide the desired policy and likely implement true pause/resume.
- **Daemon handover:** Mako must stay running until the native popup host has parity. Only one process can own `org.freedesktop.Notifications`; switching requires disabling `mako.service` and validating the D-Bus owner.

## Suggested implementation order

1. Implement `QuickshellStrategy` with native receipt, typed mapping, lifecycle, actions, and temporary debug logging—without enabling it.
2. Add persistence/restore and define restored-entry dismissal semantics.
3. Extend the backend/facade narrowly for popup membership and timeout control.
4. Build the `PanelWindow` popup host using the existing notification delegates.
5. Test expiry, replacement IDs, actions, images, transient/resident hints, DND, reload, and Mako-to-Quickshell ownership handover.
6. Enable native backend and disable Mako only after that test pass.

One notable upstream weakness is that its service mixes daemon state, persistence, popup policy, and presentation-shaped grouping in one singleton. Our existing backend/facade separation avoids that coupling and is the right foundation to retain.
