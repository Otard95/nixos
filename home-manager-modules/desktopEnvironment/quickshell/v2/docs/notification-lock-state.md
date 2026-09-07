# Notification lock-state investigation

## Decision

Use Hyprland's `hyprland_lock_notifier_v1` Wayland protocol as the primary source.

This state belongs to the compositor, not to hyprlock. It reports locks from any client that uses the Wayland session-lock protocol. Hyprland can also use it for other lock methods.

Use hypridle's `org.freedesktop.ScreenSaver` service as the fallback. The installed hypridle maps the same compositor events to `GetActive` and `ActiveChanged`.

Do not use hyprlock process existence or systemd-logind `LockedHint` as the main source.

No source was implemented during this investigation. Mako remained active, and no D-Bus ownership changed.

Implementation is deferred. The controlled ownership test will first check whether compositor lock surfaces fully cover the popup layer. Tests will use non-sensitive notifications and will also check for old popups after unlock. Do not claim lock-screen suppression until this test passes or a lock-state source exists.

## 1. Verified runtime and configuration facts

The checks ran in the active Hyprland session without locking it.

| Item | Verified value |
|---|---|
| Quickshell | `0.3.0`, revision `tag-v0.3.0`, from Nixpkgs |
| Hyprland | `0.56.2`, commit `efb50993780079460b0cbed1363e2166a2de1d9f` |
| hyprlock | `0.9.6`, source tag commit `b222d9b1f87e980cac379371df57913a53b99d7f` |
| hypridle | `0.1.8`, source tag commit `e5c01af0842bd66617f7004568df9406111d6e80` |
| systemd | `261.1` |
| Session | ID `2`, type `wayland`, active, `LockedHint=no` during the unlocked check |
| Notification daemon | Mako remains the configured and active backend |

Version commands and relevant output:

```text
$ quickshell --version
Quickshell 0.3.0 (revision tag-v0.3.0, distributed by Nixpkgs)

$ hyprctl version
Hyprland 0.56.2 ... commit efb50993780079460b0cbed1363e2166a2de1d9f

$ hyprlock --version
Hyprlock version v0.9.6

$ loginctl --version
systemd 261 (261.1)
```

The active session used object path `/org/freedesktop/login1/session/_32`. The `_32` suffix encodes the character `2`.

```text
$ loginctl show-session "$XDG_SESSION_ID" -p Type -p Active -p LockedHint
Type=wayland
Active=yes
LockedHint=no
```

The Hyprland runtime directory contains these relevant objects:

```text
$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket.sock
$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock
$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/hyprland.lock
```

No hyprlock process ran during the unlocked check. No hyprlock socket or PID file existed.

### Local configuration

All main Hyprland configuration files are Home Manager links into `/nix/store`.

`~/.config/hypr/hypridle.conf` contains:

```ini
general {
  after_sleep_cmd=hyprctl dispatch dpms on
  before_sleep_cmd=loginctl lock-session
  lock_cmd=pidof hyprlock || hyprlock
}
```

A listener also runs `loginctl lock-session` after 150 seconds. Hypridle receives that logind request and starts hyprlock through `lock_cmd`.

`~/.config/hypr/hyprlock.conf` contains only visual widget settings. It has no command that updates logind or another D-Bus lock property.

`Modules/StatusPanel/PowerOptions.qml:43` starts `hyprlock` directly. It does not update a local shell property before the process starts.

The installed `hypridle.service` runs continuously. Its current owner of `org.freedesktop.ScreenSaver` is PID 2741.

```text
$ busctl --user status org.freedesktop.ScreenSaver
PID=2741
Comm=hypridle
Exe=/nix/store/...-hypridle-0.1.8/bin/hypridle
```

The service supplies this API at both `/org/freedesktop/ScreenSaver` and `/ScreenSaver`:

```text
.GetActive       method  -  b
.ActiveChanged   signal  b
```

The current query returned `false`:

```text
$ busctl --user call org.freedesktop.ScreenSaver \
    /org/freedesktop/ScreenSaver \
    org.freedesktop.ScreenSaver GetActive
b false
```

