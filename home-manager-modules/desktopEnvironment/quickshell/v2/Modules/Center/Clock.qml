import qs
import QtQuick
import QtQuick.Layouts
import Quickshell

Pill {
    id: root

    required property var panelWindow

    readonly property int displayFontSize: 50
    readonly property int displaySecondaryFontSize: 25

    leftMargin: 10
    rightMargin: 10

    Item {
        implicitWidth: clockRow.implicitWidth + Theme.innerPadH * 2
        implicitHeight: Theme.barHeight

        RowLayout {
            id: clockRow
            anchors.centerIn: parent
            spacing: 4

            StyledText {
                text: Time.hm
                color: Theme.accentText
                font.family: Theme.font
                font.pixelSize: Theme.fontL
                Layout.alignment: Qt.AlignVCenter
            }

            StyledText {
                text: "•"
                color: Theme.subtext1
                font.family: Theme.font
                font.pixelSize: Theme.fontS
                Layout.alignment: Qt.AlignVCenter
            }

            StyledText {
                text: Qt.formatDate(Time.date, "ddd, dd MMM")
                color: Theme.withLightness(Theme.accentText, 0.7)
                font.family: Theme.font
                font.pixelSize: Theme.fontM
                Layout.alignment: Qt.AlignVCenter
            }
        }
    }
}
