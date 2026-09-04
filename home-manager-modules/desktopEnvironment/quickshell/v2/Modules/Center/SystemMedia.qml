import qs
import QtQuick
import QtQuick.Layouts

RowLayout {
    spacing: 0

    ResourceMeter {
        Layout.alignment: Qt.AlignVCenter
        icon: "memory"
        value: ResourceUsage.memoryUsedPercentage
    }

    ResourceMeter {
        Layout.alignment: Qt.AlignVCenter
        icon: "developer_board"
        value: ResourceUsage.cpuUsage
    }

    Rectangle {
        implicitWidth: 1
        implicitHeight: 18
        Layout.alignment: Qt.AlignVCenter
        color: Theme.surface1
    }

    Media {
        leftMargin: 10
        Layout.alignment: Qt.AlignVCenter
    }
}
