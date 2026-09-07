import qs
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property real padding: 5
    default property alias content: layout.children

    signal clicked

    implicitWidth: layout.implicitWidth + padding * 2
    implicitHeight: Theme.barHeight

    Rectangle {
        anchors {
            fill: parent
            topMargin: 4
            bottomMargin: 4
        }
        radius: 8
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop {
                position: 0
                color: Theme.alpha(Theme.mantle, Theme.bgAlpha)
            }
            GradientStop {
                position: 0.5
                color: Theme.base // Theme.withSaturation(Theme.withLightness(Theme.accent, 0.14), 0.05)
            }
            GradientStop {
                position: 1
                color: Theme.alpha(Theme.mantle, Theme.bgAlpha)
            }
        }
    }

    TapHandler {
        acceptedButtons: Qt.LeftButton
        onTapped: root.clicked()
    }

    RowLayout {
        id: layout
        anchors {
            left: parent.left
            right: parent.right
            leftMargin: root.padding
            rightMargin: root.padding
            verticalCenter: parent.verticalCenter
        }
        spacing: 6
    }
}
