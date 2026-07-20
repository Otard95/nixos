# Monitor Management — `monitors.lua`

Native Hyprland Lua monitor management, replacing kanshi.

## Overview

`monitors.lua` detects which monitors are connected and applies the
appropriate profile (docked with external displays, or undocked with
mirroring). It handles workspace assignment across monitors.

`utils/debounce-queue.lua` provides a generic debounce primitive using
`hl.timer()` to collapse rapid events into a single delayed action.

## Hardware

- **Laptop**: Lenovo ThinkPad with AMD Phoenix1 APU (amdgpu, DCN 3.x)
- **Built-in display**: `eDP-1` (1920×1200)
- **HDMI monitor**: `HDMI-A-1` — Lenovo P27q-10 (2560×1440), connected
  directly via the laptop's HDMI port
- **Dock monitors**: Two Lenovo P27h-10 (2560×1440) connected via USB-C
  through a dock with a DisplayPort MST hub. The MST hub means the DP
  port names can vary between docking sessions:
  - Dock slot 1: `DP-7` + `DP-9`
  - Dock slot 2: `DP-8` + `DP-11`

## Profiles

| Profile    | Condition                          | eDP-1    | HDMI-A-1         | DP monitors                        |
|------------|------------------------------------|----------|------------------|------------------------------------|
| docked-1   | HDMI-A-1 + DP-7 + DP-9            | disabled | 2560×1440 @ 0x485 | DP-7 @ 4000x0 (270°), DP-9 @ 2560x0 (90°) |
| docked-2   | HDMI-A-1 + DP-11 + DP-8           | disabled | 2560×1440 @ 0x485 | DP-8 @ 4000x0 (270°), DP-11 @ 2560x0 (90°) |
| else       | anything else                      | enabled  | mirror eDP-1     | mirror eDP-1                       |

## Key Design Decisions

### Enable before disable

When switching to a docked profile, external monitors are configured
*before* disabling eDP-1. This ensures there is always at least one
active output during the transition, preventing Wayland clients from
losing their surfaces and crashing.

### Not listening to `monitor.layout_changed`

Each `hl.monitor()` call internally replaces the monitor rule via
`MonitorRuleManager::add()`, which calls `scheduleReload()`. On the next
render frame `ensureMonitorStatus()` runs, and if any monitor's rule
differs from its active state it emits `monitor.layout_changed`.

In practice the comparison never returns `FULL_MATCH` for our rules,
so every `hl.monitor()` call re-emits the event. Listening to
`layout_changed` therefore creates an infinite loop where `apply()` →
`hl.monitor()` → `layout_changed` → `apply()` repeats every 1500ms
(the debounce interval).

The events we do listen to (`monitor.added`, `monitor.removed`,
`hyprland.start`, `config.reloaded`) are sufficient to detect all real
hardware changes.

### Debounce timing (1500ms)

The USB-C dock uses DisplayPort MST, and the MST hub takes time to
enumerate its ports after connection. A 1500ms debounce gives the hub
enough time to bring up both DP monitors before `apply()` checks the
docked condition. Without this delay, `apply()` might fire with only
one DP monitor visible and fall through to the else branch.

### Mirrored monitor tracking

`hl.get_monitors()` does not return mirrored or disabled monitors
(confirmed in Hyprland source; PR #14693 adds `{ all = true }` but is
not yet merged as of v0.55.4). When the else branch mirrors a monitor,
we track it in a local `mirrored` table. `get_monitor_names()` merges
both `hl.get_monitors()` and `mirrored` so that docked conditions can
still match when some monitors are mirrored. The `mirrored` table is
cleared when a docked profile is applied.

### Mirror clearing

`hl.monitor()` fully *replaces* the rule for a given output name (via
`MonitorRuleManager::add()` which erases the old rule before inserting).
A new rule created without a `mirror` field has `mirrorOf = ""` by
default in the C++ struct, which means "not mirrored". So calling
`hl.monitor({ output = "HDMI-A-1", mode = "...", position = "..." })`
in the docked branch implicitly clears any mirror that was set by the
else branch — no need for an explicit `mirror = ""` or similar.

### eDP-1 bounce on config reload

After `hyprctl reload`, Hyprland re-creates the Lua state and
re-evaluates the config. The catch-all `hl.monitor()` rule in
`extraConfig` briefly enables eDP-1 before `apply()` runs and disables
it again. This causes a 2-cycle bounce:
1. `config.reloaded` + `monitor.added` (eDP-1) → `apply()` disables
   eDP-1 → `monitor.removed`
