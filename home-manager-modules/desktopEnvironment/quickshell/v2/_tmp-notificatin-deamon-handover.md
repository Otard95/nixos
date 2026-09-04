## Handover

The notification-center UI and typed Mako backend are complete. The next phase is implementing a Quickshell-owned notification daemon and popup host.

Start with:

- [`notification-deamon-plan.md`](notification-deamon-plan.md) — authoritative implementation plan, decisions, risks, sequence, and test matrix.
- [`docs/notifications.md`](docs/notifications.md) — current architecture and completed behavior.
- [`upstream-notifications.md`](upstream-notifications.md) — upstream comparison and source locations.
- [`Sources/DocumentDb/README.md`](Sources/DocumentDb/README.md) — persistence infrastructure.
- [`docs/timers.md`](docs/timers.md) — timer notification coupling.

Key requirements:

- Preserve the `NotificationBackend → Notifications facade → UI` boundary.
- Set `notification.tracked = true` first in every native notification handler.
- Conditionally construct Mako, fixture, or native backends; do not instantiate `NotificationServer` in Mako mode.
- Handle replacements in place without changing unread state or re-showing expired popups.
- Reconcile hot reloads using daemon-session ID plus protocol ID; finalize the `PersistentProperties` mechanism during implementation.
- Keep live and restored dismissal/action behavior distinct.
- Use the documented YOLO markup policy initially.
- Do not disable Mako until the native backend, popup host, persistence, and handover tests pass.
