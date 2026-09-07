Cloned successfully to:

```text
/home/otard/.config/quickshell/dots-hyprland
```

Latest checked-out commit:

```text
97c5bc65 gentoo rework (#3625)
```

## What Quickshell contains

The actual shell is:

```text
dots/.config/quickshell/ii/
```

It has two visual “panel families”:

- `modules/ii/` — the primary Material-style shell
- `modules/waffle/` — Windows-inspired alternative style

Both share:

- `modules/common/` — widgets, styling, configuration, utility functions
- `services/` — audio, network, battery, notifications, wallpapers, Hyprland integration, etc.
- `scripts/` — wallpaper theming, screenshots, recording, OCR, translation, AI, thumbnails
- `settings.qml`
- `shell.qml`
- `translations/`

The shell is fairly large: roughly 5.9 MB of Quickshell/QML code.

## Main visible components

The primary `ii` shell includes:

- Top bar
- Workspaces and active-window display
- System tray
- Audio, brightness, battery and resource indicators
- Clock and calendar
- Media controls
- Notification popups and notification sidebar
- Left sidebar:
  - Search
  - AI chat
  - Translator
  - Anime/image search
- Right sidebar:
  - Network/Wi-Fi
  - Bluetooth
  - Quick toggles
  - Volume mixer
  - Notifications
  - Todo list
  - Pomodoro timer
- Application overview with window previews
- Clipboard history
- Emoji picker
- On-screen keyboard
- Wallpaper selector
- Dynamic wallpaper-based theming
- Screen snipping, OCR, translation and recording
- Lock screen and session/logout screen
- Settings UI
- Optional desktop widgets and visual overlays
- “Waffle” alternative panel family

## Minimum requirements

For the basic shell:

- Hyprland/Wayland
- Quickshell, specifically their pinned build
- Qt6 components:
  - Qt Quick
  - Qt Quick Controls
  - Qt Wayland
  - Qt SVG
  - Qt Multimedia
  - Qt Positioning
  - Qt Virtual Keyboard
  - Qt 5 compatibility
  - Kirigami
  - KDialog
- PipeWire/WirePlumber
- A notification-capable desktop session
- Material Symbols and the included fonts

The repository packages these as `illogical-impulse-quickshell-git`, which includes the pinned Quickshell commit and additional Qt dependencies.

## Optional feature dependencies

| Feature | External requirements |
|---|---|
| Audio controls | PipeWire, WirePlumber, `pavucontrol`, optionally `cava`, `playerctl` |
| Brightness | `brightnessctl`; `ddcutil` for external monitors |
| Network | NetworkManager / `nmcli` |
| Bluetooth | BlueZ plus KDE Bluetooth tools (`bluedevil`, `kcmshell6`) |
| Clipboard | `cliphist`, `wl-clipboard` |
| Wallpaper theming | `matugen`, ImageMagick, Python virtual environment |
| Wallpaper color analysis | Python, NumPy, Pillow, OpenCV |
| Screenshots | `grim`, `slurp`, `swappy`, `hyprpicker` |
| OCR | `tesseract` and English language data |
| Screen recording | `wf-recorder` |
| Screen translation | `translate-shell`, or configured Google/Gemini services |
| Music recognition | `songrec` |
| On-screen keyboard/paste automation | `ydotool`, appropriate permissions/service |
| Search calculator | `qalc` from `libqalculate` |
| Weather | `curl`, `jq`; optionally GeoClue |
| LaTeX in AI/search results | MicroTeX |
| AI features | API keys and/or Ollama; Google authentication may use the Python environment |
| File manager/settings buttons | Dolphin/KDE tools, though fallback applications are supported |

Most of these are only needed when using the corresponding widget.

## What outside Quickshell is actually important

The installer copies many unrelated dotfiles, but the Quickshell-specific dependencies are mostly:

```text
dots/.config/quickshell/ii/
dots/.config/hypr/hyprland/
dots/.config/hypr/hyprland.lua
dots/.config/matugen/
dots/.config/kde-material-you-colors/
dots/.config/fuzzel/
dots/.config/fontconfig/
```

The Hyprland configuration provides:

- Startup command: `qs -c ii`
- Keybindings that call Quickshell IPC
- Layer rules for animations, blur and panel behavior
- `qsConfig=ii`
- `ILLOGICAL_IMPULSE_VIRTUAL_ENV`

You can launch the shell manually with:

```bash
qs -c ii
```

The other shell, terminal, Fish/Zsh, Kitty, Foot, Wlogout, KDE and general application configs are not fundamentally required by Quickshell itself. They mainly provide integration, matching appearance, default applications and keybindings.

## Important generated state

The shell expects to create/use:

```text
~/.config/illogical-impulse/config.json
~/.local/state/quickshell/
~/.cache/quickshell/
```

The first-run flow generates the configuration and asks for a wallpaper. Without the repository’s installer, these directories/configuration may need to be created manually.

## Bottom line

You do **not** need the entire dots repository to use the shell. The practical starting point is:

1. Quickshell and its Qt dependencies
2. `dots/.config/quickshell/ii`
3. A small Hyprland configuration providing startup, environment and keybindings
4. Only the external tools for features you actually want

The biggest “optional bulk” is the AI, image-analysis, wallpaper-theming, OCR, translation, Waffle, and advanced media functionality.
