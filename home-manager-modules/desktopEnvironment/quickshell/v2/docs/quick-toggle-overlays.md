# Quick toggle overlays

Overlay sub-dialogs for status-panel quick toggles. A two-cell toggle can open a
dialog with extra controls: pick a Wi-Fi network, choose a Bluetooth device,
mix per-app audio. This is the local equivalent of upstream (ii)'s per-toggle
`WindowDialog`.

Built: **WifiDialog**, **BluetoothDialog**, **AudioDialog**. Not built:
NightLightDialog (see [Deferred](#deferred)).

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
- Escape emits `dismissed` (handled centrally — see [Escape](#escape-precedence)).

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
`slideDistance`, `cardColor`. Signal: `dismissed`. Function: `close()`.

## Toggle interaction

Overlays apply to two-cell toggles only. A two-cell toggle splits into two hit
targets:

- The icon container (left circle/rounded square) runs the toggle action
  (`triggered`).
- The rest of the body opens or closes the overlay (`overlayRequested`).

One-cell toggles keep a single full-area hit target for `triggered` and never
open a dialog.

`QuickToggle.qml` implements the split with three `MouseArea`s gated by `span`:
a full-area body area for `overlayRequested`, then an icon-sized area declared
after it (so it sits on top) for `triggered`, plus the one-cell full-area area.
The icon hit target duplicates the icon container geometry (`x: 8`, `40x40`,
vertically centered). If the Row layout changes, update both.

Wiring (`StatusPanelContent.qml`):

```qml
WifiToggle {
    onOverlayRequested: wifiDialog.open = !wifiDialog.open
}
```

## Dialog layout

One `OverlayDialog` per toggle, each in its own subdir under `QuickToggles/`. No
shared swap host. Directory imports do not recurse, so `StatusPanelContent.qml`
imports each subdir explicitly (`import "QuickToggles/Wifi"` etc.).

```
QuickToggles/
  QuickToggle.qml          ← toggle base (infra)
  QuickToggleGrid.qml      ← grid (infra)
  OverlayDialog.qml        ← shared dialog shell (infra)
  *Toggle.qml              ← the toggles, flat
  Wifi/                    ← dialog + rows, per toggle
    WifiDialog.qml
    WifiNetworkRow.qml
    WifiPasswordDialog.qml
  Bluetooth/
    BluetoothDialog.qml
    BluetoothDeviceRow.qml
  Audio/
    AudioDialog.qml
    AudioStreamRow.qml
    AudioDeviceRow.qml
```

`OverlayDialog` stays at the top level — shared infra, not tied to one toggle.
Rows reach it with `import ".."` and reach `Components/` with `../../../../`.

To add a dialog: new `QuickToggles/<Name>/` dir, add `import "QuickToggles/<Name>"`
to `StatusPanelContent.qml`, and wire the toggle's `onOverlayRequested`.

## Escape precedence

One `Shortcut` in `StatusPanelContent` walks the chain top-down so the innermost
layer closes first: wifi password prompt → wifi dialog → bluetooth dialog →
audio dialog → panel. `OverlayDialog` does not grab focus itself, so dialogs do
not fight over focus. Panel close also closes every open dialog.

## Built dialogs

### WifiDialog

Files: `Wifi/WifiDialog.qml`, `WifiNetworkRow.qml`, `WifiPasswordDialog.qml`.
Source: `Sources/Network.qml`. Native `Quickshell.Networking`, no `nmcli`.

- **One-shot scan window per open.** On open: clear the snapshot, scan, append
  results as they arrive (no reorder); after 3s sort once and stop scanning. The
  list is frozen from there — no scroll jumps. Networks appearing later are
  missed until reopen. No refresh button.
- **Rescan-on-connect.** On connect NM re-creates the `WifiNetwork` objects,
  leaving stale references (blank ghost rows). Re-run the scan window on
  `ssidChanged` (guarded on non-empty ssid, skipped while the prompt is open) to
  reconcile and move the connected network to the top.
- **ScriptModel, not a raw array.** A raw JS-array-of-QObjects model crashes
  delegate incubation (`VDMListDelegateDataType::createMissingProperties`) when a
  network object is freed mid-update. `ScriptModel` launders object lifetimes and
  diffs incrementally. Rows also null-guard and collapse to height 0.
- **Separate password dialog.** `WifiPasswordDialog` is its own `OverlayDialog`
  stacked above the list. It owns the wrong-password/connecting state, stays open
  on `NoSecrets`, auto-closes on `connected`, and has a show/hide password eye.
- **Forget-on-cancel.** NM creates a profile on the first connect attempt, so a
  cancelled prompt calls `forgetNetwork()` to keep `known` honest. All close
  paths route through `closePasswordPrompt()`.

PSK flow: `net.connect()` first; if `connectionFailed(NoSecrets)` fires, show the
prompt, then `net.connectWithPsk(psk)`. The signal is per-`Network`, so each row
connects it directly — no re-emit from the singleton.

### BluetoothDialog

Files: `Bluetooth/BluetoothDialog.qml`, `BluetoothDeviceRow.qml`. Source:
`Sources/Bluetooth.qml`. Native `Quickshell.Bluetooth`, no `bluetoothctl`.

- **Live list, no frozen window.** Pairing is interactive, so the list is a
  `ScriptModel` straight over the source's sorted `friendlyDevices` and stays
  live. Re-sort moves a device to the top as it connects. `ScriptModel` for the
  same freed-object reason as wifi.
- **Discovery only while open.** `onOpenChanged` toggles
  `BluetoothSource.setDiscovering(true/false)`; `setDiscovering` guards redundant
  writes (BlueZ warns when stopping discovery that never started).
- **Expandable rows, one at a time.** Collapsed shows icon, name, status,
  battery. Expanded reveals Connect/Disconnect and Pair/Forget. A busy gate
  (pairing/connecting/disconnecting) dims the row and disables its buttons.
- **No failure signal.** Bluetooth has no `connectionFailed` equivalent. A failed
  pair silently leaves the row unpaired; infer failure from `dev.pairing` going
  false while `paired`/`bonded` stay false.
- **No secret flow.** Bluetooth pairing has no PSK equivalent in the API.
- **Presentation in the singleton.** `deviceLabel`, `deviceSymbol`, `stateLabel`,
  `batteryIcon`, `deviceBusy` live in the source; rows stay dumb.

Not available: RSSI/signal strength — no property on `BluetoothDevice` in v0.3.1.

### AudioDialog

Files: `Audio/AudioDialog.qml`, `AudioStreamRow.qml`, `AudioDeviceRow.qml`.
Sources: `Sources/Audio.qml` (new), `Sources/AudioProfile.qml` +
`Sources/AudioProfile/NullProfileStrategy.qml`. Native `Quickshell.Services.Pipewire`.

- **One dialog, three tabs.** Output / Input / Devices in a single
  `OverlayDialog`. `tab` property + `openTab(name)`. A `Loader` swaps the tab body
  so the card sizes to the active tab only. The Audio toggle opens at Output;
  Input and Devices are reached by the in-dialog tab bar. The Microphone toggle
  stays one-cell (mute only, no dialog).
- **New source, no migration yet.** `Sources/Audio.qml` is additive; its overall
  sink/source helpers mirror `VolumeSource` so consumers can migrate by rename
  later. `VolumeSource`/`Mic` untouched.
- **Streams from links, not stream nodes.** An app can hold an idle, unlinked
  stream open (browsers do this for `getUserMedia`). Listing every stream node
  shows those as "in use". Instead the lists come from `PwNodeLinkTracker` on the
  default sink/source — the app on the far end of each link — matching the bar's
  `Mic.active` logic so dialog and bar agree. Tradeoff: a stream on a non-default
  device does not appear.
- **Meter filter.** Peak-meter/monitor streams (pavucontrol) are dropped by a
  name blocklist (`meterApps`), checking both `node.name` and `application.name`
  — same idea as `Mic.qml`.
- **Global PwObjectTracker.** `volume`/`muted`/`properties` are invalid unless
  the node is bound; the source tracks defaults + all listed streams/devices.
- **ScriptModel for every list**, same freed-object reason as wifi/bluetooth.
- **Device pick = preferred default.** `AudioDeviceRow` click sets
  `Pipewire.preferredDefaultAudioSink`/`Source` (a hint); the selected mark reads
  back `defaultAudioSink`/`Source`.
- **Overall slider matches the side panel** (`StyledSlider`, `Wide` track, marker
  icons). The old side-panel volume slider was removed — volume lives here now.

## Deferred

- **NightLightDialog** — not built. Would need `Sources/NightLight.qml` (enabled
  + color temperature via hyprsunset, likely the gamma/brightness split from
  `migration/diff.md`). Ref: upstream `sidebarRight/nightLight/NightLightDialog.qml`.
- **Audio card profiles** — the codec/profile dropdown per device is not exposed
  by `Quickshell.Services.Pipewire`. Scaffolded behind a strategy proxy
  (`Sources/AudioProfile.qml` → `NullProfileStrategy`, same pattern as
  `Sources/WM.qml`), so the Devices-tab profile section stays hidden. Future
  backend: `PactlStrategy` (needs `pactl`, currently absent) or `PwDumpStrategy`
  (`pw-dump` + `pw-cli set-param Profile`).
- **Wifi** — deliberate disconnect / forget on a connected/known network. Source
  has `disconnectNetwork()`/`forgetNetwork()`; no affordance yet (row click
  disabled while connected).
- **Bluetooth** — `trusted` toggle (`setTrusted()` exists), rename/alias via
  `dev.name`, adapter `discoverable`/`pairable`, and a pair-failure timeout hint.

## Source APIs

What the native Quickshell services provide for these dialogs. All confirmed
against v0.3.x docs; no external CLIs needed except for audio card profiles.

### Quickshell.Networking (Wifi)

| Need | API |
|---|---|
| AP list | `WifiDevice.networks.values` — each a `WifiNetwork` |
| SSID / strength / security | `net.name`, `net.signalStrength` (0–1), `net.security` |
| Active / known / connecting | `net.connected`, `net.known`, `net.stateChanging` |
| Scan on/off | `WifiDevice.scannerEnabled` (writable) |
| Connect / with PSK | `net.connect()` / `net.connectWithPsk(psk)` |
| Disconnect / forget | `net.disconnect()` / `net.forget()` |
| Failure reason | `connectionFailed(reason)` per `Network`; `ConnectionFailReason` |
| Wifi radio | `Networking.wifiEnabled` (writable), `wifiHardwareEnabled` (ro) |

Gaps and resolutions:
- No `autoconnect`. `wiredEnabled` derives from `wiredDevice.network.state`
  (`Connecting`/`Connected` = intent on; else off), keeping the `shapeOn` (intent)
  vs `active` (connectivity) split in `EthernetToggle`.
- Scanner runs continuously while `scannerEnabled` — enabled only during the scan
  window (battery).

### Quickshell.Bluetooth

| Need | API |
|---|---|
| Device list | `adapter.devices.values` — each a `BluetoothDevice` |
| Discovery on/off | `adapter.discovering` (writable) |
| Identity | `dev.name`, `dev.deviceName`, `dev.address`, `dev.icon` |
| State | `dev.state` (`BluetoothDeviceState`), `dev.connected` |
| Paired / bonded / trusted | `dev.paired`, `dev.bonded`, `dev.trusted` (writable) |
| Battery | `dev.batteryAvailable`, `dev.battery` (0–1) |
| Connect / disconnect | `dev.connect()` / `dev.disconnect()` |
| Pair / cancel / unpair | `dev.pair()`, `dev.pairing`, `dev.cancelPair()`, `dev.forget()` |

Gaps: no failure signal (infer from `pairing`), no RSSI. Scope to the default
adapter (`adapter.devices`) to avoid cross-adapter noise.

### Quickshell.Services.Pipewire (Audio)

| Need | API |
|---|---|
| Overall out / in | `Pipewire.defaultAudioSink` / `defaultAudioSource`, `.audio.volume`/`.muted` |
| All nodes | `Pipewire.nodes.values` — each a `PwNode` |
| App vs device / out vs in | `PwNode.isStream` / `isSink`; `audio` non-null = audio node |
| Per-node volume/mute | `node.audio.volume`/`.muted` — invalid unless bound (`PwObjectTracker`) |
| Node label | `properties["application.name"]`, `description`, `media.name`, `nickname`, `name` |
| App-to-device links | `PwNodeLinkTracker` — `linkGroups[].source`/`.target`, `.state` (`PwLinkState`) |
| Set / read default | write `preferredDefaultAudioSink`/`Source`; read `defaultAudioSink`/`Source` |
| Card profile | **none** — no Device/Profile type in the module |

Device lists use booleans (`!isStream && audio && isSink` = output devices, etc.);
app streams use links (see AudioDialog above), not raw stream nodes.

## Potential alternate: click routing

The current split is by region (icon vs body). A likely later change is
left-click vs right-click instead: left-click anywhere toggles, right-click
anywhere opens the overlay. This matches the upstream android-panel convention
and removes the duplicated icon geometry, trading a discoverable two-region
target for a hidden right-click. Revisit when the toggle set grows.

## References

- `bar-architecture.md` — panel layout and transition.
- `slider.md` — the shared `StyledSlider`.
- `migration/diff.md:44-58` — upstream dialog inventory (gamma/brightness, mic).
- `research/upstream-bottom-tools.md` — upstream widget-porting approach.
- Upstream base: `modules/common/widgets/WindowDialog.qml`.
- API docs: [Networking](https://quickshell.org/docs/v0.3.1/types/Quickshell.Networking/),
  [Bluetooth](https://quickshell.org/docs/v0.3.1/types/Quickshell.Bluetooth/),
  [Pipewire](https://quickshell.org/docs/v0.3.1/types/Quickshell.Services.Pipewire/).
