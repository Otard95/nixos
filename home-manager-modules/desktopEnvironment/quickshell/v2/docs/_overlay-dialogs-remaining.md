# Overlay dialogs — remaining work (scratch)

Temporary planning note. Not tracked (leading `_`). The overlay shell exists;
the real dialog content and the source/service backing do not.

## Done

- `Modules/StatusPanel/QuickToggles/OverlayDialog.qml` — reusable overlay shell
  (scrim, centering, content-derived sizing, in/out animation).
- `Modules/StatusPanel/QuickToggles/QuickToggle.qml` — two-cell toggles split:
  icon = `triggered`, body = `overlayRequested`.
- Demo hook: `Modules/StatusPanel/StatusPanelContent.qml` wires `WifiToggle`
  `onOverlayRequested` to a placeholder dialog. Still in place, remove later.
- `Sources/Network.qml` — rewritten to use `Quickshell.Networking` natively.
  Removed all `nmcli` / `ip` process machinery (polling, `Process`, `Timer`).
  `wifiEnabled` now reads/writes `Networking.wifiEnabled` directly. `wiredEnabled`
  derived from `network.state` (`Connecting` or `Connected`) instead of the
  unavailable `autoconnect`. Added `wifiNetworks`, `scanning`, `setScanning()`,
  `connectNetwork()`, `connectNetworkWithPsk()`, `disconnectNetwork()`,
  `forgetNetwork()` for the WifiDialog. Then added the list-presentation
  helpers: `friendlyWifiNetworks` (deduped by SSID, connected-first, strength
  sort), `isSecure()`, `needsPsk()`, `strengthIcon()` (also reused by
  `wifiIcon`).

See `docs/quick-toggle-overlays.md` for the component and interaction model.

## Remaining

Each dialog needs new source functionality. The sources today expose only
toggle-level state, enough for the grid, not the dialogs. Keep `OverlayDialog`
dumb; put list/scan/connect logic in the singleton source.

### WifiDialog — done

Files: `Modules/StatusPanel/QuickToggles/WifiDialog.qml`,
`WifiNetworkRow.qml`, `WifiPasswordDialog.qml`.

Design decisions made during the build:

- **One-shot scan window per open.** On open: clear the snapshot, scan, append
  results as they arrive (no reorder). After 3s: sort once, stop scanning. The
  list is frozen from there — no churn, no scroll jumps, always stable. Trade:
  networks appearing after the window are missed until reopen (fine — the ones
  you care about show in the first scan). No refresh button.
- **Append-only merge, then one sort.** `mergeSnapshot()` (append-only) runs
  only while the 3s window is active; `sortSnapshot()` sorts the existing set
  in place when the window ends. In-place sort keeps the same objects, so it is
  safe after the source list collapses to known-only.
- **Rescan-on-connect.** On connect NM re-creates the `WifiNetwork` objects for
  the SSID, leaving stale references in the frozen snapshot (they render as a
  blank ghost row — white card, lone bookmark). `beginScanWindow()` re-runs the
  scan window on `ssidChanged` to reconcile with fresh valid objects and move
  the connected network to the top. Guarded on a non-empty ssid so switching
  networks (drop → "" → new name) triggers one cycle, not two, and skipped while
  a password prompt is open.
- **Row null-guards.** `WifiNetworkRow` has a `valid` gate (`network` present
  and named) that collapses the row to height 0 instead of rendering a ghost;
  all `network.` reads use optional chaining. Belt-and-braces with the rescan.
