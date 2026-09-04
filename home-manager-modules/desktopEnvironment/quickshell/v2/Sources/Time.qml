pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    // Formatted strings for common use
    readonly property string hm:  Qt.formatDateTime(clock.date, "hh:mm")
    readonly property string hms: Qt.formatDateTime(clock.date, "hh:mm:ss")

    // Individual components for custom layouts
    // h (no leading zero), hh (leading zero), mm, ss
    readonly property int hours:   clock.date.getHours()
    readonly property int minutes: clock.date.getMinutes()
    readonly property int seconds: clock.date.getSeconds()

    // Formatted individual parts
    readonly property string h:  hours.toString()               // no leading zero
    readonly property string hh: hours.toString().padStart(2, "0")
    readonly property string mm: minutes.toString().padStart(2, "0")
    readonly property string ss: seconds.toString().padStart(2, "0")

    // Date components
    readonly property var date: clock.date

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
}
