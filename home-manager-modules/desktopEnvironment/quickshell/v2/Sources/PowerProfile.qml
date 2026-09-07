pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

Singleton {
    id: root

    property bool available: false
    property int probeAttempts: 0

    readonly property int maxProbeAttempts: 6
    readonly property var probeDelays: [1000, 2000, 4000, 8000, 16000]
    readonly property int profile: available ? PowerProfiles.profile : PowerProfile.Balanced
    readonly property bool hasPerformance: available && PowerProfiles.hasPerformanceProfile

    function checkAvailability() {
        if (available || availabilityProbe.running || probeAttempts >= maxProbeAttempts)
            return

        probeAttempts++
        availabilityProbe.running = true
    }

    function scheduleRetry() {
        if (probeAttempts >= maxProbeAttempts)
            return

        retryTimer.interval = probeDelays[Math.min(probeAttempts - 1, probeDelays.length - 1)]
        retryTimer.restart()
    }

    function cycle() {
        if (!available)
            return

        const profiles = [PowerProfile.PowerSaver, PowerProfile.Balanced]

        if (hasPerformance)
            profiles.push(PowerProfile.Performance)

        const index = profiles.indexOf(profile)
        PowerProfiles.profile = profiles[(index + 1) % profiles.length]
    }

    Process {
        id: availabilityProbe

        command: [
            "busctl",
            "--system",
            "get-property",
            "org.freedesktop.UPower.PowerProfiles",
            "/org/freedesktop/UPower/PowerProfiles",
            "org.freedesktop.UPower.PowerProfiles",
            "ActiveProfile"
        ]

        onExited: (exitCode) => {
            if (exitCode === 0)
                root.available = true
            else
                root.scheduleRetry()
        }
    }

    Timer {
        id: retryTimer

        repeat: false
        onTriggered: root.checkAvailability()
    }

    Component.onCompleted: checkAvailability()
}
