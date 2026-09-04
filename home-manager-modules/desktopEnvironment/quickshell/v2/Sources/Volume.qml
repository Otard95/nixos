pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property PwNode sink:   Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    PwObjectTracker { objects: [sink, source] }

    // Sink helpers
    readonly property bool   sinkAvailable: sink?.audio !== undefined && sink?.audio !== null
    readonly property bool   sinkMuted:     sink?.audio?.muted ?? false
    readonly property real   sinkVolume:    sink?.audio?.volume ?? 0.0
    readonly property int    sinkPercent:   Math.round(sinkVolume * 100)

    function toggleSinkMute()  { if (sink?.audio) sink.audio.muted = !sink.audio.muted }
    function setSinkVolume(v)  { if (sink?.audio) sink.audio.volume = Math.max(0, Math.min(1, v)) }
    function stepSinkVolume(d) { setSinkVolume(sinkVolume + d) }

    // Source helpers
    readonly property bool   sourceAvailable: source?.audio !== undefined && source?.audio !== null
    readonly property bool   sourceMuted:     source?.audio?.muted ?? false
    readonly property real   sourceVolume:    source?.audio?.volume ?? 0.0
    readonly property int    sourcePercent:   Math.round(sourceVolume * 100)

    function toggleSourceMute()  { if (source?.audio) source.audio.muted = !source.audio.muted }
    function setSourceVolume(v)  { if (source?.audio) source.audio.volume = Math.max(0, Math.min(1, v)) }
    function stepSourceVolume(d) { setSourceVolume(sourceVolume + d) }
}
