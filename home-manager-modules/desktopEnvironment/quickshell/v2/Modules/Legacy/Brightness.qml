import qs
import QtQuick
import "../../Components"

Pill {
    id: root

    visible: BrightnessSource.available
    readonly property real level: Math.max(0, Math.min(1, BrightnessSource.percent / 100))
    readonly property color iconColor: Qt.rgba(
        Theme.overlay1.r + (Theme.text.r - Theme.overlay1.r) * level,
        Theme.overlay1.g + (Theme.text.g - Theme.overlay1.g) * level,
        Theme.overlay1.b + (Theme.text.b - Theme.overlay1.b) * level,
        1
    )

    Item {
        implicitWidth: 32
        implicitHeight: Theme.barHeight - 8

        MaterialSymbol {
            anchors.centerIn: parent
            text: "light_mode"
            color: root.iconColor
            iconSize: Theme.fontL
        }

        MouseArea {
            anchors.fill: parent
            onWheel: event => BrightnessSource.set(event.angleDelta.y > 0 ? "2%+" : "2%-")
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
            onClicked: event => {
                if (event.button === Qt.LeftButton)
                    BrightnessSource.set("100%");
                else if (event.button === Qt.MiddleButton)
                    BrightnessSource.set("50%");
                else
                    BrightnessSource.set("10%");
            }
        }
    }
}
