I found the following development/debugging material:

### Active development aids in `default/`

- `Modules/StatusPanel/StatusPanel.qml:10`
  - `property bool open: false`
  - The panel now starts closed. `progress.md` retains that it was temporarily forced open for active layout development.

- `Sources/Notifications/MakoStrategy.qml:8`
  - `debugTimeFixtures: false`
  - Lines 64–98 generate fake notifications for testing time labels (`Now`, minutes, hours, yesterday, older dates, previous year).
  - Safe when disabled, but clearly development-only code.

- Notification fixture tooling:
  - `scripts/notification-fixtures`
  - `scripts/notification-fixtures.json`
  - `scripts/notification-grouping-sequence.json`
  - `scripts/notification-fixtures.md`
  - These are deliberate test tools for notification grouping, ordering, expiry, actions, and deterministic runs.

### Development documentation

- `progress.md`
  - Active handoff/development notes.
  - Contains workflow rules, known pitfalls, implementation inventory, and unfinished work.

- `upstream-notifications.md`
- `upstream-bottom-tools.md`
- `upstream-media-controls.md`
  - Detailed implementation studies and porting notes.
  - These are development/reference documents, not runtime documentation.

- `docs/notifications.md`
- `docs/timers.md`
- `docs/slider.md`
- `Sources/DocumentDb/README.md`
  - These appear to be maintained implementation documentation rather than temporary notes.

- `end_4-quickshell.md`
- `end_4-changes-peliminary.md`
  - Older planning/inventory notes. They may now be partially stale.

### Upstream reference tree

The separate `dots-hyprland` checkout contains substantially more debugging output, including:

- `modules/waffle/lock/WaffleLock.qml:43-44`
  - Unconditional wallpaper/debug prints.
- `modules/ii/sidebarRight/volumeMixer/VolumeDialogContent.qml:55`
  - Stray `print(index)`.
- `modules/common/models/LauncherSearchResult.qml:18`
  - `print("Not implemented")`.
- `services/MprisController.qml:158`
  - Logs active-player changes.
- `welcome.qml:50,291`
  - Logs wallpaper process output/commands.
- Various AI, notification, wallpaper, translation, and service logging.

That tree is documented as an untouched upstream reference, so I would not clean it unless you intend to maintain the upstream copy too.

### No obvious stray debug output in the active local config

The local `default` tree has no active `console.log()` or `print()` calls apart from legitimate `console.warn()` diagnostics for persistence and parsing failures.
