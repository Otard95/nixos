import qs
import QtQuick
import QtQuick.Layouts
import "." as StatusWidgets
import "../../../Components"

Rectangle {
    id: root

    readonly property int selectedTool: StatusPanelState.selectedTool
    readonly property bool collapsed: StatusPanelState.collapsed
    property int displayedTool: 0
    property int pendingTool: 0
    property bool switchDown: true

    Component.onCompleted: {
        displayedTool = selectedTool;
        pendingTool = selectedTool;
    }
    readonly property var tools: [
        {
            "name": "Calendar",
            "icon": "calendar_month"
        },
        {
            "name": "Timer",
            "icon": "schedule"
        },
        {
            "name": "Media",
            "icon": "music_note"
        }
    ]

    implicitHeight: collapsed ? 54 : 350
    color: Theme.mantle
    radius: Theme.innerRadius
    clip: true

    Behavior on implicitHeight {
        NumberAnimation {
            duration: 180
            easing.type: Easing.OutCubic
        }
    }

    RowLayout {
        id: expandedBody
        anchors.fill: parent
        spacing: 0
        opacity: root.collapsed ? 0 : 1
        enabled: !root.collapsed

        Behavior on opacity {
            NumberAnimation {
                duration: 120
            }
        }

        Item {
            Layout.preferredWidth: 78
            Layout.fillHeight: true

            ToolButton {
                anchors {
                    top: parent.top
                    horizontalCenter: parent.horizontalCenter
                    topMargin: 10
                }
                icon: "keyboard_arrow_down"
                onClicked: StatusPanelState.setCollapsed(true)
            }

            Column {
                anchors.centerIn: parent
                spacing: 8

                Repeater {
                    model: root.tools

                    delegate: WidgetSelector {
                        required property int index
                        required property var modelData

                        label: modelData.name
                        icon: modelData.icon
                        selected: root.selectedTool === index
                        onClicked: StatusPanelState.setSelectedTool(index)
                    }
                }
            }
        }

        Rectangle {
            Layout.preferredWidth: 1
            Layout.fillHeight: true
            Layout.topMargin: 10
            Layout.bottomMargin: 10
            color: Theme.surface0
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            StackLayout {
                id: contentStack

                anchors.fill: parent
                currentIndex: root.displayedTool
                transform: Translate {
                    id: contentTranslation
                }

                StatusWidgets.Calendar {}
                StatusWidgets.Timer {}
                StatusWidgets.Media {}
            }
        }
    }

    RowLayout {
        id: collapsedBody
        anchors {
            fill: parent
            leftMargin: 10
            rightMargin: 14
        }
        spacing: 10
        opacity: root.collapsed ? 1 : 0
        enabled: root.collapsed

        Behavior on opacity {
            NumberAnimation {
                duration: 120
            }
        }

        ToolButton {
            icon: "keyboard_arrow_up"
            onClicked: StatusPanelState.setCollapsed(false)
        }

        StyledText {
            color: Theme.text
            font.weight: Theme.weightBold
            text: Qt.formatDateTime(Time.date, "ddd, MMM d")
        }

        StyledText {
            visible: MediaSource.activePlayer !== null
            color: Theme.overlay0
            text: "•"
        }

        StyledText {
            visible: MediaSource.activePlayer !== null
            Layout.fillWidth: true
            color: Theme.subtext0
            elide: Text.ElideRight
            text: {
                const player = MediaSource.activePlayer;
                if (!player)
                    return "";
                return player.trackArtist ? player.trackTitle + " — " + player.trackArtist : player.trackTitle;
            }
        }

        Item {
            visible: MediaSource.activePlayer === null
            Layout.fillWidth: true
        }

        Item {
            visible: TimerSource.nextCountdownTimer !== null
            implicitWidth: timerSummaryRow.implicitWidth
            implicitHeight: 24
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight

            Row {
                id: timerSummaryRow
                anchors.centerIn: parent
                spacing: 4

                MaterialSymbol {
                    width: 18
                    height: 24
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: Theme.accent
                    iconSize: 17
                    text: "timer"
                }

                StyledText {
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.subtext0
                    font.weight: Theme.weightBold
                    text: {
                        const timer = TimerSource.nextCountdownTimer;
                        if (!timer)
                            return "";
                        const total = Math.max(0, Math.ceil(TimerSource.countdownRemainingMs(timer) / 1000));
                        const hours = Math.floor(total / 3600);
                        const minutes = Math.floor(total % 3600 / 60);
                        const seconds = total % 60;
                        return hours > 0
                            ? hours.toString().padStart(2, "0") + ":" + minutes.toString().padStart(2, "0") + ":" + seconds.toString().padStart(2, "0")
                            : minutes.toString().padStart(2, "0") + ":" + seconds.toString().padStart(2, "0");
                    }
                }
            }
        }
    }

    onSelectedToolChanged: {
        if (root.selectedTool === root.displayedTool)
            return;
        if (root.collapsed) {
            root.displayedTool = root.selectedTool;
            return;
        }

        toolSwitchAnimation.stop();
        contentStack.opacity = 1;
        contentTranslation.y = 0;
        root.pendingTool = root.selectedTool;
        root.switchDown = root.pendingTool > root.displayedTool;
        toolSwitchAnimation.start();
    }

    SequentialAnimation {
        id: toolSwitchAnimation

        ParallelAnimation {
            NumberAnimation {
                target: contentStack
                property: "opacity"
                to: 0
                duration: 100
                easing.type: Easing.InCubic
            }

            NumberAnimation {
                target: contentTranslation
                property: "y"
                to: root.switchDown ? -10 : 10
                duration: 100
                easing.type: Easing.InCubic
            }
        }

        ScriptAction {
            script: {
                root.displayedTool = root.pendingTool;
                contentTranslation.y = root.switchDown ? 10 : -10;
            }
        }

        ParallelAnimation {
            NumberAnimation {
                target: contentStack
                property: "opacity"
                to: 1
                duration: 120
                easing.type: Easing.OutCubic
            }

            NumberAnimation {
                target: contentTranslation
                property: "y"
                to: 0
                duration: 120
                easing.type: Easing.OutCubic
            }
        }
    }

    component ToolButton: Rectangle {
        id: button

        required property string icon
        signal clicked

        implicitWidth: 34
        implicitHeight: 34
        radius: height / 2
        color: buttonMouse.containsMouse ? Theme.surface0 : Theme.base

        MaterialSymbol {
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            iconSize: 20
            color: Theme.text
            text: button.icon
        }

        MouseArea {
            id: buttonMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: button.clicked()
        }
    }
}
