# Media controls study for the bottom tools panel

## Scope

Replace the discarded To Do tool with a compact Media tool, making the final
bottom rail:

```text
Calendar
Timer
Media
```

The Media page should fit the approximately 350px-wide content area beside the
rail and the existing 350px expanded group height.

## Sources inspected

Upstream Material implementation:

```text
modules/ii/mediaControls/MediaControls.qml
modules/ii/mediaControls/PlayerControl.qml
modules/ii/bar/Media.qml
services/MprisController.qml
```

Upstream compact Waffle implementation:

```text
modules/waffle/actionCenter/MediaPaneContent.qml
modules/waffle/actionCenter/ActionCenterContent.qml
```

Local implementation:

```text
Modules/Center/Media.qml
Modules/Center/SystemMedia.qml
Components/StyledSlider.qml
Components/MaterialSymbol.qml
```

API references:

- https://quickshell.org/docs/v0.3.1/types/Quickshell.Services.Mpris/Mpris/
- https://quickshell.org/docs/v0.3.1/types/Quickshell.Services.Mpris/MprisPlayer/

## Existing local capability

`Modules/Center/Media.qml` already imports `Quickshell.Services.Mpris` and has:

- active-player selection (playing player, otherwise first player);
- play/pause and next actions;
- track title and artist;
- a circular progress display;
- the required 1-second `positionChanged()` timer.

The detailed panel does not need `playerctl`, a process wrapper, or a new MPRIS
backend. It can use the same native objects.

The position timer is important. Quickshell documents that `MprisPlayer.position`
usually does not notify reactively during normal playback. Reading it is current,
but a visible timeline must manually emit `positionChanged()`. A 1-second timer
is appropriate for labels and a normal progress slider.

## Two useful upstream designs

### Material `ii` player card

The Material popup renders one 440×160 `PlayerControl` for every filtered
player. Each card contains:

- downloaded cover art;
- a blurred cover-art background;
- dominant-color-derived controls;
- title and artist;
- elapsed/total time;
- seekable slider or read-only progress bar;
- previous, play/pause, and next controls;
- optional Cava wave visualization.

This is the best source for behavior and control hierarchy, but not for direct
copying. Its full width is 440px before the bottom tool rail is accounted for,
and it depends on `Appearance`, graphical effects, a color quantizer, Cava,
`curl`, custom sliders, custom shadows, and generated Material color schemes.

### Waffle action-center media pane

The Waffle pane is 358×176, almost exactly the width available to the local
Media page. It uses a much simpler hierarchy:

1. player application icon/name;
2. title and artist with small cover art;
3. centered previous/play/next controls.

It omits seeking and elapsed time, but its proportions are better inspiration
for the local embedded page. The recommended local design combines this compact
composition with the Material player's timeline.

## Recommended local layout

Use one active player rather than stacking every connected player. Multiple
440px cards work in a separate popup, but cannot fit predictably inside a fixed
350px bottom section.

A suitable page is:

```text
┌──────────────────────────────────┐
│ [app icon] Player name   [1 / 2] │  optional player selector
│                                  │
│ ┌───────────┐  Track title       │
│ │           │  Artist            │
│ │ cover art │  Album             │
│ │           │                    │
│ └───────────┘                    │
│                                  │
│  1:24                     3:52   │
│  ───────── seek/progress ─────   │
│                                  │
│       previous  play  next       │
│   [shuffle]              [repeat]│  only when supported
└──────────────────────────────────┘
```

At roughly 350×350, a 100–120px square cover image leaves enough width for
metadata and enough height for a full timeline and controls. Catppuccin colors
should remain fixed; album-art-derived theming would conflict with the local
fixed-theme decision.

### Empty state

When no MPRIS player exists, show a centered `music_note` icon and “No active
player”. Keep the Media rail button visible: applications can appear while the
panel remains open, and the page will update from `Mpris.players` automatically.

## Player selection

The local bar currently chooses:

```qml
Mpris.players.values.find(p => p.isPlaying) ?? Mpris.players.values[0] ?? null
```

That is sufficient for a first Media page. A better shared selection policy is:

1. retain the explicitly selected player while it still exists;
2. otherwise select a currently playing player;
3. otherwise retain the most recently active player;
4. otherwise select the first real player.

