import qs
import QtQuick
import "../../Components"

Row {
    visible: Keyboard.available

    StyledText {
        anchors.verticalCenter: parent.verticalCenter
        color: Theme.withLightness(Theme.accent, 0.9)
        font.pixelSize: Theme.fontM
        text: Keyboard.shortName
    }

    MaterialSymbol {
        visible: Keyboard.capsLock
        anchors.verticalCenter: parent.verticalCenter
        iconSize: Theme.fontM
        color: Theme.yellow
        text: "keyboard_capslock"
    }
}
