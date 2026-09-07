## Handoff: Quickshell primary-bar migration

### Goal
Rebuild the upstream `ii` primary bar incrementally in `./`, retaining Catppuccin and avoiding the unwanted upstream feature bulk. Do **not** copy the upstream panel family/config/service system wholesale.

### Current state
The current config is live at:

```text
/home/otard/.config/quickshell/default
```

It is a Git repository.

The upstream reference remains untouched at:

```text
/home/otard/.config/quickshell/dots-hyprland/dots/.config/quickshell/ii
```

Quickshell runs this local config through the enabled user service:

```bash
systemctl --user restart quickshell.service
```

Do not launch a separate unmanaged Quickshell instance for validation.

### Design decisions made

- Catppuccin Frappé remains the fixed theme.
- Main bar is attached to the screen edge, with side droops.
- Main bar height is `40px`, matching upstream's base bar height.
- The main bar background is Catppuccin `crust`.
- Interior `BarGroup` containers use a horizontal `mantle → base → mantle` gradient.
- `PowerMenu.qml` removed from the bar; will be replaced with a proper session panel later.
- `Brightness.qml` remains available but is not currently placed on the bar.
- Open Sans is the current text font.
- Shared UI text scale: S=12px, M=13px, L=15px.
- `Theme.accentText` — desaturated accent at high lightness (`withSaturation(accent, 0.1)` + `withLightness(..., 0.9)`), used for subtle accent-tinted labels across the bar.
- Status-panel layer hierarchy: `crust` panel → `mantle` sections → `base` controls → `surface0` nested controls/hover.
- Wide active toggles keep a neutral cell and accent only the icon container; active cells/icon containers use an `18px` rounded-rectangle radius. Single-cell active toggles retain an accent cell.
- The user does their own visual tweaking between sessions; do not assume the state of visual properties without reading the file.

### Important user instruction / learning

Do **not** treat screenshots as proof that a UI change is correct or even visible. Agents often miss fine visual details in screenshots and have repeatedly overclaimed success here.

For visual/UI work:

1. Verify source code and runtime logs.
2. Describe exactly what changed.
3. Ask the user to confirm visual correctness.
4. Do not say something "looks right," "matches upstream," or is "fixed" based only on a screenshot.

The user is the visual authority.

### Current bar layout

```
LEFT                    CENTER                          RIGHT
────────────────────────────────────────────────────────────────────
[Mode] [ActiveWindow]   [SystemMedia] [Workspaces] [Clock+Battery]  [StatusPill]
```

#### Left section
- `Mode` — submap/mode indicator
- `ActiveWindow` — app icon + truncated title for the focused window on that monitor

#### Center section (three `BarGroup` containers in a `Row`)
- `SystemMedia` — RAM meter + CPU meter + separator + media player
- `Workspaces` — per-monitor workspace dots with app icons and active indicator
- `Clock` + `Battery` — time/date with calendar popup, battery fill bar

#### Right section
- `StatusPill` — single pill containing all status indicators, including unread notifications (see below)

### StatusPill indicators (right to left visual order)

| Indicator | Condition | Icon | Color |
|---|---|---|---|
| Volume muted | `VolumeSource.sinkMuted` | `volume_off` | text |
| Mic recording | `Mic.active && !sourceMuted` | `mic` | red |
| Mic muted | `VolumeSource.sourceMuted` | `mic_off` | text |
| Keyboard layout | `Keyboard.available` | short text e.g. `US` | text |
| Notifications | DND or `Notifications.unreadCount > 0` | paused icon, or bell with unread-count badge | yellow in DND, accent when unread |
| Network | always | signal icon | teal/peach/red by signal |
| Bluetooth | `BluetoothSource.available` | `bluetooth_connected` / `bluetooth` / `bluetooth_disabled` | text |

- Scroll on pill → adjusts sink volume
- Click → toggles the status panel for that monitor

`Mic.active` uses `PwNodeLinkTracker` to detect real recording apps, excluding meters like pavucontrol.

### Bottom tools panel

The bottom status-panel section is implemented as one collapsible tool group:

- Calendar, Timer, and Media pages selected from a left navigation rail.
- A 350px expanded body and compact collapsed date/media summary.
- Animated collapse/expand and user-confirmed directional fade/slide tool switching.
- Selected-tool and collapsed state persist globally through `StatusPanelState` and `DocumentStore`.
- Shuffle/repeat media controls are intentionally out of scope; the user does not want shuffle.
- User-confirmed Calendar, collapse, Pomodoro, stopwatch, and media controls.
- Media progression uses the reusable slider's Wavy style while playing and Thin style while paused; the stable-height cross-fade and persistent Canvas were user-confirmed smooth.
- Native MPRIS media source shared by the bar and detailed Media page.
- Multiple-player navigation represents MPRIS endpoints, not individual browser tabs.
- Pomodoro and stopwatch state persist across service reloads through `DocumentStore`.
  Operational timer state uses wall-clock timestamps; stored lap durations are historical only.