- **ScriptModel, not a raw array.** The ListView model is a `ScriptModel`
  wrapping the snapshot. A raw JS-array-of-QObjects model crashes delegate
  incubation (`VDMListDelegateDataType::createMissingProperties`) when a
  network object is freed mid-update; `ScriptModel` launders object lifetimes
  (v0.3.1: "Fixed crashes from accessing freed objects laundered through a
  ScriptModel") and diffs incrementally.
- **Show/hide password.** `WifiPasswordDialog` has an eye toggle
  (`visibility` / `visibility_off`) that flips `echoMode`; resets on close.
- **Separate password dialog.** `WifiPasswordDialog` is its own `OverlayDialog`
  stacked above the list (`crust` card vs the list's `mantle`). It owns the
  wrong-password / connecting state, stays open on `NoSecrets`, auto-closes on
  `connected`. Scanning pauses while it is open.
- **Forget-on-cancel.** NM creates a connection profile on the first connect
  attempt, so a cancelled prompt would leave the AP marked `known`.
  `WifiDialog.closePasswordPrompt()` calls `forgetNetwork()` when the network
  never connected, keeping `known` honest. All close paths (cancel button,
  escape, panel close, dialog dismiss) route through it.
- **Escape priority.** One `Shortcut` in `StatusPanelContent`: password prompt
  first, then the wifi dialog, then the whole panel. `OverlayDialog` no longer
  grabs focus itself (avoids two dialogs fighting over focus).

Crashes hit during the build, both resolved:

- v0.3.0 use-after-free in the NM backend (`NMWirelessNetwork::updateReferenceAp`
  on `AccessPointRemoved`) when an AP disappears mid-association. Fixed upstream
  in v0.3.1 ("Fixed crashes when a wifi network disappear") — requires the
  version bump.
- Delegate-incubation crash (`VDMListDelegateDataType::createMissingProperties`)
  from a raw JS-array model holding a freed object. Fixed by wrapping the model
  in `ScriptModel` (see above).

**Requires Quickshell ≥ v0.3.1.**

TODO (deferred — interaction design undecided):

- Disconnect from the connected network. Row click is disabled while connected;
  needs a deliberate action (long-press, or a trailing button on the row).
  Source already has `disconnectNetwork()`.
- Forget a known network on purpose (distinct from forget-on-cancel). Source
  already has `forgetNetwork()`.

Ref: upstream `modules/ii/sidebarRight/wifiNetworks/WifiDialog.qml`.

### BluetoothDialog

- Source: `Sources/Bluetooth.qml` (adapter enabled + connected count only).
- Needs: device list (paired + discovered), discovery start/stop + discovering
  state, pair/connect/disconnect/trust per device.
- Ref: upstream `modules/ii/sidebarRight/bluetoothDevices/BluetoothDialog.qml`.

### VolumeDialog ×2 (output, input)

- Source: `Sources/Volume.qml` (default sink/source only), `Sources/Mic.qml`.
- Needs: per-app stream list from Pipewire (output nodes, input nodes),
  per-stream volume + mute get/set, input dialog source-device pick.
- Ref: upstream `modules/ii/sidebarRight/volumeMixer/VolumeDialog.qml` +
  `VolumeDialogContent.qml`.

### NightLightDialog

- Source: none yet. Add `Sources/NightLight.qml`.
- Needs: enabled state + temperature value/setter (hyprsunset); likely the
  gamma/brightness split from the migration diff.
- Ref: upstream `modules/ii/sidebarRight/nightLight/NightLightDialog.qml`.

## Network source research

### Quickshell.Networking v0.3.0 API coverage

All WifiDialog needs are available natively. No nmcli required for the dialog.

| Need | API |
|---|---|
| AP list | `WifiDevice.networks.values` — each entry is a `WifiNetwork` |
| SSID / strength / security | `net.name`, `net.signalStrength` (0–1), `net.security` (`WifiSecurityType`) |
| Active / known | `net.connected`, `net.known` |
| Connecting state | `net.stateChanging` |
| Scan on/off | `WifiDevice.scannerEnabled` (writable bool) |
| Connect (known) | `net.connect()` — emits `connectionFailed(NoSecrets)` if PSK needed |
| Connect with PSK | `net.connectWithPsk(psk)` — backend may store PSK for future `connect()` |
| Disconnect / forget | `net.disconnect()` / `net.forget()` |
| Failure reason | `connectionFailed(reason)` signal on each `Network`; `ConnectionFailReason` enum |
| Wifi radio | `Networking.wifiEnabled` (writable) + `Networking.wifiHardwareEnabled` (read-only) |
| `ConnectionState` values | `Unknown`, `Connecting`, `Disconnecting`, `Connected`, `Disconnected` |
| `WifiSecurityType` values | `Open`, `StaticWep`, `DynamicWep`, `Leap`, `WpaEap`, `Wpa2Psk`, `WpaPsk`, `Sae` |

`WiredDevice` adds `linkSpeed`, `hasLink`, `network`. No `autoconnect` property
exists in the native API (see resolution below).

### NetworkSource consumer audit

`Modules/Legacy/Network.qml` is never loaded — dead code. Actual consumers:

| Property / function | Consumer |
|---|---|
| `wifiEnabled`, `wifiConnected`, `ssid`, `wifiIcon`, `toggleWifi()` | `WifiToggle.qml` |
| `wiredDevice` (null check), `wiredConnected`, `wiredEnabled`, `toggleWired()` | `EthernetToggle.qml` |
| `icon`, `available`, `isWifi`, `signalStrength` | `NetworkIndicator.qml` |

Properties only referenced in `Legacy/`: `ipv4`, `ipv6`, `macAddress`,
`deviceName`. All removed along with the `ipProc` process and its 30s timer.

### `autoconnect` gap

`wiredEnabled` was `wiredDevice?.autoconnect`, which does not exist in the native
API. Resolution: derive it from `wiredDevice.network.state`. States
`Connecting` and `Connected` mean the user wants the connection; `Disconnecting`
and `Disconnected` mean they explicitly cut it. This preserves the semantic split
between `shapeOn` (intent) and `active` (actual connectivity) in `EthernetToggle`.

### `connectionFailed` wiring decision

`connectionFailed(reason)` is a signal on each `Network` object, not on the
device. The dialog renders a row per AP; each row can connect `onConnectionFailed`
directly on its network object. No re-emit from the singleton needed.
PSK flow: call `net.connect()` first; if `NoSecrets` fires, show the password
prompt, then call `net.connectWithPsk(psk)`.

### Scanner lifetime (open)

`WifiDevice.scannerEnabled = true` keeps scanning continuously — battery cost.
Options: enable only while the dialog is open (cleanest), or pulse on open then
disable after the first scan completes. Not yet decided.

## Open questions

- Content selection: one shared `OverlayDialog` host with swapped content, or
  one `OverlayDialog` per toggle. Undecided.
- Interaction: keep icon-vs-body region split, or move to left-click toggle /
  right-click overlay (matches upstream android panel, drops the duplicated
  icon geometry). See `docs/quick-toggle-overlays.md`.
- Escape precedence: panel has its own Escape shortcut; dialog Escape may close
  the whole panel. Needs the dialog to take precedence when open.

## References

- `docs/quick-toggle-overlays.md` — component + interaction model.
- `docs/migration/diff.md:44-58` — upstream dialog inventory, gamma/brightness,
  mic volume.
- `docs/research/upstream-bottom-tools.md` — upstream widget-porting approach.
- Upstream base: `modules/common/widgets/WindowDialog.qml`.
- Quickshell.Networking v0.3.0 API:
  - [Networking](https://quickshell.org/docs/v0.3.0/types/Quickshell.Networking/Networking/)
  - [NetworkDevice](https://quickshell.org/docs/v0.3.0/types/Quickshell.Networking/NetworkDevice/)
  - [WifiDevice](https://quickshell.org/docs/v0.3.0/types/Quickshell.Networking/WifiDevice/)
  - [WifiNetwork](https://quickshell.org/docs/v0.3.0/types/Quickshell.Networking/WifiNetwork/)
  - [Network](https://quickshell.org/docs/v0.3.0/types/Quickshell.Networking/Network/)
  - [WiredDevice](https://quickshell.org/docs/v0.3.0/types/Quickshell.Networking/WiredDevice/)
  - [WifiSecurityType](https://quickshell.org/docs/v0.3.0/types/Quickshell.Networking/WifiSecurityType/)
  - [ConnectionState](https://quickshell.org/docs/v0.3.0/types/Quickshell.Networking/ConnectionState/)
