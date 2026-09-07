Now I have read every relevant file in both roots. Here is the corrected overview.

## Bar

**Your bar** (`/etc/nixos/.../v2/Modules/PrimaryBar.qml`):
- Left: `Mode` (hidden when no submap), `ActiveWindow` (app icon + title capped at 30 chars)
- Center: `SystemMedia` (RAM + CPU circular meters + separator + inline media; left-click = toggle playing, right-click = next), `Workspaces` (per-monitor dots with app icons, click to activate), `Clock` (time + short date, **display only, no popup, no interaction**), `Battery` (canvas fill bar, bolt icon while charging)
- Right: `StatusPill` (volume muted, mic active/muted, keyboard layout, DND, network icon, bluetooth icon; left-click = toggle panel, scroll = volume)

**Upstream ii bar** (`BarContent.qml`):
- Left: scroll zone (scroll = brightness, hover = scroll hint tooltip), `LeftSidebarButton` (distro icon, toggles left sidebar, ping dot when AI finishes while closed), `ActiveWindow`
- Center left: `Resources` (RAM always; swap auto-hides while media title present; CPU auto-hides while media title present; **hover opens ResourcesPopup** with RAM/swap/CPU used/free/total detail) + `Media` (circular progress ring + title•artist; left-click = toggle floating MediaControls; middle = play/pause; back/forward = prev/next)
- Center middle: `Workspaces` (right-click = toggle overview)
- Center right: `ClockWidget` (time + optional date; **hover/click opens ClockWidgetPopup** showing full date, uptime, and first five pending Todos) + `UtilButtons` (config-controlled circle buttons: screen-snip, screen-record, color picker, keyboard toggle, mic mute, dark-mode, power-profile cycle) + `BatteryIndicator` (**hover opens BatteryPopup**)
- Right: scroll zone (scroll = volume, hover = scroll hint tooltip), `SysTray`, right sidebar pill (volume muted, mic muted, HyprlandXkbIndicator, **notification unread count badge**, network, bluetooth), optional `WeatherBar`

**What your bar is missing:**

1. `Clock` — no popup; upstream's opens a tooltip on hover with full date, uptime, and pending Todos
2. `Resources` — yours always shows both meters; upstream's swap and CPU auto-hide while media is playing, ResourcesPopup on hover
3. `LeftSidebarButton` — no equivalent, no left sidebar exists
4. Left scroll zone → brightness control + hover hint
5. Right scroll zone → volume control + hover hint
6. `UtilButtons` — screen-snip, screen-record, color picker, keyboard toggle, mic mute, dark-mode toggle, power-profile cycle
7. `BatteryIndicator` hover popup with detail
8. `SysTray`
9. `WeatherBar`
10. Notification unread count badge in status pill (yours shows DND icon only)

---

## Panel

**Your panel** (`StatusPanelContent.qml`):
- Header: `Uptime` (clock icon + "Up Xh Ym") + `PowerOptions` (lock/restart/poweroff with confirm step)
- `QuickSliders`: brightness + volume
- `QuickToggleGrid`: WifiToggle (2-cell), EthernetToggle (2-cell, hidden when no wired device), BluetoothToggle (2-cell), AudioToggle (2-cell), IdleInhibitToggle (1-cell), MicrophoneToggle (1-cell)
- `NotificationList` with `NotificationFooter` (DND toggle, count text, dismiss-all)
- `WidgetGroup`: Calendar / Timer / Media; nav rail; collapsible; compact summary shows date + playing track + next countdown timer

