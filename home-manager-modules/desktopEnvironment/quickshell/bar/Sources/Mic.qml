pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property var meterApps: ["PulseAudio Volume Control", "pavucontrol"]

    PwNodeLinkTracker {
        id: tracker
        node: Pipewire.defaultAudioSource
    }

    // True only when a real app (not a peak meter) is recording.
    readonly property bool active: {
        for (const lg of tracker.linkGroups) {
            if (!lg.target?.isStream) continue
            if (meterApps.some(n => lg.target.name.includes(n))) continue
            return true
        }
        return false
    }
}
