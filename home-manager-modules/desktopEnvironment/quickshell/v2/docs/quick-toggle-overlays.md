# Quick toggle overlays

Overlay sub-dialogs for status-panel quick toggles. Upstream (ii) has a
`WindowDialog` per toggle for extra controls: pick a Wi-Fi network, choose a
Bluetooth device, set night-light temperature, per-app volume. This is the
local equivalent.

## OverlayDialog

`Modules/StatusPanel/QuickToggles/OverlayDialog.qml` is one reusable component.
It owns the scrim, placement, sizing, and in/out animation. Concrete dialogs
supply only content.

Behavior:

- Fills the panel content and sits on top (`z: 100`).
- Scrim dims the panel; clicking it dismisses.
- Card centers in the panel, slides down and fades on open, reverses on close.
- Height derives from content. `contentHost.implicitHeight` reads
  `childrenRect.height`, so the card grows to fit. Do not anchor the content
  host to fill the card — that inverts the sizing and the card stays fixed.
- `dialogHeight > 0` fixes the height instead of deriving it.
- Escape emits `dismissed`.

Usage:

```qml
OverlayDialog {
    id: wifiDialog
    onDismissed: close()

    // any content; the card sizes to it
    Column { ... }
}
// open with: wifiDialog.open = true
```

Properties: `open`, `dialogWidth`, `dialogHeight` (0 = derive), `contentPadding`,
`slideDistance`. Signal: `dismissed`. Function: `close()`.

## Toggle interaction

Overlays apply to two-cell toggles only. A two-cell toggle splits into two hit
targets:

- The icon container (left circle/rounded square) runs the toggle action
  (`triggered`).
- The rest of the body opens or closes the overlay (`overlayRequested`).

One-cell toggles keep a single full-area hit target for `triggered`.

`QuickToggle.qml` implements the split with three `MouseArea`s gated by `span`:
a full-area body area for `overlayRequested`, then an icon-sized area declared
after it (so it sits on top) for `triggered`, plus the one-cell full-area area.

The icon hit target duplicates the icon container geometry (`x: 8`, `40x40`,
vertically centered). If the Row layout changes, update both.

Wiring example (`StatusPanelContent.qml`):

```qml
WifiToggle {
    onOverlayRequested: wifiDialog.open = !wifiDialog.open
}
```

## Content selection

Each concrete toggle supplies its own dialog content chosen by toggle type
(Wi-Fi list, Bluetooth devices, night-light temperature, volume mixer). Open
question: one shared `OverlayDialog` host in the panel with swapped content, or
one `OverlayDialog` owned per toggle. Not yet decided.

## Potential alternate: click routing

The current split is by region (icon vs body). A likely later change is
left-click vs right-click instead:

- Left-click anywhere on the toggle runs the toggle action.
- Right-click anywhere opens the overlay.

This matches the upstream android-panel convention (LMB toggle, RMB/hold for the
sub-dialog) and removes the duplicated icon geometry. It trades the discoverable
two-region target for a hidden right-click. Revisit when the toggle set grows.