### File inventory

#### Root
- `shell.qml` — thin panel host, one `PanelWindow` per screen via `Variants`
- `Theme.qml` — Catppuccin palette, typography, bar geometry, helper functions
- `qmldir` — module registry

#### Components/
- `BarGroup.qml` — padded gradient container; `padding` property works via anchor margins
- `RoundCorner.qml` — droop geometry for bar corners
- `MaterialSymbol.qml` — Material Icons Round font wrapper; use `anchors.fill` + text alignment, not `anchors.centerIn`, for correct glyph centering
- `StyledSlider.qml` — reusable Thin/Regular/Wide/Wavy slider with markers, stable handle geometry, and animated track transitions
- `WavyLine.qml` — persistent Canvas wave renderer used by the Wavy slider style
- `StyledText.qml` — NativeRendering text base
- `Pill.qml`, `OuterPill.qml` — visually transparent legacy wrappers; not used in new code

#### Modules/
- `PrimaryBar.qml` — layout root
- `Left/` — `Mode`, `ActiveWindow`
- `Center/` — `SystemMedia`, `ResourceMeter`, `Media`, `Workspaces`, `Clock`, `Battery`
- `Right/StatusPill.qml` — right indicator pill and status-panel trigger
- `Right/NotificationStatus.qml` — DND icon or unread-notification bell with a count badge
- `StatusPanel/StatusPanel.qml` — per-monitor right-edge overlay host; defaults closed after being temporarily forced open for layout development
- `StatusPanel/StatusPanelContent.qml` — panel surface and content layout
- `StatusPanel/QuickToggles.qml` — four-column Android-style grid: two-cell Wi-Fi/Ethernet/Bluetooth/audio controls and one-cell idle-inhibit/mic controls
- `StatusPanel/Widgets/WidgetGroup.qml` — collapsible bottom group, navigation rail, compact summary, and content stack
- `StatusPanel/Widgets/WidgetSelector.qml` — Calendar/Timer/Media rail selector
- `StatusPanel/Widgets/Calendar.qml` — month calendar with navigation and current-day highlighting
- `StatusPanel/Widgets/Timer.qml` — Pomodoro and stopwatch pages
- `StatusPanel/Widgets/Media.qml` — active-player metadata, art, timeline, transport, and player-endpoint navigation
- `Legacy/` — unplaced former bar modules: `Brightness`, `KeyboardLayout`, `Misc`, `Network`, `PowerMenu`, `StatusCluster`, `Volume`

#### Sources/
- `Battery.qml` — UPower + sysfs fallback
- `Bluetooth.qml` — Quickshell Bluetooth adapter/device state and toggle API
- `Brightness.qml` — brightnessctl
- `IdleInhibit.qml` — Wayland idle inhibitor
- `Keyboard.qml` — layout detection (Hyprland + basic fallback)
- `Mic.qml` — `PwNodeLinkTracker` recording detection
- `Network.qml` — separate Wi-Fi/wired device state, Wi-Fi radio query/toggle, Ethernet connect/disconnect, SSID/signal icons, and IP via `ip -j`
- `Notifications.qml` — notification facade: typed reconciliation of entries and groups by ID, grouping, newest-first ordering, DND, dismissal, action invocation; `MakoStrategy` backend
- `DocumentDb/DocumentStore.qml` — schema-validated atomic JSON document persistence
- `Media.qml` — shared MPRIS player selection, progress refresh, and transport actions
- `ResourceUsage.qml` — `/proc/meminfo` + `/proc/stat` polled every 2s
- `Time.qml` — system clock
- `Timer.qml` — timestamp-based Pomodoro/stopwatch state and persistence
- `StatusPanelState.qml` — persisted global selected-tool and collapsed presentation state
- `Volume.qml` — PipeWire sink/source state
- `WM.qml` — workspace + active-window proxy (Hyprland strategy); exposes `workspacesByMonitor`, `activeWindowByMonitor`, `workspaceAppsById`, `activeMode`

### Theme helpers

```qml
Theme.alpha(color, a)           // change opacity, preserve RGB
Theme.withLightness(color, l)   // change HSL lightness (0–1 absolute)
Theme.withSaturation(color, s)  // change HSL saturation (0–1 absolute)
Theme.accentText                // desaturated, light-tinted accent for labels
```