When multiple players exist, expose small previous/next player buttons, dots, or
a compact player-name selector in the header. Do not display all players
vertically inside the fixed bottom section.

Extract the nonvisual part of the existing center widget into a shared
`Sources/Media.qml` singleton registered as `MediaSource`. It should own active
player selection, player tracking, progress refresh, and transport methods. The
center-bar summary and detailed page should both consume it so they cannot
select different players.

### Duplicate players

Useful rules from upstream's `MprisController` are:

- ignore `org.mpris.MediaPlayer2.playerctld` proxy entries;
- when Plasma browser integration exists, suppress duplicate native Firefox or
  Chromium buses;
- suppress MPD's duplicate non-instance bus.

Do not copy `MediaControls.filterDuplicatePlayers()` unchanged. Its combined
boolean expression lacks clear grouping, and its position/length comparison
uses signed subtraction rather than absolute differences. A player behind
another by any large amount can therefore be incorrectly considered “within
2 seconds”. Title containment also risks merging unrelated tracks with short
or empty titles.

Duplicate filtering should be conservative. For an initial local version,
filter only known proxy bus names and allow the user to switch among the rest.

## Cover art

Start with a normal asynchronous `Image` bound to `player.trackArtUrl`:

```qml
Image {
    source: player?.trackArtUrl ?? ""
    asynchronous: true
    fillMode: Image.PreserveAspectCrop
}
```

Put it inside a rounded `Rectangle` with `clip: true`, and show a `music_note`
placeholder when the URL is empty or loading fails. This avoids the unavailable
`OpacityMask` dependency.

Do not port upstream's cover downloader as written. It interpolates the MPRIS
art URL and output path into `bash -c`, invokes `curl`, and then treats any exit
as a successful download. Besides adding an unnecessary process dependency,
that construction needs careful shell escaping and error handling because the
URL comes from another process.

Only add a managed art cache if direct `Image` loading proves incompatible with
real players in use. If added later, use `Process.command` arguments directly,
validate schemes, create the cache directory explicitly, and check exit status.

Do not port blurred-art backgrounds, Cava, or dominant-color extraction for the
first version. They add dependencies and visual noise without improving the
core controls.

## Timeline and seeking

Use the local `StyledSlider` with the actual seconds range:

```qml
from: 0
to: Math.max(player?.length ?? 0, 1)
value: player?.position ?? 0
enabled: player?.canSeek && player?.positionSupported
onMoved: player.position = value
```

Using seconds instead of a normalized 0–1 range makes tooltip/time formatting
and seeking clearer. The tooltip formatter should display `m:ss` or `h:mm:ss`.

Guard all timeline calculations against missing/zero length. Quickshell exposes
both `positionSupported` and `lengthSupported`; players are not required to
provide every metadata or control property.

For non-seekable players, retain the same visual track as a disabled/read-only
progress display rather than making the whole row jump or disappear. The
implemented page also retains the timeline when position or length metadata is
unavailable, using `0:00` labels and a zero-position disabled track so track
changes cannot alter the layout.

The 1-second refresh timer should run only while:

- this page is active;
- a player is playing; and
- position is supported.

The existing bar has its own timer because it displays progress continuously.
If both bar and page use the same player, duplicate 1Hz signal emissions are
harmless but unnecessary. A shared media source could eventually drive one
refresh signal for both.

## Controls and capability checks

Every control must follow its corresponding MPRIS capability:

| Control | Enable condition | Action |
|---|---|---|
| Previous | `canGoPrevious` | `previous()` |
| Play | `canPlay` | `play()` or `togglePlaying()` |
| Pause | `canPause` | `pause()` or `togglePlaying()` |
| Next | `canGoNext` | `next()` |
| Seek | `canSeek && positionSupported` | assign `position` |
| Shuffle | `shuffleSupported && canControl` | assign `shuffle` |
| Repeat | `loopSupported && canControl` | cycle `loopState` |
| Player volume | `volumeSupported && canControl` | assign `volume` |

Player volume is distinct from the system output volume already controlled by
`VolumeSource`. It should be omitted initially to avoid presenting two similar
volume controls in one status panel. Shuffle and repeat are useful secondary
controls but can come after the primary transport and seek controls.