2. `monitor.removed` → `apply()` runs again, now stable

This is harmless and converges immediately.

## Known Issues / AMD GPU Bugs

### DMUB firmware crash (PSR)

AMD Phoenix1 APUs have a known bug where the DMUB (Display
Microcontroller Unit B) firmware crashes when the eDP panel's PSR
(Panel Self Refresh) state machine conflicts with display pipeline
changes during docking/undocking transitions. Symptoms:

- `[drm] *ERROR* Error queueing DMUB command: status=2`
- `[drm] *ERROR* [CRTC:80:crtc-0] flip_done timed out`
- Complete system freeze (no TTY switching possible)

**Workaround**: Add `amdgpu.dcdebugmask=0x10` to kernel parameters.
This disables PSR, preventing the DMUB from entering its error state
during eDP-1 transitions. This is a widespread issue on kernel 6.18.x
with AMD 7040 series (Phoenix) hardware.

### Aquamarine startup race

At boot, aquamarine tries to modeset all detected outputs concurrently
with `ATOMIC_NONBLOCK` commits. This causes `"Device or resource busy"`
and `"Cannot commit when a page-flip is awaiting"` errors in the
Hyprland log. Usually transient, but occasionally a monitor gets stuck
at `0x0@60Hz` resolution when its modeset permanently fails. This
affects any output (HDMI-A-1, DP-7, etc.) and cannot be fixed by
`hyprctl reload` or re-applying monitor rules — the DRM CRTC state is
corrupted. The only recovery is restarting the Hyprland session
(`uwsm stop && uwsm start hyprland` from a TTY).

The PSR workaround (`amdgpu.dcdebugmask=0x10`) reduces the frequency
of this issue but does not eliminate it entirely.

Upstream issues:
- [#14522](https://github.com/hyprwm/Hyprland/discussions/14522) —
  eDP-1 stuck disabled after dock disconnect (exact match)
- [#13224](https://github.com/hyprwm/Hyprland/discussions/13224) —
  HDMI stuck in page-flip loop after hotplug
- [#14547](https://github.com/hyprwm/Hyprland/pull/14547) — merged
  refactor of monitor state/fallback (in 0.55.4, partial fix)
- The full fix for the page-flip race is expected in Hyprland 0.56.

### Wayland client crashes on USB-C disconnect

When the USB-C dock is physically disconnected, the DP monitors vanish
abruptly. Wayland clients that were bound to those outputs' `wl_output`
objects may receive protocol errors and crash. This affects Electron
apps (Slack, etc.), XWayland, hyprpaper, and various session services.
The enable-before-disable ordering mitigates this for planned
transitions, but a physical unplug is inherently abrupt.

Session services that crash (hyprpaper, xdg-desktop-portal-hyprland,
quickshell, etc.) may need manual restart after a USB-C hot-unplug.

### `hl.get_monitors()` limitations

- Does not return disabled monitors
- Does not return mirrored monitors
- Returns `FALLBACK` pseudo-monitor when all real outputs are gone
  (e.g. during suspend). This must be filtered out.
- PR #14693 adds `hl.get_monitors({ all = true })` but is not merged
  as of Hyprland v0.55.4

### HDMI-A-1 disappearing after full dock replug

After a full dock unplug/replug cycle, HDMI-A-1 sometimes reconnects
in a broken state where Hyprland doesn't report it via
`hl.get_monitors()` even though it's physically connected. The DP
monitors (which go through MST) appear fine.

When `apply()` detects dock DP ports without HDMI-A-1, it triggers
`hyprctl reload` which forces Hyprland to re-evaluate all connectors
and recover HDMI-A-1. This is a workaround for an aquamarine bug.

### FALLBACK monitor

When all real monitors disconnect (suspend, full dock unplug), Hyprland
creates an internal `FALLBACK` monitor. `get_monitor_names()` filters
it out so it doesn't pollute profile detection or get mirrored.

## Debugging

Monitor events and profile switches are logged to the system journal:

```bash
journalctl -b -t monitors.lua
```

Each `apply()` call logs which branch was taken and what monitors were
visible. Each event that triggers the debounce queue is also logged.

To check the current kernel-level DRM state:

```bash
nix-shell -p drm_info --run "drm_info /dev/dri/card2"
```

To check for AMD GPU errors:

```bash
journalctl -b -k -p err | grep -i "amdgpu\|drm\|dmub\|flip\|crtc"
```
