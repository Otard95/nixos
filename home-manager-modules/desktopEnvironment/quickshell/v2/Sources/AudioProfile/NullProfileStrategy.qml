import QtQuick
import Quickshell

// No-op audio profile backend. Active by default until a real strategy
// (pactl / pw-dump) is implemented. See Sources/AudioProfile.qml for the
// interface a real strategy must satisfy.
Scope {
    property bool available: false
    property var  cards: []

    function cardForNode(node) { return null }
    function setProfile(cardId, index) {}
}
