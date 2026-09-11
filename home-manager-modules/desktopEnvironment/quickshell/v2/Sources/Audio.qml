pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

// Audio source for the AudioDialog: overall output/input, per-app streams, and
// device selection. Built additively alongside the existing VolumeSource — the
// overall helpers mirror it so consumers can migrate by rename later.
//
// Card profiles (codec/profile per device) are NOT here: Quickshell.Services.
// Pipewire does not expose them. See Sources/AudioProfile.qml for the strategy
// scaffold that a future external backend will fill in.
Singleton {
    id: root

    // ── Overall (mirrors VolumeSource) ─────────────────────────────────
    readonly property PwNode sink:   Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    readonly property bool sinkAvailable: sink?.audio !== undefined && sink?.audio !== null
    readonly property bool sinkMuted:     sink?.audio?.muted ?? false
    readonly property real sinkVolume:    sink?.audio?.volume ?? 0.0
    readonly property int  sinkPercent:   Math.round(sinkVolume * 100)

    function toggleSinkMute() { if (sink?.audio) sink.audio.muted = !sink.audio.muted }
    function setSinkVolume(v) { if (sink?.audio) sink.audio.volume = Math.max(0, Math.min(1, v)) }

    readonly property bool sourceAvailable: source?.audio !== undefined && source?.audio !== null
    readonly property bool sourceMuted:     source?.audio?.muted ?? false
    readonly property real sourceVolume:    source?.audio?.volume ?? 0.0
    readonly property int  sourcePercent:   Math.round(sourceVolume * 100)

    function toggleSourceMute() { if (source?.audio) source.audio.muted = !source.audio.muted }
    function setSourceVolume(v) { if (source?.audio) source.audio.volume = Math.max(0, Math.min(1, v)) }

    // ── Node lists ─────────────────────────────────────────────────────
    // Filter on documented booleans, not media.class strings. `audio` presence
    // is valid without binding; `isStream`/`isSink` are readonly and always set.
    //   isStream  → application (true) vs hardware device (false)
    //   isSink    → accepts audio in (true) vs outputs audio (false)
    // So a playback app outputs (isSink false); a recording app receives
    // (isSink true). Devices invert: a sink device accepts, a source outputs.
    readonly property var _nodes: Pipewire.nodes.values

    function _audioNodes(pred) {
        return root._nodes.filter(n => n.audio && pred(n))
    }

    // Devices: all hardware audio nodes (selectable regardless of links).
    readonly property var sinks:   _audioNodes(n => !n.isStream && n.isSink)
    readonly property var sources: _audioNodes(n => !n.isStream && !n.isSink)

    // App streams come from links to the default device, not from every stream
    // node. An app can hold an idle/unlinked stream open (browsers do this for
    // getUserMedia) — that is not "in use" and must not show. This matches the
    // bar's mic-activity logic (Mic.qml), so dialog and bar always agree.
    PwNodeLinkTracker { id: sinkLinks;   node: Pipewire.defaultAudioSink }
    PwNodeLinkTracker { id: sourceLinks; node: Pipewire.defaultAudioSource }

    // Peak-meter / monitor streams (pavucontrol, etc.) pollute the list. Same
    // blocklist idea as Mic.qml, checking both node.name and application.name.
    readonly property var meterApps: ["PulseAudio Volume Control", "pavucontrol"]
    function _isMeter(node) {
        const hay = [node.properties?.["application.name"] ?? "", node.name ?? ""]
        return root.meterApps.some(m => hay.some(h => h.includes(m)))
    }

    // The app on the far end of each link (the node that is not the device).
    function _linkedStreams(tracker, dev) {
        const out = []
        if (!dev) return out
        for (const lg of tracker.linkGroups) {
            const n = lg.source === dev ? lg.target : lg.source
            if (n && n.isStream && n.audio && !root._isMeter(n) && !out.includes(n))
                out.push(n)
        }
        return out
    }

    readonly property var outputStreams: _linkedStreams(sinkLinks, sink)
    readonly property var inputStreams:  _linkedStreams(sourceLinks, source)

    // volume/muted/properties are invalid unless the node is bound. Track every
    // node we surface so rows can read them. Deduped — defaults also appear in
    // the device lists.
    readonly property var trackedNodes: {
        const out = []
        const push = n => { if (n && !out.includes(n)) out.push(n) }
        push(sink); push(source)
        for (const n of outputStreams) push(n)
        for (const n of inputStreams)  push(n)
        for (const n of sinks)         push(n)
        for (const n of sources)       push(n)
        return out
    }

    PwObjectTracker { objects: root.trackedNodes }

    // ── Per-node helpers ───────────────────────────────────────────────
    function nodeVolume(node)  { return node?.audio?.volume ?? 0.0 }
    function nodeMuted(node)   { return node?.audio?.muted ?? false }
    function nodePercent(node) { return Math.round(root.nodeVolume(node) * 100) }

    function setNodeVolume(node, v) {
        if (node?.audio) node.audio.volume = Math.max(0, Math.min(1, v))
    }
    function toggleNodeMute(node) {
        if (node?.audio) node.audio.muted = !node.audio.muted
    }

    function nodeLabel(node) {
        if (!node) return ""
        const p = node.properties ?? {}
        return p["application.name"] || node.description || p["media.name"]
            || node.nickname || node.name || ""
    }

    // Freedesktop icon name hint (for future image use); rows fall back to a
    // Material symbol by kind.
    function nodeIcon(node) {
        return node?.properties?.["application.icon-name"] ?? ""
    }

    // ── Default device selection ───────────────────────────────────────
    // preferredDefault* is a hint; defaultAudioSink/Source is what actually won.
    function setDefaultSink(node)   { if (node) Pipewire.preferredDefaultAudioSink = node }
    function setDefaultSource(node) { if (node) Pipewire.preferredDefaultAudioSource = node }

    function isDefaultSink(node)   { return !!node && node === sink }
    function isDefaultSource(node) { return !!node && node === source }
}
