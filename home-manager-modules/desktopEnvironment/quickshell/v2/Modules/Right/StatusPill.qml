import qs
import QtQuick
import QtQuick.Layouts
import "../../Components"

Item {
    id: root

    signal toggleRequested

    readonly property color baseIconColor: Theme.withLightness(Theme.accent, 0.9)
    readonly property color networkColor: {
        if (!NetworkSource.available)
            return Theme.red;
        if (!NetworkSource.isWifi)
            return baseIconColor;
        const s = NetworkSource.signalStrength;
        return s < 0.25 ? Theme.red : s < 0.50 ? Theme.peach : baseIconColor;
    }

    implicitWidth: pill.implicitWidth
    implicitHeight: pill.implicitHeight

    BarGroup {
        id: pill
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        padding: 10

        RowLayout {
            id: indicators
            anchors.centerIn: parent
            spacing: 14

            // Volume muted — only when sink is muted
            MaterialSymbol {
                visible: VolumeSource.sinkMuted
                text: "volume_off"
                iconSize: Theme.fontL
                color: baseIconColor
            }

            // Mic — recording (red) when active, muted icon when muted
            MaterialSymbol {
                visible: Mic.active || VolumeSource.sourceMuted
                text: VolumeSource.sourceMuted ? "mic_off" : "mic"
                iconSize: Theme.fontL
                color: Mic.active ? Theme.red : baseIconColor
            }

            // Keyboard layout — only when layout info is available
            StyledText {
                visible: Keyboard.available
                color: baseIconColor
                font.pixelSize: Theme.fontM
                text: Keyboard.shortName
            }

            NotificationStatus {}

            // Network — always visible
            MaterialSymbol {
                text: NetworkSource.icon
                iconSize: Theme.fontL
                color: root.networkColor
            }

            // Bluetooth — only when adapter is present
            MaterialSymbol {
                visible: BluetoothSource.available
                text: BluetoothSource.icon
                iconSize: Theme.fontL
                color: baseIconColor
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        onClicked: root.toggleRequested()
        onWheel: event => VolumeSource.stepSinkVolume(event.angleDelta.y > 0 ? 0.02 : -0.02)
    }
}
