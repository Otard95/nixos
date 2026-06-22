import qs
import QtQuick
import Quickshell.Io

// Only visible when brightnessctl is available (i.e. on laptops with backlights).
Pill {
    id: root

    property int brightness: -1
    property int maxBrightness: -1
    readonly property int percent: maxBrightness > 0
        ? Math.round(brightness / maxBrightness * 100) : -1

    // Hide when brightness info is unavailable.
    visible: percent >= 0

    Process {
        id: getProc
        command: ["brightnessctl", "-m"]
        running: true
        stdout: StdioCollector {
            // -m output format: device,class,current,percentage,max
            onStreamFinished: {
                const parts = this.text.trim().split(",")
                if (parts.length >= 5) {
                    root.brightness = parseInt(parts[2]) || 0
                    root.maxBrightness = parseInt(parts[4]) || 0
                }
            }
        }
    }

    Timer {
        interval: 5000
        running: root.percent >= 0
        repeat: true
        onTriggered: getProc.running = true
    }

    Item {
        implicitWidth:  row.implicitWidth + Theme.innerPadH * 2
        implicitHeight: Theme.barHeight - 10

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 4

            Text {
                anchors.verticalCenter: parent.verticalCenter
                font.family: Theme.font
                font.pixelSize: Theme.fontLg
                color: Theme.text
                text: "☀"
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                font.family: Theme.font
                font.pixelSize: Theme.fontSm
                color: Theme.text
                text: percent >= 0 ? percent + "%" : ""
            }
        }

        MouseArea {
            anchors.fill: parent
            onWheel: (event) => {
                if (event.angleDelta.y > 0)
                    setProc.command = ["brightnessctl", "s", "2%+"]
                else
                    setProc.command = ["brightnessctl", "s", "2%-"]
                setProc.running = true
            }
            // Click presets matching the waybar config.
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
            onClicked: (event) => {
                if (event.button === Qt.LeftButton)
                    setProc.command = ["brightnessctl", "s", "100%"]
                else if (event.button === Qt.MiddleButton)
                    setProc.command = ["brightnessctl", "s", "50%"]
                else
                    setProc.command = ["brightnessctl", "s", "10%"]
                setProc.running = true
            }
        }
    }

    Process {
        id: setProc
        running: false
        // Re-poll after a set command completes.
        onRunningChanged: if (!running) getProc.running = true
    }
}
