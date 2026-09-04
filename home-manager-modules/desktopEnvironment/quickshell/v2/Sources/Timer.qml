pragma Singleton

import qs
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property int focusDuration: 25 * 60
    readonly property int shortBreakDuration: 5 * 60
    readonly property int longBreakDuration: 15 * 60
    readonly property int sessionsBeforeLongBreak: 4
    readonly property double initialTimestamp: Date.now()

    readonly property var state: timerStore.document
    readonly property int pomodoroPhase: state?.pomodoro.phase ?? 0
    readonly property int completedFocusSessions: state?.pomodoro.completedSessions ?? 0
    readonly property bool pomodoroRunning: state?.pomodoro.running ?? false
    readonly property double pomodoroEndMs: state?.pomodoro.deadlineAt ?? 0

    readonly property bool stopwatchRunning: state?.stopwatch.running ?? false
    readonly property double stopwatchStartedMs: state?.stopwatch.startedAt ?? initialTimestamp
    readonly property double stopwatchLastLapStartMs: state?.stopwatch.lastLapStart ?? initialTimestamp
    readonly property var stopwatchLaps: state?.stopwatch.laps ?? []

    readonly property var countdownTimers: state?.countdowns ?? []
    readonly property bool anyCountdownRunning: countdownTimers.some(timer => timer.state === "running")
    readonly property var nextCountdownTimer: countdownTimers.reduce((next, timer) => {
        if (timer.state !== "running")
            return next;
        return next === null || timer.deadlineAt < next.deadlineAt ? timer : next;
    }, null)

    property double nowMs: Date.now()
    property var notificationQueue: []
    property var countdownNotificationIds: ({})
    property int notifyingCountdownId: 0

    readonly property string pomodoroPhaseName: pomodoroPhase === 0 ? "Focus" : pomodoroPhase === 1 ? "Short break" : "Long break"
    readonly property int pomodoroPhaseDuration: durationForPhase(pomodoroPhase)
    readonly property int pomodoroRemaining: {
        const reference = pomodoroRunning ? nowMs : state?.pomodoro.pausedAt ?? nowMs;
        return Math.max(0, Math.ceil((pomodoroEndMs - reference) / 1000));
    }
    readonly property double stopwatchElapsedMs: {
        const reference = stopwatchRunning ? nowMs : state?.stopwatch.pausedAt ?? stopwatchStartedMs;
        return Math.max(0, reference - stopwatchStartedMs);
    }

    function durationForPhase(phase) {
        return phase === 0 ? focusDuration : phase === 1 ? shortBreakDuration : longBreakDuration;
    }

    function defaultDocument() {
        return {
            version: 2,
            nextCountdownId: 1,
            countdowns: [],
            pomodoro: {
                phase: 0,
                completedSessions: 0,
                running: false,
                deadlineAt: initialTimestamp + focusDuration * 1000,
                pausedAt: initialTimestamp
            },
            stopwatch: {
                running: false,
                startedAt: initialTimestamp,
                pausedAt: initialTimestamp,
                lastLapStart: initialTimestamp,
                laps: []
            }
        };
    }

    function validateDocument(document) {
        const pomodoro = document.pomodoro;
        const stopwatch = document.stopwatch;
        if (!pomodoro.running && pomodoro.deadlineAt < pomodoro.pausedAt)
            return "pomodoro deadlineAt must not precede pausedAt";
        if (!stopwatch.running && stopwatch.pausedAt < stopwatch.startedAt)
            return "stopwatch pausedAt must not precede startedAt";
        if (stopwatch.lastLapStart < stopwatch.startedAt)
            return "stopwatch lastLapStart must not precede startedAt";

        const ids = {};
        for (const timer of document.countdowns) {
            if (ids[timer.id])
                return "countdown IDs must be unique";
            ids[timer.id] = true;
            if (timer.remainingMs > timer.durationMs)
                return "countdown remainingMs must not exceed durationMs";
            if (timer.state === "running" && (timer.deadlineAt <= 0 || timer.remainingMs !== 0))
                return "running countdown fields are inconsistent";
            if (timer.state === "idle" && (timer.deadlineAt !== 0 || timer.remainingMs !== timer.durationMs))
                return "idle countdown fields are inconsistent";
            if (timer.state === "paused" && (timer.deadlineAt !== 0 || timer.remainingMs <= 0))
                return "paused countdown fields are inconsistent";
            if (timer.state === "completed" && (timer.deadlineAt !== 0 || timer.remainingMs !== 0))
                return "completed countdown fields are inconsistent";
        }
        return true;
    }

    function countdownRemainingMs(timer) {
        return timer.state === "running"
            ? Math.max(0, timer.deadlineAt - nowMs)
            : timer.remainingMs;
    }

    function createCountdown(durationMs, once, label) {
        const duration = Math.floor(durationMs);
        if (duration <= 0)
            return false;

        const timestamp = Date.now();
        timerStore.update(document => {
            const id = document.nextCountdownId++;
            document.countdowns = document.countdowns.concat([{
                id: id,
                label: String(label ?? "").trim(),
                durationMs: duration,
                deadlineAt: timestamp + duration,
                remainingMs: 0,
                state: "running",
                once: once !== false
            }]);
        });
        nowMs = timestamp;
        return true;
    }

    function toggleCountdown(id) {
        const timestamp = Date.now();
        nowMs = timestamp;
        completeDueCountdowns(timestamp);
        timerStore.update(document => {
            const timer = document.countdowns.find(candidate => candidate.id === id);
            if (!timer)
                return;
            if (timer.state === "running") {
                timer.remainingMs = Math.max(1, timer.deadlineAt - timestamp);
                timer.deadlineAt = 0;
                timer.state = "paused";
            } else if (timer.state === "paused" || timer.state === "idle") {
                timer.deadlineAt = timestamp + timer.remainingMs;
                timer.remainingMs = 0;
                timer.state = "running";
            }
        });
    }

    function restartCountdown(id) {
        const timestamp = Date.now();
        timerStore.update(document => {
            const timer = document.countdowns.find(candidate => candidate.id === id);
            if (!timer)
                return;
            if (timer.state === "running") {
                timer.deadlineAt = timestamp + timer.durationMs;
                timer.remainingMs = 0;
            } else if (timer.state === "paused") {
                timer.state = timer.once ? "running" : "idle";
                timer.deadlineAt = timer.once ? timestamp + timer.durationMs : 0;
                timer.remainingMs = timer.once ? 0 : timer.durationMs;
            }
        });
        nowMs = timestamp;
    }

    function acknowledgeCountdown(id) {
        dismissCountdownNotification(id);
        timerStore.update(document => {
            const index = document.countdowns.findIndex(timer => timer.id === id);
            if (index < 0 || document.countdowns[index].state !== "completed")
                return;
            if (document.countdowns[index].once) {
                document.countdowns.splice(index, 1);
                document.countdowns = document.countdowns.slice();
            } else {
                const timer = document.countdowns[index];
                timer.state = "idle";
                timer.deadlineAt = 0;
                timer.remainingMs = timer.durationMs;
            }
        });
    }

    function deleteCountdown(id) {
        dismissCountdownNotification(id);
        timerStore.update(document => {
            document.countdowns = document.countdowns.filter(timer => timer.id !== id);
        });
    }

    function renameCountdown(id, label) {
        timerStore.update(document => {
            const timer = document.countdowns.find(candidate => candidate.id === id);
            if (timer)
                timer.label = String(label).trim();
        });
    }

    function completeDueCountdowns(timestamp) {
        const completed = countdownTimers.filter(timer => timer.state === "running" && timer.deadlineAt <= timestamp);
        if (completed.length === 0)
            return;

        timerStore.update(document => {
            document.countdowns.forEach(timer => {
                if (timer.state === "running" && timer.deadlineAt <= timestamp) {
                    timer.state = "completed";
                    timer.deadlineAt = 0;
                    timer.remainingMs = 0;
                }
            });
        });
        completed.forEach(timer => enqueueNotification("Timer complete", timer.label || "Countdown finished", timer.id));
    }

    function dismissCountdownNotification(id) {
        const notificationId = countdownNotificationIds[id];
        if (notificationId !== undefined)
            Notifications.dismiss(String(notificationId));

        const category = "quickshell.timer." + id;
        Notifications.notifications.forEach(entry => {
            if (entry.category === category && String(entry.notificationId) !== String(notificationId ?? ""))
                Notifications.dismiss(entry.notificationId);
        });

        const nextIds = Object.assign({}, countdownNotificationIds);
        delete nextIds[id];
        countdownNotificationIds = nextIds;
    }

    function enqueueNotification(title, body, countdownId) {
        notificationQueue = notificationQueue.concat([{
            title: title,
            body: body,
            countdownId: Number(countdownId) || 0
        }]);
        runNextNotification();
    }

    function runNextNotification() {
        if (notification.running || notificationQueue.length === 0)
            return;
        const next = notificationQueue[0];
        notificationQueue = notificationQueue.slice(1);
        notifyingCountdownId = next.countdownId;
        const command = ["notify-send", "--print-id", "--urgency=critical", "--app-name=Timer"];
        if (next.countdownId > 0)
            command.push("--category=quickshell.timer." + next.countdownId);
        command.push(next.title, next.body);
        notification.command = command;
        notification.running = true;
    }

    function togglePomodoro() {
        const timestamp = Date.now();
        timerStore.update(document => {
            const pomodoro = document.pomodoro;
            if (pomodoro.running) {
                pomodoro.running = false;
                pomodoro.pausedAt = timestamp;
            } else {
                pomodoro.deadlineAt += Math.max(0, timestamp - pomodoro.pausedAt);
                pomodoro.pausedAt = 0;
                pomodoro.running = true;
            }
        });
        nowMs = timestamp;
    }

    function resetPomodoro() {
        const timestamp = Date.now();
        timerStore.update(document => {
            document.pomodoro.running = false;
            document.pomodoro.pausedAt = timestamp;
            document.pomodoro.deadlineAt = timestamp + durationForPhase(document.pomodoro.phase) * 1000;
        });
        nowMs = timestamp;
    }

    function advancePomodoro(pauseNextPhase) {
        const timestamp = Date.now();
        let nextPhaseName = "";
        let nextPhaseRunning = false;

        timerStore.update(document => {
            const pomodoro = document.pomodoro;
            if (pomodoro.phase === 0) {
                pomodoro.completedSessions++;
                pomodoro.phase = pomodoro.completedSessions % sessionsBeforeLongBreak === 0 ? 2 : 1;
            } else {
                pomodoro.phase = 0;
            }

            if (pauseNextPhase)
                pomodoro.running = false;
            pomodoro.pausedAt = pomodoro.running ? 0 : timestamp;
            pomodoro.deadlineAt = timestamp + durationForPhase(pomodoro.phase) * 1000;
            nextPhaseName = pomodoro.phase === 0 ? "Focus" : pomodoro.phase === 1 ? "Short break" : "Long break";
            nextPhaseRunning = pomodoro.running;
        });

        nowMs = timestamp;
        enqueueNotification("Pomodoro", nextPhaseName + (nextPhaseRunning ? " started" : " ready"));
    }

    function toggleStopwatch() {
        const timestamp = Date.now();
        timerStore.update(document => {
            const stopwatch = document.stopwatch;
            if (stopwatch.running) {
                stopwatch.running = false;
                stopwatch.pausedAt = timestamp;
            } else {
                const pausedDuration = Math.max(0, timestamp - stopwatch.pausedAt);
                stopwatch.startedAt += pausedDuration;
                stopwatch.lastLapStart += pausedDuration;
                stopwatch.pausedAt = 0;
                stopwatch.running = true;
            }
        });
        nowMs = timestamp;
    }

    function resetStopwatch() {
        const timestamp = Date.now();
        timerStore.update(document => {
            document.stopwatch.running = false;
            document.stopwatch.startedAt = timestamp;
            document.stopwatch.pausedAt = timestamp;
            document.stopwatch.lastLapStart = timestamp;
            document.stopwatch.laps = [];
        });
        nowMs = timestamp;
    }

    function addLap() {
        const timestamp = stopwatchRunning ? Date.now() : state.stopwatch.pausedAt;
        const lapDuration = Math.max(0, timestamp - stopwatchLastLapStartMs);
        if (lapDuration <= 0)
            return;

        timerStore.update(document => {
            document.stopwatch.laps = document.stopwatch.laps.concat([lapDuration]);
            document.stopwatch.lastLapStart = timestamp;
        });
        nowMs = timestamp;
    }

    function reconcileLoadedState() {
        const timestamp = Date.now();
        nowMs = timestamp;
        completeDueCountdowns(timestamp);
        if (pomodoroRunning && timestamp >= pomodoroEndMs)
            advancePomodoro(true);
    }

    DocumentStore {
        id: timerStore

        documentName: "timer"
        storageClass: DocumentStore.State
        defaults: root.defaultDocument()
        schema: ({
            type: "object",
            required: ["version", "nextCountdownId", "countdowns", "pomodoro", "stopwatch"],
            properties: {
                version: { type: "integer", const: 2 },
                nextCountdownId: { type: "integer", minimum: 1 },
                countdowns: {
                    type: "array",
                    items: {
                        type: "object",
                        required: ["id", "label", "durationMs", "deadlineAt", "remainingMs", "state", "once"],
                        properties: {
                            id: { type: "integer", minimum: 1 },
                            label: { type: "string", maxLength: 120 },
                            durationMs: { type: "number", minimum: 1 },
                            deadlineAt: { type: "number", minimum: 0 },
                            remainingMs: { type: "number", minimum: 0 },
                            state: { type: "string", enum: ["idle", "running", "paused", "completed"] },
                            once: { type: "boolean" }
                        },
                        additionalProperties: false
                    }
                },
                pomodoro: {
                    type: "object",
                    required: ["phase", "completedSessions", "running", "deadlineAt", "pausedAt"],
                    properties: {
                        phase: { type: "integer", minimum: 0, maximum: 2 },
                        completedSessions: { type: "integer", minimum: 0 },
                        running: { type: "boolean" },
                        deadlineAt: { type: "number", minimum: 0 },
                        pausedAt: { type: "number", minimum: 0 }
                    },
                    additionalProperties: false
                },
                stopwatch: {
                    type: "object",
                    required: ["running", "startedAt", "pausedAt", "lastLapStart", "laps"],
                    properties: {
                        running: { type: "boolean" },
                        startedAt: { type: "number", minimum: 0 },
                        pausedAt: { type: "number", minimum: 0 },
                        lastLapStart: { type: "number", minimum: 0 },
                        laps: {
                            type: "array",
                            items: { type: "number", minimum: 0 }
                        }
                    },
                    additionalProperties: false
                }
            },
            additionalProperties: false
        })
        customValidator: document => root.validateDocument(document)

        onLoaded: root.reconcileLoadedState()
        onLoadRejected: errors => {
            console.warn("Timer state rejected; resetting:", JSON.stringify(errors));
            timerStore.reset();
            root.reconcileLoadedState();
        }
        onSaveRejected: errors => console.warn("Timer state save rejected:", JSON.stringify(errors))
    }

    Timer {
        running: root.pomodoroRunning || root.stopwatchRunning || root.anyCountdownRunning
        interval: root.stopwatchRunning ? 100 : 1000
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            root.nowMs = Date.now();
            root.completeDueCountdowns(root.nowMs);
            if (root.pomodoroRunning && root.nowMs >= root.pomodoroEndMs)
                root.advancePomodoro(false);
        }
    }

    Process {
        id: notification
        stdout: StdioCollector {
            onStreamFinished: {
                const notificationId = text.trim();
                if (root.notifyingCountdownId > 0 && notificationId !== "") {
                    const nextIds = Object.assign({}, root.countdownNotificationIds);
                    nextIds[root.notifyingCountdownId] = notificationId;
                    root.countdownNotificationIds = nextIds;
                }
            }
        }
        onExited: {
            root.notifyingCountdownId = 0;
            root.runNextNotification();
        }
    }
}
