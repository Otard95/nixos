# Bottom tools panel study

## Goal

Replace the standalone calendar at `Modules/StatusPanel/StatusPanelContent.qml:67`
with the upstream-style bottom tool group shown in the reference image:

```text
expanded
┌──────────────────────────────────────────────┐
│ [collapse] │                                 │
│            │                                 │
│ [Calendar] │       selected tool content     │
│ [Timer]    │                                 │
│ [Media]    │                                 │
└──────────────────────────────────────────────┘

collapsed
┌──────────────────────────────────────────────┐
│ [expand]  date • active media summary        │
└──────────────────────────────────────────────┘
```

The existing local `Calendar.qml` already has approximately the right expanded
height and can become the first content page. It will move into the status-panel
widget package alongside the other pages.

## Sources inspected

Upstream root:

```text
/home/otard/.config/quickshell/dots-hyprland/dots/.config/quickshell/ii
```

Primary upstream files:

```text
modules/ii/sidebarRight/BottomWidgetGroup.qml
modules/ii/sidebarRight/SidebarRightContent.qml
modules/ii/sidebarRight/calendar/CalendarWidget.qml
modules/ii/sidebarRight/pomodoro/PomodoroWidget.qml
modules/ii/sidebarRight/pomodoro/PomodoroTimer.qml
modules/ii/sidebarRight/pomodoro/Stopwatch.qml
services/TimerService.qml
modules/ii/mediaControls/MediaControls.qml
modules/ii/mediaControls/PlayerControl.qml
modules/waffle/actionCenter/MediaPaneContent.qml
services/MprisController.qml
modules/common/Persistent.qml
modules/common/widgets/NavigationRailTabArray.qml
modules/common/widgets/NavigationRailButton.qml
modules/common/widgets/SecondaryTabButton.qml
```

Local files:

```text
Modules/StatusPanel/StatusPanelContent.qml
Modules/StatusPanel/Calendar.qml (to be moved to `Widgets/Calendar.qml`)
Modules/StatusPanel/StatusPanel.qml
Theme.qml
Components/MaterialSymbol.qml
```

External API references:

- Quickshell `FileView`: https://quickshell.org/docs/v0.3.1/types/Quickshell.Io/FileView/
- Quickshell path helpers: https://quickshell.org/docs/v0.3.1/types/Quickshell/Quickshell/

## What upstream actually does

`SidebarRightContent.qml` places `BottomWidgetGroup` below the expanding
notification section. The group has `Layout.fillWidth: true`, does not fill
height, and derives its preferred height from `implicitHeight`.

`BottomWidgetGroup.qml` is one rounded, clipped layer-1 rectangle. Its expanded
state has a fixed implicit height of 350px. Its collapsed state derives height
from a compact summary row.

Expanded content is a `RowLayout`:

1. A fixed-width navigation rail on the left.
2. A fill-width/fill-height tool content area on the right.

The rail contains the collapse button at its top and three vertically centered
tool buttons:

| Index | Label | Icon | Content |
|---:|---|---|---|
| 0 | Calendar | `calendar_month` | month calendar |
| 1 | Timer | `schedule` | Pomodoro/stopwatch views |
| 2 | Media | `music_note` | MPRIS player and controls |

The collapse button points down while expanded. When collapsed, it points up
and the whole group becomes a single summary row. Locally this can contain the
formatted date and active track summary; it should not retain upstream's task
count now that To Do is out of scope.

Upstream persists both `collapsed` and `selectedTab`. It cross-fades expanded
and collapsed rows while animating `implicitHeight`. Tool changes use a `Loader`
with a vertical fade/slide transition.

## Geometry against the local panel

The local status panel is 460px wide with 10px content padding, leaving roughly
440px for the group. That is close to the reference image's 425px total width.
A 72–82px rail leaves approximately 345–355px for content.

The local calendar already computes to about 345px high:

- 20px outer vertical margins
- 34px header
- 5px header/grid spacing
- 28px weekday row
- six 38px date rows
- six 5px grid gaps

This fits directly into a 350px expanded group. Its horizontal grid also remains
usable after reserving the navigation rail.

