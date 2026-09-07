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
    NotificationStatus { indicatorType: NotificationStatus.Dot }
    NetworkIndicator {}
    BluetoothIndicator {}
}
```

Each indicator in `Modules/Right/` is self-contained. It reads directly from
singletons and sets its own `visible` and `color`.

## NotificationStatus indicator types

`NotificationStatus` accepts an optional `indicatorType` property:

| Value                      | Behavior                          |
|----------------------------|-----------------------------------|
| `NotificationStatus.Number`| Badge shows unread count (default)|
| `NotificationStatus.Dot`   | Badge is a plain circle, no count |

The enum is declared in the component:

```qml
enum IndicatorType {
    Number,
    Dot
}
```

## Status panel transition

`StatusPanel` animates `StatusPanelContent` on open and close:

- **Opacity** — 0 → 1 on open, 1 → 0 on close
- **Y translate** — −20px → 0 on open, 0 → −20px on close
- **Duration** — 300 ms, `Easing.OutCubic`

The `PanelWindow` stays visible until `opacity` reaches 0, so the close
animation completes before the window is removed.