### Workflow that worked

1. Inspect the exact upstream component before porting visual behavior.
2. Copy/adapt the smallest useful primitive, not upstream's large `Config`, `Appearance`, panel-family, or service hierarchy.
3. Keep the current local data sources wherever possible.
4. Check `qs log -p /home/otard/.config/quickshell/default` after edits.
5. Use the user for visual confirmation.

### Workflow pitfalls to avoid

- Do not claim visual parity based on screenshots.
- Do not claim a component is upstream-accurate without checking the actual upstream QML.
- Do not introduce unavailable upstream dependencies blindly:
  - `Qt5Compat.GraphicalEffects` is unavailable here.
- Quickshell hot reload sometimes does not reconstruct nested modules or reload JavaScript helpers. When a restart is required, use the enabled user service:
  ```bash
  systemctl --user restart quickshell.service
  ```
  Do not launch a separate manual `qs -d` instance.
- Do not reintroduce visible standalone pills. Use `BarGroup` where grouping is intended.

### QML layout lessons

- Use `RowLayout`/`ColumnLayout` (from `QtQuick.Layouts`) over `Row`/`Column` positioners.
  Quickshell's own guide explicitly recommends this: layouts pixel-align, support `Layout.*`
  attached properties, and behave more predictably in nested contexts.
- Do **not** use `anchors` on direct children of a positioner (`Row`, `Column`). Use
  `verticalItemAlignment: Qt.AlignVCenter` on the `Row` itself, or switch to `RowLayout`
  with `Layout.alignment: Qt.AlignVCenter` on children.
- A `RowLayout` as the root of a component file, nested inside another `RowLayout`, causes
  its children to be merged/flattened into the outer layout. Use an `Item` as the component
  root with `implicitWidth`/`implicitHeight` set, and a `RowLayout` inside anchored to fill.
- `Text.implicitWidth` is read-only. Use `Layout.preferredWidth` instead when inside a layout.
- `anchors.centerIn: parent` on a `Text` centers the bounding box including line metrics,
  not the visual glyph. Use `anchors.fill: parent` with `horizontalAlignment: Text.AlignHCenter`
  and `verticalAlignment: Text.AlignVCenter` instead.
- `BarGroup.padding` works correctly because the inner `RowLayout` uses anchor margins
  (`leftMargin: root.padding`) rather than `anchors.centerIn`.
- `GridLayout.columnSpan` occupies columns but does not independently constrain every underlying column. For the four-column quick-toggle grid, columns 0–1 are constrained by the one-cell idle/mic controls; invisible one-cell `CellConstraint` items complete columns 2–3. With `uniformCellWidths: true`, all four columns then resolve equally. Layout-managed tiles use `Layout.preferredWidth` weights, never direct `width` assignments.
- Keep backend state, polling, and commands in `Sources/`; modules should bind to source properties/functions and contain presentation logic only.
- Always verify Material icon ligature names against the **actual font file** before using them.
  Upstream uses Material Symbols (new variable font); we use the static `MaterialIconsRound-Regular.otf`
  which has a different and smaller icon set. An invalid ligature name renders as individual ASCII
  characters — if center-aligned in a small box, these overflow into neighbouring elements, causing
  icons to appear in the wrong circle/container. Use `strings <font.otf>` or fonttools to check
  that an icon name is actually present. Add `clip: true` to icon container items as a safeguard.
- `MprisPlayer.position` does not update reactively by default. Drive it with a `Timer` that
  calls `player.positionChanged()` and uses `triggeredOnStart: true` for immediate update on
  resume. Do not cache position manually — some players emit spurious `positionChanged` with
  position = track length on pause, which corrupts the cached value.
- Do not place a Canvas inside a Repeater model that is rebuilt on every progress update. The
  Wavy slider keeps one full-width Canvas alive and reveals progress with a resizing clipped
  item; this avoids a visible blink on each MPRIS position refresh.

### Likely next work

1. Continue status panel: Wi-Fi/Bluetooth detail dialogs, and volume mixer.
3. System tray (`Quickshell.Services.SystemTray`).
4. Refactor `ActiveWindow`, `Workspaces`, `Clock`, `Network` away from structural `Pill`/`OuterPill` inheritance.
5. Consider switching workspace/active-window icon resolution to `IconImage` from `Quickshell.Widgets`
   (simpler than the manual `DesktopEntries` + Papirus path + fallback chain).
6. Brightness: decide placement (left-scroll upstream style vs. dedicated widget).
