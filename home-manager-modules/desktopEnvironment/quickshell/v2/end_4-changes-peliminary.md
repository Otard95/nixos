I traced the dependency structure. For your reduced version, I would keep the **`ii` family only** and remove the Waffle family plus the explicitly unwanted features.

## Keep

```text
dots/.config/quickshell/ii/
├── shell.qml
├── GlobalStates.qml
├── settings.qml
├── modules/common/
├── modules/ii/bar/
├── modules/ii/background/        # only if you still want its desktop background
├── modules/ii/cheatsheet/
├── modules/ii/dock/
├── modules/ii/lock/
├── modules/ii/mediaControls/
├── modules/ii/notificationPopup/
├── modules/ii/onScreenDisplay/
├── modules/ii/overview/          # optional; remove if you do not want app overview
├── modules/ii/polkit/
├── modules/ii/screenCorners/
├── modules/ii/sessionScreen/
├── modules/ii/sidebarRight/
├── modules/ii/sidebarLeft/       # only if you want its remaining features
├── services/                     # prune unused services
└── translations/
```

The most important shared code is:

```text
modules/common/
services/
shell.qml
GlobalStates.qml
```

`modules/common` contains the theme, configuration, reusable widgets and utility functions used almost everywhere.

## Remove completely

### Waffle

Remove:

```text
modules/waffle/
panelFamilies/WaffleFamily.qml
```

Then simplify `shell.qml`:

- Remove the Waffle import
- Remove `"waffle"` from `families`
- Remove the Waffle `PanelFamilyLoader`

### Wallpaper interaction and theming

Remove:

```text
modules/ii/wallpaperSelector/
scripts/colors/
services/Wallpapers.qml
services/MaterialThemeLoader.qml
modules/ii/background/        # if you do not want wallpaper rendering at all
```

However, wallpaper theming is coupled to `Appearance.qml`. If you keep the existing Material appearance, it expects generated wallpaper-derived colors. For a clean wallpaper-free version, `Appearance.qml` should be changed to use a fixed color scheme instead of:

```text
~/.local/state/quickshell/user/generated/colors.json
```

You can also remove:

```text
dots/.config/matugen/
dots/.config/kde-material-you-colors/
```

## Remove the requested features

| Feature | Files/directories |
|---|---|
| OCR | `modules/ii/regionSelector/` OCR paths, `scripts/images/`, OCR keybindings |
| Screen recording | `modules/ii/overlay/recorder/`, `scripts/videos/` |
| Screen translation | `modules/ii/screenTranslator/`, `scripts/ai/gemini-translate.sh` |
| On-screen keyboard | `modules/ii/onScreenKeyboard/`, `services/Ydotool.qml` |
| Search calculator | Remove the `qalc` branch from `modules/ii/overview/` search handling |
| Weather | `services/Weather.qml`, `modules/ii/bar/weather/`, weather sidebar widgets |
| AI | `services/Ai.qml`, `services/ai/`, `modules/ii/sidebarLeft/aiChat/`, `scripts/ai/`, Google Cloud files |
| File manager | No major QML component; remove Dolphin-related launch actions from Hyprland variables/settings |

The region selector may still be useful for ordinary screenshots, but the OCR, Lens/search and recording integrations should be removed from it.

## Services probably still needed

For a normal bar/sidebar:

```text
services/Audio.qml
services/Battery.qml
services/BluetoothStatus.qml
services/Brightness.qml
services/Cliphist.qml
services/DateTime.qml
services/HyprlandData.qml
services/HyprlandXkb.qml
services/MprisController.qml
services/Network.qml
services/Notifications.qml
services/PolkitService.qml
services/ResourceUsage.qml
services/TrayService.qml
services/Updates.qml
```

Potentially also:

```text
services/Idle.qml
services/Hyprsunset.qml
services/Privacy.qml
services/Todo.qml
services/TimerService.qml
```

Keep those only if you want lock/idle behavior, night light, privacy indicators, todo lists or Pomodoro.

Remove:

```text
services/Ai.qml
services/ai/
services/Booru.qml
services/GoogleCloud.qml
services/Weather.qml
services/SongRec.qml
services/Translation.qml
services/Ydotool.qml
services/Wallpapers.qml
services/LatexRenderer.qml
services/KeyringStorage.qml   # if AI/keyring-backed settings are removed
```

`Booru.qml` is the anime/image search service and is only needed by the left sidebar anime feature.

## External packages needed afterward

Likely required:

- Quickshell with its Qt dependencies
- Hyprland
- PipeWire/WirePlumber
- `upower`
- `brightnessctl` if brightness controls remain
- NetworkManager/`nmcli` if network controls remain
- BlueZ if Bluetooth controls remain
- `cliphist` and `wl-clipboard` if clipboard history remains
- `playerctl` only for the supplied media keybindings
- `cava` only for audio visualizers
- `hypridle`/`hyprlock` for locking and idle handling
- `hyprpicker` only for the color-picker button
- Material Symbols and whichever fonts you retain

No longer needed:

```text
matugen
kde-material-you-colors
imagemagick
numpy
pillow
opencv
tesseract
wf-recorder
translate-shell
ydotool
qalc
songrec
MicroTeX
Dolphin
fuzzel              # unless retaining fallback launcher/search behavior
```

## Hyprland files to simplify

Will have to be handled entirely differently to fit into my nixos config.

## Practical recommendation

Do not delete individual shared widgets yet. First simplify:

1. `shell.qml`
2. `IllogicalImpulseFamily.qml`
3. `services/`
4. `modules/ii/sidebarLeft/`
5. `modules/ii/sidebarRight/`
6. `hyprland/keybinds.lua`

Then run Quickshell and remove unused files based on import/runtime errors. The QML code is highly interconnected, and many “feature” files use shared widgets and singleton services.
