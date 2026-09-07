import qs
import QtQuick
import "../../Components"

StyledText {
    visible: Keyboard.available
    color: Theme.withLightness(Theme.accent, 0.9)
    font.pixelSize: Theme.fontM
    text: Keyboard.shortName
}
