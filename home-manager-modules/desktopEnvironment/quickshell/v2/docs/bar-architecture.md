# Bar architecture

## Layout ownership

`Modules/PrimaryBar.qml` owns all layout and grouping for the bar. It places
each section and wraps groups in `BarGroup`. Individual components do not wrap
themselves in `BarGroup`.

The three sections are:

- `leftSection` — `Mode` and `ActiveWindow`
- `centerSection` — `SystemMedia`, `Workspaces`, `Clock`, `Battery`
- right — a `BarGroup` containing `StatusPill`

## StatusPill composition

`StatusPill` is a layout container, not a self-contained widget. It exposes:

```qml
default property alias indicators: layout.data
```

`PrimaryBar` passes indicator components as children:

```qml
StatusPill {
    onToggleRequested: root.toggleStatusPanel()

    VolumeMutedIndicator {}
    MicIndicator {}
    KeyboardIndicator {}
    NotificationStatus { indicatorType: NotificationStatus.Number }
    NetworkIndicator {}
    BluetoothIndicator {}
}
```

Each indicator in `Modules/Right/` is self-contained. It reads directly from
singletons and sets its own `visible` and `color`.

## NotificationStatus indicator types

`NotificationStatus` accepts an optional `indicatorType` property:

| Value                       | Behavior                                                    |
|-----------------------------|-------------------------------------------------------------|
| `NotificationStatus.Number` | Bell icon + pill badge with unread count (default)          |
| `NotificationStatus.Dot`    | Bell swaps to `notifications_unread` icon, no badge         |

The enum is declared in the component:

```qml
enum IndicatorType {
    Number,
    Dot
}
```

In `Number` mode, the badge is anchored `top`/`right` of the bell with
`topMargin: 7` and `rightMargin: -7` so it sits outside the bell's bounding
box. The parent `Item` sizes to `Theme.fontL` square; the badge overflows
freely since `clip` defaults to `false`.

## MaterialSymbol font

`Components/MaterialSymbol.qml` loads
`assets/fonts/MaterialSymbolsRounded.ttf` — the variable Material Symbols
Rounded font from the Google material-design-icons repository. The older
`MaterialIconsRound-Regular.otf` did not include newer glyphs such as
`notifications_unread`.

## WM singleton (`Sources/WM.qml`)

`WM` is a proxy singleton. Bar modules import only `WM`; the backend strategy is
swapped by changing `impl`.

The Hyprland strategy (`Sources/WM/HyprlandStrategy.qml`) seeds state at startup
by running `hyprctl monitors` then `hyprctl clients` in sequence. After that, live
updates come from two sources:

- **`Hyprland.rawEvent`** — `activewindow` immediately writes the focused window
  to `activeWindowByMonitor` using the monitor *name* string directly.
- **`refreshClients()`** — rebuilds `activeWindowByMonitor` and `workspaceAppsById`
  from a fresh `hyprctl clients` run. All other window events (`openwindow`,
  `closewindow`, `movewindow`, `windowtitle`) go through this path.

### Post-wake correctness

`refreshClients()` maps each client's numeric `monitor` field to a monitor name
using a live snapshot of `Hyprland.monitors.values` taken at call time. This
snapshot must be rebuilt on every call — not cached at startup — because Hyprland
re-enumerates monitors on wake from sleep and the numeric IDs can change. A stale
map produces an empty `activeWindowByMonitor`, which hides `ActiveWindow`.

The `rawEvent` immediate-write path is unaffected by this because it uses the
monitor name string directly from `focusedMonitorName`.

## Status panel transition

`StatusPanel` animates `StatusPanelContent` on open and close:

- **Opacity** — 0 → 1 on open, 1 → 0 on close
- **Y translate** — −20px → 0 on open, 0 → −20px on close
- **Duration** — 300 ms, `Easing.OutCubic`

The `PanelWindow` stays visible until `opacity` reaches 0, so the close
animation completes before the window is removed.
