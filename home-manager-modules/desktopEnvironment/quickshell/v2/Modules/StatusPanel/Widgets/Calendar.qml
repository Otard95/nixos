import qs
import QtQuick
import QtQuick.Layouts
import "calendar_layout.js" as CalendarLayout
import "../../../Components"

Rectangle {
    id: root

    property int monthShift: 0
    readonly property string todayKey: Qt.formatDateTime(Time.date, "yyyy-MM-dd")
    readonly property var viewingDate: CalendarLayout.getDateInXMonthsTime(monthShift, new Date(todayKey + "T12:00:00"))
    readonly property var days: CalendarLayout.getCalendarLayout(viewingDate, monthShift === 0)

    implicitHeight: calendar.implicitHeight + 20
    color: "transparent"

    MouseArea {
        anchors.fill: parent
        onWheel: event => root.monthShift += event.angleDelta.y > 0 ? -1 : 1
    }

    ColumnLayout {
        id: calendar
        anchors {
            fill: parent
            margins: 10
        }
        spacing: 5

        RowLayout {
            Layout.fillWidth: true

            Rectangle {
                Layout.preferredWidth: monthLabel.implicitWidth + 20
                Layout.preferredHeight: 34
                radius: height / 2
                color: monthMouse.containsMouse ? Theme.surface0 : Theme.base

                StyledText {
                    id: monthLabel
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    color: Theme.text
                    font.pixelSize: Theme.fontL
                    font.weight: Theme.weightBold
                    text: (root.monthShift !== 0 ? "• " : "") + root.viewingDate.toLocaleDateString(Qt.locale(), "MMMM yyyy")
                }

                MouseArea {
                    id: monthMouse
                    anchors.fill: parent
                    enabled: root.monthShift !== 0
                    hoverEnabled: true
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: root.monthShift = 0
                }
            }

            Item {
                Layout.fillWidth: true
            }

            NavButton {
                icon: "chevron_left"
                onClicked: root.monthShift--
            }

            NavButton {
                icon: "chevron_right"
                onClicked: root.monthShift++
            }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 7
            columnSpacing: 5
            rowSpacing: 5

            Repeater {
                model: CalendarLayout.weekDays
                delegate: Rectangle {
                    required property string modelData
                    Layout.fillWidth: true
                    Layout.preferredHeight: 28
                    color: "transparent"

                    StyledText {
                        anchors.fill: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: Theme.overlay0
                        font.weight: Theme.weightBold
                        text: modelData
                    }
                }
            }

            Repeater {
                model: 42
                delegate: Rectangle {
                    required property int index
                    readonly property var dayData: root.days[Math.floor(index / 7)][index % 7]
                    Layout.fillWidth: true
                    Layout.preferredHeight: 38
                    radius: Theme.innerRadius
                    color: dayData.today === 1 ? Theme.accent : "transparent"

                    StyledText {
                        anchors.fill: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: dayData.today === 1 ? Theme.base : dayData.today === -1 ? Theme.overlay0 : Theme.text
                        text: dayData.day
                    }
                }
            }
        }
    }

    component NavButton: Rectangle {
        id: button

        required property string icon
        signal clicked

        implicitWidth: 34
        implicitHeight: 34
        radius: height / 2
        color: mouse.containsMouse ? Theme.surface0 : Theme.base

        MaterialSymbol {
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            iconSize: 20
            color: Theme.text
            text: button.icon
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: button.clicked()
        }
    }

}