The required local Material ligatures were verified against
`assets/fonts/MaterialIconsRound-Regular.otf`:

```text
music_note
skip_previous
skip_next
play_arrow
pause
shuffle
repeat
repeat_one
volume_up
open_in_new
```

## Metadata and app identity

Use Quickshell's guarded convenience properties instead of reading the raw
metadata map:

- `trackTitle`
- `trackArtist`
- `trackAlbum`
- `trackArtUrl`

The documentation explicitly notes that these properties compensate for bad
player metadata.

For the player heading, `identity` is the simplest label. `desktopEntry` can be
resolved through `DesktopEntries.byId(...)` if an application icon is desired,
but that is optional. The cover image and player identity are enough for a
first version, avoiding another icon-resolution path.

Fallback labels should be local and predictable:

```text
Unknown title
Unknown artist
No active player
```

Do not render blank rows merely because album or artist metadata is absent.

## Component boundary

Recommended file:

```text
Modules/StatusPanel/Widgets/Media.qml
```

Split the current `Modules/Center/Media.qml`; do not move the whole file. It is
still the bar's visual component (`WrapperMouseArea`, progress canvas, icon,
and label), so that presentation remains under `Modules/Center/`.

Move its MPRIS-facing state into:

```text
Sources/Media.qml               registered as singleton MediaSource
```

with an interface such as:

```qml
readonly property list<MprisPlayer> players
property MprisPlayer selectedPlayer
readonly property MprisPlayer activePlayer
readonly property real progress
function selectNextPlayer()
function selectPreviousPlayer()
function togglePlaying()
function previous()
function next()
```

`MediaSource` should also own the 1-second `positionChanged()` timer. The bar
needs live progress even while the detailed page is closed, so centralizing the
timer does not create otherwise unnecessary background work. The detailed page
then adds presentation and seeks by assigning the selected player's `position`.
No subprocess or cache management belongs in either visual component.

Register it in `qmldir` as `singleton MediaSource 1.0 Sources/Media.qml`, matching
existing names such as `BatterySource`, `VolumeSource`, and `BrightnessSource`.
Using `MediaSource` also avoids a name collision with the existing visual
`Media` component.

## Collapse summary

Without To Do, the compact bottom row can show:

```text
Tuesday, April 11  •  Track title — Artist
```

If no player is active, show only the date. Elide the media portion so it cannot
force the collapsed group wider than the panel. Clicking the summary could
expand to the previously selected tool; it should not implicitly switch to
Media unless that behavior is explicitly wanted.

## Implementation status

The shared media implementation is complete and user-validated:

- `Sources/Media.qml` owns active-player selection, the 1Hz position refresh,
  transport actions, progress, and endpoint navigation.
- Both `Modules/Center/Media.qml` and the status-panel Media page consume
  `MediaSource`.
- The detailed page includes cover art fallback, metadata, elapsed/total time,
  seeking, previous/play-pause/next controls, empty state, and an always-visible
  MPRIS endpoint count/switcher.
- Nullable MPRIS capability bindings are normalized to booleans to avoid QML
  `undefined` assignment warnings.
- Real playback, seeking, player appearance/disappearance, and empty state were
  confirmed by the user.
- Zen/Firefox exposes multiple media tabs as one MPRIS endpoint, so the browser's
  active media session is shown and individual tabs cannot be switched here.
- Shuffle/repeat controls were left out as optional scope.

## Implemented phases

1. Built `Modules/StatusPanel/Widgets/WidgetGroup.qml` with the three pages:
   Calendar, Timer, and Media.
2. Added `Modules/StatusPanel/Widgets/Media.qml` with empty state, cover art,
   metadata, timeline, and transport controls.
3. Verified behavior with actual local players, including seeking, position
   refresh, and player disappearance.
4. Added MPRIS endpoint count and navigation.
5. Deferred optional shuffle/repeat controls.
6. Kept both media views on the shared `MediaSource` and filtered the known
   `playerctld` proxy entry.

The compact Waffle pane is the best geometric inspiration; the Material
`PlayerControl` is the best behavioral reference. Combining those two while
retaining the local Catppuccin primitives gives the requested feature without
pulling in upstream's popup, effects, Cava, or service framework.
