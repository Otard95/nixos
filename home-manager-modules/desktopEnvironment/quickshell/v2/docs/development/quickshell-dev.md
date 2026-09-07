# Quickshell development service

Use `scripts/quickshell-dev` to run this source tree as a background user service.
The service runs `/etc/nixos/home-manager-modules/desktopEnvironment/quickshell/v2` directly.
It does not use the Home Manager store copy at `~/.config/quickshell/default`.

## Commands

Start the development service:

```bash
scripts/quickshell-dev start
```

This command stops `quickshell.service` before it starts `quickshell-dev.service`.
Quickshell reloads QML source files after you save them.

Restart the development service:

```bash
scripts/quickshell-dev restart
```

Read recent logs:

```bash
scripts/quickshell-dev logs
```

Follow logs live:

```bash
scripts/quickshell-dev logs -f
```

Show both service states:

```bash
scripts/quickshell-dev status
```

Stop development and restore the managed service:

```bash
scripts/quickshell-dev stop
```

## Service details

The wrapper starts a transient user unit named `quickshell-dev.service`.
Systemd stores its output in the user journal.

The wrapper reads `QS_NOTIFICATION_BACKEND` from `quickshell.service`.
It uses `native` if the managed service does not set that value.

Do not run both services at the same time.
They can create duplicate panels, notification daemons, and D-Bus conflicts.