## 2. Evidence and findings

### 2.1 Quickshell cannot observe another client's lock through `WlSessionLock`

Quickshell 0.3.0 documents `WlSessionLock` as a lock owner. Setting `locked` requests a new `ext_session_lock_v1` object and creates lock surfaces.

Documentation:

- <https://quickshell.org/docs/v0.3.0/types/Quickshell.Wayland/WlSessionLock/>
- <https://wayland.app/protocols/ext-session-lock-v1>

The Quickshell page says only one `WlSessionLock` can lock at one time. An attempt while another lock exists does nothing.

The source confirms that the properties describe Quickshell's own lock object:

- [`src/wayland/session_lock.cpp`](https://github.com/quickshell-mirror/quickshell/blob/v0.3.0/src/wayland/session_lock.cpp)
- [`src/wayland/session_lock/session_lock.hpp`](https://github.com/quickshell-mirror/quickshell/blob/v0.3.0/src/wayland/session_lock/session_lock.hpp)
- [`src/wayland/session_lock/lock.cpp`](https://github.com/quickshell-mirror/quickshell/blob/v0.3.0/src/wayland/session_lock/lock.cpp)

`WlSessionLock::isLocked()` reads its private `SessionLockManager`. `secure` becomes true only when that object's `ext_session_lock_v1.locked` event arrives.

The standard `ext-session-lock-v1` protocol has no observer interface. Its events go to the client that requested the lock.

Therefore, constructing a dormant `WlSessionLock` is not an observation method. It can conflict with hyprlock and must not be used here.

### 2.2 Hyprland exposes authoritative current state

The installed command supports an exact current-state query:

```text
$ hyprctl locked
false

$ hyprctl -j locked
{
    "locked": false
}
```

Hyprland 0.56.2 registers this command in:

- [`src/debug/HyprCtl.cpp:1967-2021`](https://github.com/hyprwm/Hyprland/blob/v0.56.2/src/debug/HyprCtl.cpp#L1967-L2021)

The handler returns `g_pSessionLockManager->isSessionLocked()`. That method reads the compositor's session-lock protocol state.

This command gives correct state after a Quickshell start or reload. It does not supply transitions.

The command is absent from the installed `hyprctl --help` command list and the current IPC event table. Its exact-version source is stronger evidence than the help output.

### 2.3 Hyprland's normal IPC event socket has no lock event

Hyprland documents `.socket2.sock` as a live event stream:

- <https://wiki.hypr.land/IPC/>

The event list has no session-lock event. Exact Hyprland 0.56.2 source also posts no `SHyprIPCEvent` from either file:

- [`src/managers/SessionLockManager.cpp`](https://github.com/hyprwm/Hyprland/blob/v0.56.2/src/managers/SessionLockManager.cpp)
- [`src/protocols/SessionLock.cpp`](https://github.com/hyprwm/Hyprland/blob/v0.56.2/src/protocols/SessionLock.cpp)

Thus `.socket2.sock` cannot give lock and unlock transitions in this version.

The command socket can answer `hyprctl locked`. A loop can poll it, but a command response is not an event source.

### 2.4 Hyprland supplies a dedicated lock observer protocol

Hyprland 0.56.2 registers `hyprland_lock_notifier_v1` version 1. This protocol exists specifically for lock observation.

Protocol documentation:

- <https://wayland.app/protocols/hyprland-lock-notify-v1>
- [Protocol XML](https://github.com/hyprwm/hyprland-protocols/blob/main/protocols/hyprland-lock-notify-v1.xml)

The protocol contract states:

- It lets clients monitor whether the Wayland session is locked.
- It sends `locked` immediately when a new observer connects to an already locked session.
- It sends `locked` and `unlocked` for transitions.
- The usual source is any client that uses `ext-session-lock`.
- Hyprland can report another compositor lock method through the same interface.
- The `locked` event occurs after the secure lock transition and locked frames.

Exact implementation:

- [`src/protocols/LockNotify.cpp`](https://github.com/hyprwm/Hyprland/blob/v0.56.2/src/protocols/LockNotify.cpp)
- [`src/protocols/SessionLock.cpp`](https://github.com/hyprwm/Hyprland/blob/v0.56.2/src/protocols/SessionLock.cpp)
- [`src/managers/ProtocolManager.cpp`](https://github.com/hyprwm/Hyprland/blob/v0.56.2/src/managers/ProtocolManager.cpp)

`CLockNotifyProtocol::onGetNotification()` sends `locked` at once when `m_isLocked` is true. `onLocked()` and `onUnlocked()` send each transition to all observers.

The compositor calls these methods when the session-lock protocol reaches its secure lock and unlock points. This source is independent of the hyprlock process.

Quickshell 0.3.0 does not expose this Hyprland protocol as a QML type. Its source contains no `hyprland_lock_notifier_v1` implementation.

A small native helper or a new Quickshell module is necessary for direct use.

### 2.5 hypridle already bridges the observer protocol to D-Bus

The installed hypridle 0.1.8 binds `hyprland_lock_notifier_v1` and receives both events:

- [`src/core/Hypridle.cpp:89-92`](https://github.com/hyprwm/hypridle/blob/v0.1.8/src/core/Hypridle.cpp#L89-L92)
- [`src/core/Hypridle.cpp:398-435`](https://github.com/hyprwm/hypridle/blob/v0.1.8/src/core/Hypridle.cpp#L398-L435)

Its `onLocked()` sets `m_isLocked=true`. Its `onUnlocked()` sets `m_isLocked=false`.

Hypridle exposes that field through `org.freedesktop.ScreenSaver.GetActive`. It emits `ActiveChanged(bool)` from the same handlers:

- [`src/core/Hypridle.cpp:627-665`](https://github.com/hyprwm/hypridle/blob/v0.1.8/src/core/Hypridle.cpp#L627-L665)
- <https://wiki.hypr.land/Hypr-Ecosystem/hypridle/>

When hypridle starts while the session is locked, Hyprland sends the initial `locked` event immediately. The Wayland request enters the queue before hypridle starts its event loop.

This gives both current state and transitions in the present setup. The D-Bus service name alone does not guarantee lock semantics from all possible owners.

Another screen saver can own `org.freedesktop.ScreenSaver` and interpret `GetActive` as blanking rather than locking. The source must treat an unexpected owner as unknown.

### 2.6 logind `LockedHint` is advisory, not automatic

The logind D-Bus API has a session `LockedHint` property and emits property changes. It also has `SetLockedHint(bool)`.

Official documentation:

- <https://www.freedesktop.org/software/systemd/man/latest/org.freedesktop.login1.html>

The documentation says the desktop environment calls `SetLockedHint()` to tell logind about lock state. Logind does not derive this value from Wayland session-lock ownership.

The `Lock()` and `Unlock()` D-Bus signals are requests. They do not prove that a lock screen reached or left the secure state.

Exact hyprlock 0.9.6 source contains no `SetLockedHint`, `LockedHint`, or session-object call:

- [`src/core/Dbus.cpp`](https://github.com/hyprwm/hyprlock/blob/v0.9.6/src/core/Dbus.cpp)
- [`src/core/hyprlock.cpp`](https://github.com/hyprwm/hyprlock/blob/v0.9.6/src/core/hyprlock.cpp)

Hyprlock uses its system-bus connection only for logind sleep state in the fingerprint code.

Hypridle 0.1.8 listens to logind `Lock` and `Unlock` requests, but it does not call `SetLockedHint()`.

Therefore, the current source evidence does not support `LockedHint` for this setup. A controlled lock test must still record its behavior before the final implementation.

`LockedHint` can become useful after an explicit bridge sets it from compositor events. It is not a universal state that every Wayland lock screen sets.

For a later backend that does not use Hyprland, examine `LockedHint` as a fallback. Use it only if the active desktop or locker calls `SetLockedHint()` after each secure lock and unlock. Tests must cover startup while locked, loss of the writer, session changes, and stale values. If no known writer exists, treat the state as unknown and fail closed.

### 2.7 Process existence is not lock ownership

Hyprlock process existence gives false results at both ends of its lifetime.

Before lock ownership, hyprlock can load resources and screencopy frames. Only later does it call `acquireSessionLock()`:

- [`src/core/hyprlock.cpp:340-380`](https://github.com/hyprwm/hyprlock/blob/v0.9.6/src/core/hyprlock.cpp#L340-L380)

After authentication, hyprlock starts its fade-out before it sends `unlock_and_destroy`. The process remains alive after the compositor unlocks:

- [`src/core/hyprlock.cpp:519-530`](https://github.com/hyprwm/hyprlock/blob/v0.9.6/src/core/hyprlock.cpp#L519-L530)
- [`src/core/hyprlock.cpp:792-842`](https://github.com/hyprwm/hyprlock/blob/v0.9.6/src/core/hyprlock.cpp#L792-L842)

If hyprlock crashes after secure lock, the Wayland protocol requires the compositor to remain locked. The process can then be absent while the session remains locked.

The protocol specification states this crash behavior:

- <https://wayland.app/protocols/ext-session-lock-v1>

No hyprlock PID file or state socket exists in the installed package or runtime directory. The `pidof hyprlock || hyprlock` command only prevents duplicate process starts.

The Hyprland `hyprland.lock` file belongs to the compositor. It does not describe session-lock state.

## 3. Candidate comparison

Ratings use `5` for the best result. “Exact” means source evidence covers current state and both transitions.

| Candidate | Startup state | Transitions | Reload or restart while locked | Stability | Latency | Failure and privacy | Fit under `Sources/` | Result |
|---|---:|---:|---:|---:|---:|---|---:|---|
| Direct `hyprland_lock_notifier_v1` helper | 5 | 5 | 5 | 3 | Event-driven | Helper failure becomes unknown and fail-closed | 4 | **Recommended** |
| hypridle `GetActive` plus `ActiveChanged` | 5 | 5 | 5 | 3 | Event-driven | Wrong D-Bus owner can change semantics | 4 | **Fallback** |
| `hyprctl -j locked` polling | 5 | 2 | 5 | 3 | Poll interval | A missed or failed poll must fail closed | 5 | Diagnostic and reconciliation only |
| logind `LockedHint` now | 1 | 1 | 1 | 5 | Event-driven if maintained | Current locker does not maintain it | 4 | Reject now |
| logind `Lock` and `Unlock` request signals | 1 | 1 | 1 | 5 | Event-driven | Requests can fail or take time | 4 | Reject |
| Hyprland `.socket2.sock` | 0 | 0 | 0 | 4 | Event-driven | No lock event in version 0.56.2 | 4 | Reject |
| Quickshell `WlSessionLock` | 0 | 0 | 0 | 4 | Event-driven | It requests ownership and can conflict | 3 | Reject |
| hyprlock process existence | 1 | 1 | 1 | 3 | Poll or process event | False unlocked state after a locker crash | 5 | Reject |
| Layer or surface presence | 1 | 1 | 1 | 2 | Poll or event | Session-lock surfaces are not normal layer-shell state | 2 | Reject |
| State file written by commands | 3 | 4 | 3 | 2 | Event-driven | Stale files survive writer failure | 3 | Optional last resort |

## 4. Recommended design

### 4.1 Primary source

Add a small helper that binds `hyprland_lock_notifier_v1` version 1. Package it through Nix later.

The helper must use this startup sequence:

1. Bind the lock notifier global.
2. Create a lock-notification object.
3. Install `locked` and `unlocked` handlers.
4. issue a `wl_display.sync` request.
5. Emit `locked` if the compositor sends the initial event.
6. Emit `unlocked` after the sync callback if no initial `locked` event arrived.
7. Keep the Wayland event loop active for transitions.

The sync barrier is necessary. The protocol sends an initial event only for the locked case.

Use a line protocol on standard output:

```text
locked
unlocked
unavailable <reason>
```

Wrap the helper in a `Sources/SessionLockState.qml` singleton with `Quickshell.Io.Process` and `SplitParser`.

Quickshell 0.3.0 supports a long-running `Process`, parsed standard output, exit status, and process restart:

- <https://quickshell.org/docs/v0.3.0/types/Quickshell.Io/Process/>
- <https://quickshell.org/docs/v0.3.0/types/Quickshell.Io/SplitParser/>

This design has one source name and no hyprlock dependency. It also avoids repeated command processes.

### 4.2 Fallback source

Use the existing hypridle `org.freedesktop.ScreenSaver` bridge.

The fallback must:

1. Check that the name has an owner.
2. identify the owner as the expected hypridle service.
3. Subscribe to `ActiveChanged` before it accepts an unlocked state.
4. Call `GetActive` for startup state.
5. Watch `NameOwnerChanged` for service loss or replacement.
6. Re-query after each owner change.
7. Set state to unknown if the monitor or query fails.

Quickshell 0.3.0 has no public generic D-Bus QML client type. A small D-Bus helper is safer than parsing `dbus-monitor` text.

If no helper is acceptable, use an installed `dbus-monitor` process for events and `busctl` for queries. Treat parser errors and process exits as unknown.

Use `hyprctl -j locked` as a second query after startup and after D-Bus recovery. A mismatch means unknown until two consecutive queries agree.

## 5. Proposed source contract

```qml
pragma Singleton

Singleton {
    readonly property bool available: false
    readonly property bool stateKnown: false
    readonly property bool locked: true
    readonly property string source: "none"
    readonly property string error: ""
}
```

Required invariants:

- `locked` is true whenever `stateKnown` is false.
- `available` means the selected source is connected and usable.
- `stateKnown` becomes true only after the startup sync or an authoritative query.
- `source` identifies `hyprland-lock-notify`, `hypridle-dbus`, or `none`.
- A helper exit sets `available=false`, `stateKnown=false`, and `locked=true` before restart.
- An invalid line does not change the last reported state. It makes state unknown.

The `error` property is useful for logs and diagnostics. Notification policy must not depend on it.

## 6. Startup, reload, failure, and transition semantics

### Startup while unlocked

Start with `locked=true` and `stateKnown=false`. Set `locked=false` only after the protocol sync proves no initial locked event exists.

### Startup while locked

Hyprland sends `locked` immediately when the observer object is created. Keep popups hidden throughout source startup.

### Quickshell configuration reload

Quickshell stops an attached `Process` during reload. The new source starts in the unknown, fail-closed state.

The new helper reconnects and receives the current locked state. It does not depend on an event that occurred before reload.

### Full Quickshell restart while locked

The same initial-state rule applies. Notification persistence can load, but popup presentation remains inhibited until lock state is known and unlocked.

### Lock transition

On `locked`, first set `locked=true`. Then the native strategy hides all current popup memberships.

Do not expire normal center entries. Do not replay hidden popup memberships after unlock.

### Notifications received while locked

Retain normal notifications in the center and mark them unread. Do not add them to popup membership.

Apply the final transient policy separately. Lock-state failure must never make a transient notification visible.

### Unlock transition

Set `locked=false` only from an authoritative `unlocked` event. Do not restore old popups.

New notifications received after unlock follow normal popup policy.

### Source failure

Immediately set `stateKnown=false` and `locked=true`. Hide all current popups.

Retry the source with bounded delay. Never use a cached unlocked value after the source fails.

## 7. Controlled validation procedure

Do the non-disruptive checks first. Every lock, unlock, restart while locked, or suspend step needs explicit user approval.

### Phase A: no approval needed

1. Confirm the exact versions again.
2. Confirm Mako owns `org.freedesktop.Notifications`.
3. Confirm `hyprctl -j locked` returns `false` while unlocked.
4. Confirm hypridle owns `org.freedesktop.ScreenSaver`.
5. Confirm `GetActive` returns `false` while unlocked.
6. Start only the proposed observer helper.
7. Confirm its startup output is `unlocked`.
8. Stop the helper and confirm the QML contract becomes unknown and locked.

### Phase B: approval required for locking

1. Start these observers before the lock:
   - the direct protocol helper,
   - `org.freedesktop.ScreenSaver.ActiveChanged`,
   - logind `PropertiesChanged`,
   - a timestamped `hyprctl -j locked` sampler.
2. Ask the user for approval to run `loginctl lock-session`.
3. Unlock normally through hyprlock.
4. Compare timestamps and values from all sources.
5. Confirm the direct protocol event and `hyprctl locked` agree.
6. Record whether logind `LockedHint` changed.
7. Confirm `GetActive` and `ActiveChanged` followed the direct protocol.

### Phase C: approval required for Quickshell reload while locked

1. Ask the user for approval to lock the session.
2. Send a test notification before the reload.
3. Reload only the Quickshell configuration through its managed method.
4. Confirm the source starts unknown and fail-closed.
5. Confirm the initial observer event restores `locked=true`.
6. Send a notification while locked.
7. Confirm no notification popup appears.
8. Unlock normally.
9. Confirm old popup memberships do not reappear.
10. Send a new notification and confirm normal popup behavior resumes.

### Phase D: approval required for a full Quickshell restart while locked

1. Ask the user for approval to lock the session.
2. Restart only the managed Quickshell service.
3. Confirm the first rendered popup-host state is hidden.
4. Confirm the helper reports the existing lock without a new lock transition.
5. Unlock normally and test one new notification.

### Phase E: approval required for failure tests

1. Ask the user before stopping or restarting hypridle.
2. Stop the selected helper while unlocked and confirm fail-closed state.
3. Restart the helper and confirm current-state recovery.
4. Repeat while locked only after separate user approval.
5. Do not kill hyprlock to test a crash without a recovery plan and explicit approval.
6. Do not test suspend without explicit approval.

Use non-sensitive test notification text during all locked tests.

## 8. Risks and unresolved questions

- `hyprland_lock_notifier_v1` is Hyprland-specific and version 1. It is more direct than a hyprlock-specific source.
- Quickshell 0.3.0 has no public wrapper for this protocol.
- A helper adds a small compiled component and Nix package work.
- The current Hyprland wiki tracks the latest release. Recheck exact source after each Hyprland upgrade.
- `hyprctl locked` exists in 0.56.2 source but not in the installed command help text.
- Hypridle's ScreenSaver service semantics depend on its owner. Another owner can mean “screen saver active,” not “secure lock active.”
- Runtime testing must confirm the installed hypridle startup path while already locked.
- Runtime testing must confirm whether any other local component updates logind `LockedHint`.
- A later backend can use `LockedHint` only after tests identify the component that maintains it and its failure behavior.
- Lock notification occurs after the compositor reaches secure lock. It does not report the earlier lock request.
- A popup can still change during the short pre-lock transition. The compositor has not declared the session locked at that point.
- The local popup has no configured above-lock rule. Still, application-level suppression remains required as defense in depth.

## 9. Smallest later integration points

### `Sources/SessionLockState.qml`

Add one singleton with the contract above. Keep all helper lifecycle and fail-closed rules in this source.

### `Modules/Notifications/NotificationPopupHost.qml`

Change the visibility gate at line 12 to require known unlocked state through `!SessionLockState.locked`.

This host gate is defense in depth. It prevents rendering even if backend popup membership is stale.

### `Sources/Notifications/QuickshellStrategy.qml`

Add lock state to the popup eligibility test near `publishNewBinding()`.

When `SessionLockState.locked` becomes true, call `hideAllPopups()` immediately. Do not replay them after unlock.

Gate all new `popupController.show()` calls on the combined inhibitor state. This gate must include DND, status-panel state, and lock state.

Do not put Wayland, D-Bus, process, or helper details into `NotificationPopupHost` or `QuickshellStrategy`.

## Conclusion about a lock-screen-independent state

A lock-screen-independent state exists in this Hyprland session: `hyprland_lock_notifier_v1`.

It is compositor state and works with any Wayland session-lock client. It is not a universal Wayland observer protocol.

The closest cross-desktop state is logind `LockedHint`, but lock clients must set it. Hyprlock 0.9.6 and hypridle 0.1.8 do not set it in their exact source.
