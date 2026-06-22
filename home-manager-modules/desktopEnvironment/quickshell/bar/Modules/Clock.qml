import qs
import QtQuick
import QtQuick.Layouts
import Quickshell

Pill {
    id: root

    required property var panelWindow

    property bool popupOpen: false

    Timer {
        id: closeTimer
        interval: 150
        repeat: false
        onTriggered: root.popupOpen = false
    }

    // ── Clock pill ────────────────────────────────────────────────────
    Item {
        implicitWidth:  label.implicitWidth + Theme.innerPadH * 2
        implicitHeight: Theme.barHeight - 10

        Text {
            id: label
            anchors.centerIn: parent
            text:  Time.hm
            color: Theme.text
            font.family: Theme.font
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: { closeTimer.stop(); root.popupOpen = true }
            onExited:  closeTimer.restart()
        }
    }

    // ── Calendar popup ────────────────────────────────────────────────
    PopupWindow {
        id: popup
        anchor.window: root.panelWindow
        anchor.rect.x: root.panelWindow.width - popupContent.implicitWidth - Theme.barMarginH
        anchor.rect.y: Theme.barHeight + 6
        visible: root.popupOpen

        color: "transparent"
        implicitWidth:  popupContent.implicitWidth
        implicitHeight: popupContent.implicitHeight

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: closeTimer.stop()
            onExited:  closeTimer.restart()
        }

        Rectangle {
            id: popupContent
            anchors.fill: parent
            implicitWidth:  calendarColumn.implicitWidth  + 32
            implicitHeight: calendarColumn.implicitHeight + 32

            color:  Theme.base
            radius: Theme.outerRadius

            // Refresh the calendar when date changes.
            readonly property var now: new Date()

            Timer {
                interval: 1000
                running:  popup.visible
                repeat:   true
                onTriggered: popupContent.refreshCalendar()
            }

            function refreshCalendar() {
                calendarRepeater.model = buildCalendar()
            }

            function buildCalendar() {
                const d     = new Date()
                const year  = d.getFullYear()
                const month = d.getMonth()
                const today = d.getDate()

                const firstDay = new Date(year, month, 1).getDay()
                // Week starts Monday: shift Sunday (0) to position 6.
                const offset = (firstDay + 6) % 7
                const daysInMonth    = new Date(year, month + 1, 0).getDate()
                const daysInPrevMonth = new Date(year, month, 0).getDate()

                const cells = []
                // Previous month tail
                for (let i = offset - 1; i >= 0; i--)
                    cells.push({ day: daysInPrevMonth - i, thisMonth: false, isToday: false })
                // This month
                for (let i = 1; i <= daysInMonth; i++)
                    cells.push({ day: i, thisMonth: true, isToday: i === today })
                // Next month head — fill to complete last row
                const remaining = (7 - cells.length % 7) % 7
                for (let i = 1; i <= remaining; i++)
                    cells.push({ day: i, thisMonth: false, isToday: false })

                return cells
            }

            Component.onCompleted: refreshCalendar()

            ColumnLayout {
                id: calendarColumn
                anchors.centerIn: parent
                spacing: 12

                // ── Time ─────────────────────────────────────────
                Item {
                    id: timeDisplay
                    Layout.alignment: Qt.AlignHCenter
                    implicitWidth:  mainTime.implicitWidth + supTime.implicitWidth
                    implicitHeight: mainTime.implicitHeight

                    // Hours : Minutes — large, baseline at bottom
                    Row {
                        id: mainTime
                        anchors.left:   parent.left
                        anchors.bottom: parent.bottom
                        spacing: 0

                        Text {
                            text: Time.h
                            color: Theme.text
                            font.family: Theme.font
                            font.pixelSize: Theme.fontDisplay
                            font.bold: true
                        }
                        Text {
                            text: ":"
                            color: Theme.overlay1
                            font.family: Theme.font
                            font.pixelSize: Theme.fontDisplay
                            font.bold: true
                        }
                        Text {
                            text: Time.mm
                            color: Theme.text
                            font.family: Theme.font
                            font.pixelSize: Theme.fontDisplay
                            font.bold: true
                        }
                    }

                    // : seconds — half size, dimmed, raised as superscript
                    Row {
                        id: supTime
                        anchors.left: mainTime.right
                        anchors.top:  parent.top
                        anchors.topMargin: 6
                        spacing: 0

                        Text {
                            text: Time.ss
                            color: Theme.overlay1
                            font.family: Theme.font
                            font.pixelSize: Theme.fontDisplaySm
                        }
                    }
                }

                // ── Date ─────────────────────────────────────────
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: Qt.formatDate(Time.date, "dddd, d MMMM yyyy")
                    color: Theme.subtext1
                    font.family: Theme.font
                    font.pixelSize: Theme.fontLg
                }

                // ── Calendar ──────────────────────────────────────
                ColumnLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 4

                    // Weekday headers
                    Row {
                        spacing: 0
                        Repeater {
                            model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
                            delegate: Text {
                                width:  36
                                height: 24
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment:   Text.AlignVCenter
                                text:  modelData
                                color: index >= 5 ? Theme.peach : Theme.subtext0
                                font.family: Theme.font
                                font.pixelSize: Theme.fontXs
                                font.bold: true
                            }
                        }
                    }

                    // Day grid
                    Grid {
                        columns: 7
                        spacing: 2

                        Repeater {
                            id: calendarRepeater
                            delegate: Rectangle {
                                required property var modelData
                                width:  36
                                height: 28
                                radius: 6
                                color: modelData.isToday ? Theme.peach : "transparent"

                                Text {
                                    anchors.centerIn: parent
                                    text:  modelData.day
                                    color: modelData.isToday  ? Theme.crust
                                         : modelData.thisMonth ? Theme.text
                                                               : Theme.surface2
                                    font.family: Theme.font
                                    font.pixelSize: Theme.fontSm
                                    font.bold: modelData.isToday
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
