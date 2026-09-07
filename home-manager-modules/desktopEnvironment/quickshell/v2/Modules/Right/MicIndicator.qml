import qs
import QtQuick
import "../../Components"

MaterialSymbol {
    visible: Mic.active || VolumeSource.sourceMuted
    text: VolumeSource.sourceMuted ? "mic_off" : "mic"
    iconSize: Theme.fontL
    color: Mic.active ? Theme.red : Theme.withLightness(Theme.accent, 0.9)
}
