# Concurrent countdown timers

## Goal

Extend the status-panel Timer tool with a normal countdown-timer page while
retaining Pomodoro and Stopwatch:

```text
Timers | Pomodoro | Stopwatch
```

`Timers` is the first and initially selected page. Creating a timer starts it
immediately, and any number of timers may run concurrently.

Relevant existing code:

- `Modules/StatusPanel/Widgets/Timer.qml` — Timer tool presentation and tabs.
- `Sources/Timer.qml` — timestamp-based Pomodoro/stopwatch state and persistence.
- `Sources/DocumentDb/DocumentStore.qml` — validated atomic JSON persistence.
- `Modules/Center/ResourceMeter.qml` — circular progress-ring reference.
- `Modules/StatusPanel/Widgets/WidgetGroup.qml` — fixed 350px content host.
- `Sources/Notifications.qml` — notification facade; native timer notification
  acknowledgement is deferred until the Quickshell notification daemon is
  implemented.

## Persisted model

Countdown timers live in the existing `timer.json` document. This is private,
nonessential state, so the schema version may be replaced and incompatible old
state may be invalidated instead of migrated or split into another document.

Each countdown timer is represented by:

```js
{
    id: 1,
    label: "Tea",
    durationMs: 300000,
    deadlineAt: 0,
    remainingMs: 300000,
    state: "idle", // "idle" | "running" | "paused" | "completed"
    once: true
}
```

State invariants:

| State | `deadlineAt` | `remainingMs` |
|---|---:|---:|
| `idle` | `0` | `durationMs` |
| `running` | absolute wall-clock deadline | `0` |
| `paused` | `0` | captured remainder |
| `completed` | `0` | `0` |

A dedicated state is preferable to inferring completion because completion is
persistent and may drive an alarm until acknowledgement. Running countdowns
remain timestamp-based so delayed QML ticks and shell reloads do not introduce
drift.

The countdown collection and its next numeric ID are stored beside the existing
Pomodoro and stopwatch records. `DocumentStore` validation enforces positive
durations, unique IDs, valid states, and the state-specific field invariants.

## Transitions

| Action | Transition |
|---|---|
| Create | New timer starts in `running` with `deadlineAt = now + durationMs` |
| Play idle | `idle → running` for the full duration |
| Resume | `paused → running` for `remainingMs` |
| Pause | `running → paused`, capturing `deadlineAt - now` |
| Complete | `running → completed` |
| Restart running | Remains `running` with a fresh full-duration deadline |
| Restart paused, `once: true` | `paused → running` with a fresh full-duration deadline |
| Restart paused, `once: false` | `paused → idle` at the full duration |
| Restart idle | No-op |
| Acknowledge, `once: true` | Delete timer |
| Acknowledge, `once: false` | `completed → idle` at the full duration |
| Delete | Remove timer in any state |

There is initially no explicit stop button because row width is limited. For a
reusable timer, pausing and restarting aborts it back to idle. A once-only timer
restarts immediately instead, preventing a transient timer from lingering idle
and surprising the user when it is started much later. Delete is its explicit
abort path. A stop action may be added if there is enough space and that proves
inconvenient.

## Creation row

The creation row is permanently pinned above the scrollable timer list:

```text
+   [HH] : [MM] : [SS]   [x] Once
```

The three boxes are one logical numeric input:

- one backing string containing at most six digits;
- newly typed digits enter from the right;
- `30` displays as `00:00:30`;
- `90` displays as `00:00:90` and evaluates to 1 minute 30 seconds;
- `300` displays as `00:03:00`;
- Backspace removes the rightmost digit;
- clicking any segment focuses the same input;
- focus is represented visually on the seconds/rightmost segment;
- Enter or the `+` button creates and starts the timer;
- zero duration is rejected;
- `Once` defaults to checked again after creation.

Timers start unnamed. Clicking a timer's label area provides inline editing;
an empty label remains valid.

## Timer rows

The circular meter used by `ResourceMeter.qml` is extracted or adapted as a
reusable progress-ring icon. Timer rows use a larger version as their primary
control:

- running: pause icon with decreasing progress;
- paused: play icon with frozen progress;
- idle: play icon with a full ring;
- completed: acknowledgement icon with completed/alarm styling.

The textual time is:

- running/paused: `remaining / duration`;
- idle: duration only;
- completed: `00:00`.

When the bottom widget group is collapsed, the running timer with the earliest
deadline is shown at the right edge as `timer <time-left>`. The media summary
keeps the flexible width and elides first when space is constrained.

Hovering a row reveals restart and delete controls without hiding the time. The
label may elide to make room. Drag-only actions are avoided because they are
less discoverable and easier to trigger accidentally.

## Completion and notifications

Completion is persisted before alerting. Multiple timers expiring on the same
tick are completed together, and each receives its own notification. Reloading
the shell reconciles overdue running timers into `completed`.

The in-panel completed-state control is the initial acknowledgement path.
Acknowledging or deleting a completed timer also dismisses its corresponding
notification. Countdown notifications carry a timer-specific category, and the
source records the notification ID returned by `notify-send`; the category also
allows the notification facade to find it after source state changes.
Notification actions and acknowledgement initiated from the notification are
explicitly deferred until the native Quickshell notification daemon can connect
those events directly to `TimerSource`.

Audible alarm behavior should be driven by the persisted `completed` state so
it can survive reloads. The exact sound and repeat cadence are presentation
choices and should not be encoded into the document schema.

## Validation

Implementation validation should cover:

1. Create and run multiple timers concurrently.
2. Pause, resume, restart, rename, and delete timers independently.
3. Confirm paused restart returns reusable timers to idle but immediately
   restarts once-only timers.
4. Confirm positional digit entry, Backspace, Enter, and zero rejection.
5. Complete several timers on the same source tick.
6. Verify both `once` acknowledgement paths.
7. Restart `quickshell.service` while timers are running and completed.
8. Confirm Pomodoro and Stopwatch still function after the intentional document
   schema replacement.
9. Check Quickshell runtime logs before requesting visual confirmation.
