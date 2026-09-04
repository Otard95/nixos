import qs
import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../../Components"

Rectangle {
    id: root

    property string uptimeText: "Up 0m"
    property real horizontalPadding: 14
    property real verticalPadding: 10

    implicitWidth: uptimeRow.implicitWidth + horizontalPadding * 2
    implicitHeight: uptimeRow.implicitHeight + verticalPadding * 2
    color: Theme.mantle
    radius: height / 2

    function updateUptime() {
        const seconds = Math.floor(Number(uptimeFile.text().split(" ")[0]));
        if (!Number.isFinite(seconds))
            return;
        const minutes = Math.floor(seconds / 60);
        const hours = Math.floor(minutes / 60);
        const days = Math.floor(hours / 24);

        if (days > 0)
            uptimeText = `Up ${days}d ${hours % 24}h`;
        else if (hours > 0)
            uptimeText = `Up ${hours}h ${minutes % 60}m`;
        else
            uptimeText = `Up ${minutes}m`;
    }

    RowLayout {
        id: uptimeRow
        anchors.centerIn: parent
        spacing: 6

        MaterialSymbol {
            iconSize: 18
            color: Theme.subtext0
            text: "schedule"
        }

        StyledText {
            color: Theme.text
            font.pixelSize: Theme.fontL
            font.weight: Theme.weightBold
            text: root.uptimeText
        }
    }

    FileView {
        id: uptimeFile
        path: "/proc/uptime"
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            uptimeFile.reload();
            root.updateUptime();
        }
    }
}