The wrapper should own the `Theme.mantle` section background and
`Theme.innerRadius`. `Widgets/Calendar.qml` can either keep the same-colored root rectangle, which
is visually harmless, or expose a transparent/embedded mode.
The latter is cleaner if the calendar is ever reused elsewhere.

When the group collapses, `NotificationList` will naturally receive the freed
height because it is the only `Layout.fillHeight` child in
`StatusPanelContent.qml`.

## Recommended local structure

Do not copy upstream's navigation, appearance, translation, configuration, and
persistence frameworks. Port the small behavior directly:

```text
Modules/StatusPanel/
└── Widgets/
    ├── WidgetGroup.qml          collapsible rail and content host
    ├── WidgetSelector.qml       rail selector button
    ├── Calendar.qml             existing content page
    ├── calendar_layout.js
    ├── Timer.qml                later content page
    └── Media.qml                MPRIS content page

Sources/
├── Media.qml                    shared MPRIS state, registered as MediaSource
└── Timer.qml                    later timer state and clock logic
```

`Widgets/WidgetGroup.qml` should own only presentation state:

```qml
property int selectedTool: 0
property bool collapsed: false
readonly property var tools: [
    { name: "Calendar", icon: "calendar_month" },
    { name: "Timer", icon: "schedule" },
    { name: "Media", icon: "music_note" }
]
```

Use an `Item` or `Rectangle` root with `implicitHeight` switching between the
expanded height and compact-row height. The expanded body should be a
`RowLayout`, not a `Row`, so the right content gets the remaining width
predictably.

A local rail button needs only:

- icon and label stacked vertically;
- a rounded icon container;
- accent background/icon treatment when selected;
- hover feedback;
- one full `MouseArea`;
- explicit width and implicit height.

The selected appearance in the screenshot is an accent-tinted rounded icon
container while the label remains below it. This does not require upstream's
`NavigationRailButton`, ripple effects, or `Qt5Compat.GraphicalEffects`.

For content switching, `StackLayout` is preferable locally to upstream's
dynamic `Loader`: it is simpler, avoids URL-based component loading, and keeps
the calendar's `monthShift` and each tool's sub-tab state when switching. A
small opacity animation can be added later if desired. If startup cost becomes
material, replace pages 1 and 2 with per-page loaders.

Integrate it as:

```qml
// StatusPanelContent.qml: import "Widgets"
WidgetGroup {
    Layout.fillWidth: true
    Layout.preferredHeight: implicitHeight
}
```

in place of the direct `Calendar` instance. A relative directory import keeps
these private status-panel components out of the root `qmldir`.

## Collapse behavior

The safest local implementation is declarative rather than reproducing
upstream's timer-driven manual opacity assignments:

- animate `implicitHeight` with `Behavior on implicitHeight`;
- keep expanded and collapsed bodies in the same clipped root;
- bind each body's `opacity` and `visible` to `collapsed`;
- animate opacity independently;
- disable hidden-body mouse handling immediately during the transition.

The upstream half-duration cleanup timer exists to sequence its cross-fade, but
is not needed for a first local implementation. Avoid binding `visible` only to
`opacity > 0` without also disabling input, because an outgoing body can remain
interactive during the fade.

A compact height around 54px matches the upstream structure and leaves enough
space for a 34px circular expand control with 10px margins.

## State and persistence

There is no local equivalent of upstream's large `Persistent.qml`. For the
initial container, runtime-only `selectedTool` and `collapsed` properties are
sufficient and avoid importing that framework.

If persistence is wanted, use a very small local state singleton and
`Quickshell.statePath("status-panel.json")`; the documented helper resolves
inside the current shell's state directory. Do not hard-code the upstream
`~/.local/state/quickshell/user/...` path.

The selected tool and collapsed state are global in upstream. The local status
panel is instantiated once per screen, so putting these properties directly on
`WidgetGroup` makes them per-monitor. A singleton is required only if all
monitors should share the same state.

## Media implementation implications

The local bar already talks directly to `Quickshell.Services.Mpris`. Extract its
nonvisual player selection, progress refresh, and transport actions into
`Sources/Media.qml`, registered as `MediaSource`; keep the existing
`Modules/Center/Media.qml` as the bar presentation. The bottom Media page can
then share that source without a new process or external player CLI. The
detailed study and proposed compact layout are in
`upstream-media-controls.md`.

