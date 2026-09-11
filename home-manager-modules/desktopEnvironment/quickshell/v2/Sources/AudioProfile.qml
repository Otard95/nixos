pragma Singleton
import QtQuick
import Quickshell
import "./AudioProfile" as Strategies

// Proxy/adapter singleton for audio card profiles — the codec/profile dropdown
// per output device (e.g. "High Fidelity Playback (A2DP, aptX HD)" vs
// "Headset Head Unit (HSP/HFP)"). Quickshell.Services.Pipewire does NOT expose
// card profiles, so this needs an external backend.
//
// None is implemented yet: `impl` defaults to the Null strategy (empty, no-op),
// so the dialog's profile section stays hidden. To add a backend, implement a
// strategy exposing the interface below and point `impl` at it.
//
// ─── Strategy interface ─────────────────────────────────────────────────────
//
//   available : bool                    // backend usable
//
//   cards : Array<{
//     id:                 string | int
//     name:               string
//     nodeName:           string        // matches PwNode.name for association
//     activeProfileIndex: int
//     profiles: Array<{ index: int, name: string, available: bool }>
//   }>
//
//   cardForNode(node) : card | null     // associate a device node to its card
//   setProfile(cardId, profileIndex) : void
//
// Candidate future strategies:
//   - PactlStrategy   — `pactl list cards` + `pactl set-card-profile`
//                       (needs pactl installed; currently absent on this host).
//   - PwDumpStrategy  — `pw-dump` (Device objects, EnumProfile/Profile params)
//                       + `pw-cli set-param <id> Profile '{ index: N }'`.
// ─────────────────────────────────────────────────────────────────────────────
Singleton {
    id: root

    property var impl: nullStrategy

    readonly property bool available: impl.available
    readonly property var  cards:     impl.cards

    function cardForNode(node)        { return impl.cardForNode(node) }
    function setProfile(cardId, index) { impl.setProfile(cardId, index) }

    Strategies.NullProfileStrategy { id: nullStrategy }
    // Strategies.PactlStrategy { id: pactl }   // swap impl above to use this
}
