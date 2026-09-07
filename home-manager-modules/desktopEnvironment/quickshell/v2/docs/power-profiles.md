# Power profiles

`PowerProfileSource` gives the shell access to the Power Profiles D-Bus API.

## System requirement

The source checks this D-Bus service:

```text
org.freedesktop.UPower.PowerProfiles
```

A system must run a service that implements this API. `power-profiles-daemon` is one provider.

```nix
services.power-profiles-daemon.enable = true;
```

The feature does not require the main UPower daemon.

## Source API

`PowerProfileSource` is a singleton from `Sources/PowerProfile.qml`.

| Property or function | Description |
|---|---|
| `available` | True after a D-Bus probe succeeds. False before this result and after all failed probes. |
| `profile` | The current `PowerProfiles.profile` value. The value is `PowerProfile.Balanced` until the source is available. |
| `hasPerformance` | True when the provider exposes the Performance profile. |
| `cycle()` | Selects the next supported profile. |

The panel hides `PowerProfileToggle` until `available` is true.

## Probe behavior

The source runs `busctl --system get-property` on `ActiveProfile`.

The source makes six attempts. It makes the first attempt at startup. Failed attempts wait for 1, 2, 4, 8, and 16 seconds. The source stops after the sixth failure.

The source does not create Quickshell's `PowerProfiles` singleton before a probe succeeds. This prevents Quickshell from logging a missing Power Profiles service on unsupported systems.

Restart Quickshell to probe again after the retry limit.

## Profile cycle

The cycle order is:

```text
Power saver -> Balanced -> Performance -> Power saver
```

The source omits Performance when `hasPerformance` is false. The cycle starts from the active profile that the provider reports.

A profile selection is a manual user selection. It clears active application profile holds, as defined by the Power Profiles API.

## Test record

On `deimos`, 2026-09-07:

- `power-profiles-daemon.service` was active.
- `ActiveProfile` was `balanced`.
- The provider exposed Power Saver, Balanced, and Performance.
- The provider reported no active profile holds.
- The Quickshell log showed no PowerProfile source or toggle errors.