**Upstream ii sidebar right** (`SidebarRightContent.qml`):
- Header: uptime pill (distro icon + "Up Xd Yh") + button group: edit-mode toggle (android only), reload Hyprland+Quickshell, open settings app, session/power
- `QuickSliders`: brightness **unified with gamma** (0–0.3 = hyprsunset gamma, 0.3–1.0 = real brightness, secondary icon at the 0.3 split) + volume + **mic volume** — each independently config-toggled
- Classic panel: NetworkToggle (wifi; alt opens WifiDialog), BluetoothToggle (alt opens BluetoothDialog), NightLight (alt opens NightLightDialog), GameMode, IdleInhibitor, EasyEffects, CloudflareWarp
- Android panel: full set — all classic toggles plus AntiFlashbang, Audio, Mic, DarkMode, ColorPicker, MusicRecognition, OnScreenKeyboard, PowerProfile, ScreenSnip, NotificationToggle; supports **edit mode** (LMB enable/disable, RMB/hold toggle 1→2 cell width, scroll to reorder)
- Overlay sub-dialogs: WifiDialog, BluetoothDialog (with device discovery), NightLightDialog (temperature), VolumeDialog output (per-app mixer), VolumeDialog input
- `CenterWidgetGroup`: notification list (no footer — notification controls are elsewhere)
- `BottomWidgetGroup`: Calendar / **Todo** / PomodoroWidget; nav rail; collapsible; compact summary shows **date + pending task count**

**What your panel is missing:**

1. Header buttons — reload Hyprland+Quickshell, open settings, edit-mode toggle
2. Brightness slider unified with gamma/hyprsunset
3. Mic volume slider
4. Classic panel style
5. Android panel edit mode (enable/disable, resize, reorder)
6. Toggles: NightLight, GameMode, CloudflareWarp, EasyEffects, AntiFlashbang, DarkMode, ColorPicker, MusicRecognition, OnScreenKeyboard, PowerProfile, ScreenSnip, NotificationToggle
7. All toggle sub-dialogs: WifiDialog, BluetoothDialog, NightLightDialog, VolumeDialog ×2
8. **Todo** widget tab
9. Collapsed summary shows media + timer (yours) vs date + task count (upstream)
10. Upstream has no Media tab in the sidebar — that lives in the floating MediaControls panel instead

---

## Outside bar and panel

Your shell loads: `NotificationPopupHost`, `StatusPanel`, `PanelWindow` bar per screen.

Upstream `IllogicalImpulseFamily` additionally loads:

| Module | What it does |
|---|---|
| `Background` | Wallpaper rendering with desktop clock and weather widgets |
| `Cheatsheet` | Keybind cheatsheet overlay + periodic table |
| `Dock` | Optional pinned + running-app dock |
| `Lock` | Lock screen with PAM authentication |
| `MediaControls` | Floating per-player panel: album art, title, transport, seek, cava visualizer; duplicate deduplication; positioned left of bar center |
| `OnScreenDisplay` | OSD for volume, brightness, and gamma; auto-hides on timeout; dismisses on hover; red protection message on audio clipping |
| `OnScreenKeyboard` | Virtual keyboard |
| `Overlay` | Full-screen overlay with pinnable widgets (crosshair, notes, FPS limiter, recorder, resource monitor, volume mixer), optional screen dim, zoom-in open animation |
| `Overview` | Workspace thumbnail overview + unified search bar (apps, clipboard, emojis, web via prefixes) |
| `Polkit` | Polkit authentication agent dialog |
| `RegionSelector` | Screen region selection for screenshots |
| `ScreenCorners` | Decorative rounded screen corners |
| `ScreenTranslator` | OCR screen region then translate it in a side panel |
| `SessionScreen` | Power/session screen: shutdown, reboot, logout, suspend, lock |
| `SidebarLeft` | Left sidebar with AI chat (Gemini/Mistral/OpenAI/Ollama, multi-turn), Translator, Anime/Booru browser |
| `VerticalBar` | Alternative vertical bar mode, mutually exclusive with horizontal bar |
| `WallpaperSelector` | Wallpaper browser with thumbnail generation and apply |
| `settings.qml` | Separate Quickshell process: full settings UI launched from sidebar |
| `killDialog.qml` | Process kill dialog |
| `ReloadPopup` | Config hot-reload status indicator |
