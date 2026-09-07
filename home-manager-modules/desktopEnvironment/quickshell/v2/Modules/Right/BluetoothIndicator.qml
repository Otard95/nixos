import qs
import QtQuick
import "../../Components"

MaterialSymbol {
    visible: BluetoothSource.available
    text: BluetoothSource.icon
    iconSize: Theme.fontL
    color: Theme.withLightness(Theme.accent, 0.9)
}
