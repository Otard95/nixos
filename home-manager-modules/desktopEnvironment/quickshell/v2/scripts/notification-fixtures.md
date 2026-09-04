# Notification fixture sender

`notification-fixtures` sends repeatable Freedesktop notifications to the active
notification daemon. It is intended for exercising the Quickshell notification
adapter and UI while Mako remains the daemon.

## Usage

```bash
scripts/notification-fixtures [options]
```

```bash
# Send the first built-in fixture.
scripts/notification-fixtures

# Send eight built-in fixtures in sequence, one every two seconds.
scripts/notification-fixtures --count 8 --interval 2s

# Send twenty random fixtures, waiting a random 500ms–3s between each one.
scripts/notification-fixtures --count 20 --order random --interval 500ms-3s

# Cycle both the delay and expiry values.
scripts/notification-fixtures --count 12 --interval 500ms,2s,5s --expire 3s,8s,15s

# Use custom fixtures from a file or standard input.
scripts/notification-fixtures --file ./fixtures.json --count 10 --order random
jq '.' ./fixtures.json | scripts/notification-fixtures --file - --count 10

# Repeat a random run deterministically.
scripts/notification-fixtures --count 10 --order random --seed 42

# Run the ordered grouping/reordering regression sequence.
scripts/notification-fixtures --file scripts/notification-grouping-sequence.json --count 6 --interval 4s
```

## Options

| Option | Description |
| --- | --- |
| `--count N` | Number of notifications to send. Default: `1`. |
| `--interval SPEC` | Delay between sends. Default: `0`. |
| `--expire SPEC` | Lifetime passed to `notify-send -t`. Default: `0`, which does not expire. |
| `--order sequential\|random` | Fixture selection order. Default: `sequential`. |
| `--file PATH\|-` | JSON fixture source. Defaults to `notification-fixtures.json`; `-` reads standard input. |
| `--seed N` | Seed for reproducible random fixture and duration selection. |

A duration specification accepts:

- A fixed duration: `500ms`, `2s`, `1m`.
- A per-notification random range: `500ms-3s`.
- A cycling list: `500ms,2s,5s`.

Bare numbers are seconds. Units are `ms`, `s`, and `m`.

## Fixtures

A fixture source is a non-empty JSON array. Required fields are `appName` and
`summary`; all other fields are optional.

```json
[
  {
    "appName": "Zen",
    "icon": "zen",
    "desktopEntry": "zen",
    "category": "im.received",
    "summary": "Pull request review requested",
    "body": "schibsted-smb/graphql-monorepo",
    "urgency": "normal",
    "actions": [
      { "id": "default", "label": "Activate" }
    ]
  }
]
```

| Field | Meaning |
| --- | --- |
| `appName` | Sender/application name passed as `notify-send --app-name`. |
| `icon` | Icon name or file path passed as `notify-send --icon`. |
| `desktopEntry` | Desktop entry hint, used to test facade icon fallback and grouping. |
| `category` | Freedesktop notification category. |
| `summary` | Notification title. |
| `body` | Notification body; rich text is supported by the sender protocol. |
| `urgency` | `low`, `normal`, or `critical`. Defaults to `normal`. |
| `actions` | Array of `{ "id", "label" }` action definitions. |

The bundled fixtures cover grouping, urgency, long content, rich text,
desktop-entry icon fallback, a default Activate action, and multiple explicit
actions.

`notification-grouping-sequence.json` is an ordered regression scenario:

1. Build Service appears.
2. Calendar appears.
3. Build Service receives a newer entry, moves to the top, and its count becomes 2.
4. Calendar receives a newer entry, moves to the top, and its count becomes 2.
5. Build Service receives a critical entry, moves to the top, and its newest item is first.
6. System Monitor appears as a third group.

Use a 4–5 second interval to inspect each state before the next update.

## Architecture

The script intentionally stays outside the Quickshell notification interface:

```text
fixture JSON → notification-fixtures → notify-send → Mako → MakoStrategy → Notifications facade → UI
```

It tests the same external sender path as normal applications. It does not
inject records into `MakoStrategy`; `debugTimeFixtures` remains the dedicated,
typed in-process mechanism for deterministic time-label tests.

Action-bearing `notify-send` invocations must remain alive for the daemon to
invoke their actions. The script launches those senders in the background, then
waits after all fixtures have been sent. It prints an action identifier when one
is selected. Press `Ctrl-C` to stop waiting and terminate active fixture
senders.
