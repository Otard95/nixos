import qs
import QtQuick
import QtQuick.Layouts
import "../../Components"

Rectangle {
    id: root

    implicitHeight: sliders.implicitHeight + 8
    color: Theme.mantle
    radius: Theme.innerRadius

    ColumnLayout {
        id: sliders
        anchors {
            fill: parent
            margins: 4
        }
        spacing: 5

        StyledSlider {
            Layout.fillWidth: true
            visible: BrightnessSource.available
            trackSize: StyledSlider.Wide
            trackColor: Theme.base
            value: BrightnessSource.available ? BrightnessSource.percent / 100 : 0
            onMoved: BrightnessSource.setPercent(value * 100)

            markers: [
                SliderMarker {
                    value: 0.3
                    divider: true
                    icon: "wb_twilight"
                },
                SliderMarker {
                    value: 1
                    icon: "light_mode"
                }
            ]
        }

    }
}
