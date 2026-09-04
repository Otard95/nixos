pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: root

    readonly property var players: Mpris.players.values.filter(player => player.dbusName !== "org.mpris.MediaPlayer2.playerctld")
    property MprisPlayer selectedPlayer: null
    readonly property MprisPlayer activePlayer: players.includes(selectedPlayer) ? selectedPlayer : players.find(player => player.isPlaying) ?? players[0] ?? null
    readonly property real progress: {
        const length = activePlayer?.length ?? 0;
        return length > 0 ? Math.max(0, Math.min(1, activePlayer.position / length)) : 0;
    }

    function selectPlayer(offset) {
        if (players.length < 1)
            return;
        const currentIndex = Math.max(0, players.indexOf(activePlayer));
        selectedPlayer = players[(currentIndex + offset + players.length) % players.length];
    }

    function selectNextPlayer() {
        selectPlayer(1);
    }

    function selectPreviousPlayer() {
        selectPlayer(-1);
    }

    function togglePlaying() {
        if (activePlayer?.isPlaying) {
            if (activePlayer.canPause)
                activePlayer.pause();
        } else if (activePlayer?.canPlay) {
            activePlayer.play();
        }
    }

    function previous() {
        if (activePlayer?.canGoPrevious)
            activePlayer.previous();
    }

    function next() {
        if (activePlayer?.canGoNext)
            activePlayer.next();
    }

    Timer {
        running: (root.activePlayer?.isPlaying ?? false) && (root.activePlayer?.positionSupported ?? false)
        interval: 1000
        repeat: true
        triggeredOnStart: true
        onTriggered: root.activePlayer?.positionChanged()
    }
}