## Timer implementation implications

Upstream's Timer tool contains two sub-tabs:

- Pomodoro: focus/break/long-break cycle, start/pause/resume/reset.
- Stopwatch: start/pause/resume, lap recording, reset, and a lap list.

Its service uses wall-clock timestamps rather than decrementing a counter, so
elapsed time remains correct across delayed timer ticks. That is the right
principle to retain. It sends a `notify-send` notification at Pomodoro phase
changes.

Do not copy the service unchanged:

- the local shell has no upstream `Config`, `Persistent`, `Translation`, or
  `Audio` singletons;
- its 200ms Pomodoro poll is unnecessarily frequent for a seconds display;
- its stopwatch polls every 10ms even though the visible precision should drive
  the required update rate;
- `stopwatchLaps.push(...)` does not reassign the list, so some QML consumers may
  not update reliably;
- running timers need explicit restart/reload semantics based on persisted wall
  timestamps.

Use a dedicated `Sources/Timer.qml` with fixed local defaults first (for
example 25/5/15 minutes), timestamp-based calculations, and UI-appropriate poll
rates. Persistence can be added after the interaction is working.

## Upstream defects not to port

The checked-out `BottomWidgetGroup.qml` compares `root.currentTab` in its tool
switch connection, but the declared property is `selectedTab`. That direction
check is therefore invalid in this revision. Local code should compare the new
`selectedTool` against a saved previous index, or omit directional transitions.

The upstream trailing comma after the final tab object is accepted by its QML
runtime but is unnecessary.

The upstream calendar/timer/media pages depend on a broad widget and service
hierarchy. Copying the files directly would pull in `Appearance`, `Persistent`,
`Config`, `Translation`, `Directories`, numerous styled controls, and graphical
effects. Reimplementing the small local surface is substantially safer.

## Icon compatibility

The exact required outer-panel ligatures were checked against the local static
font at `assets/fonts/MaterialIconsRound-Regular.otf` using fonttools. All are
present:

```text
calendar_month
schedule
music_note
keyboard_arrow_up
keyboard_arrow_down
```

`timer`, `skip_previous`, `skip_next`, `play_arrow`, `pause`, `shuffle`,
`repeat`, and `repeat_one` are also present for the inner tools.

## Implementation status

The panel is implemented and user-validated:

- `WidgetGroup.qml` provides the 350px expanded layout, compact summary,
  navigation rail, and collapse/expand animation.
- Calendar, Pomodoro, stopwatch, and Media pages are functional.
- Tool switching uses a user-validated directional fade/slide while retaining
  the persistent `StackLayout` page instances.
- `MediaSource` is shared by the center bar and detailed Media page. The page
  supports art, metadata, seeking, transport controls, empty state, and
  switching among separately exposed MPRIS endpoints. Its timeline uses the
  reusable slider's Wavy style while playing and Thin style while paused, with
  a stable-height animated transition.
- A browser may multiplex multiple media tabs through one MPRIS endpoint; those
  tabs cannot be selected individually from Quickshell.
- `TimerSource` persists Pomodoro and stopwatch state with `DocumentStore`.
  Operational state is timestamp-based (`deadlineAt`, `startedAt`, `pausedAt`,
  and `lastLapStart`); lap durations are persisted only as history.
- Selected-tool and collapsed state persist globally through `StatusPanelState`
  and `DocumentStore`.
- Shuffle/repeat controls were intentionally omitted; the user does not want a
  shuffle control.
- Reloads and validation use `systemctl --user restart quickshell.service`; do
  not launch an unmanaged Quickshell process.

## Implemented sequence

1. Added `Widgets/WidgetGroup.qml` and `Widgets/WidgetSelector.qml`; moved the
   calendar and its JavaScript helper into `Widgets/`.
2. Replaced the direct calendar in `StatusPanelContent.qml` with the group.
3. Added the shared MPRIS source and detailed Media page.
4. Verified behavior and visuals with the user and checked runtime logs.
5. Added the timestamp-based Timer source and Pomodoro/stopwatch page.
6. Added timer persistence.
7. Added global selected-tool and collapsed-state persistence through the same
   `DocumentStore` infrastructure.
8. Added and user-validated directional tool-page fade/slide transitions.
