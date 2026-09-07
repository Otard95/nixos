import qs
import QtQuick
import "../../Components"

MaterialSymbol {
    visible: VolumeSource.sinkMuted
    text: "volume_off"
    iconSize: Theme.fontL
    color: Theme.withLightness(Theme.accent, 0.9)
}
