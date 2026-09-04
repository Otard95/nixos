import qs
import QtQuick
import QtQuick.Layouts
import "../../../Components"

Item {
    id: root

    property int selectedTab: 0
    property string durationDigits: ""
    property bool createOnce: true

    readonly property string paddedDurationDigits: durationDigits.padStart(6, "0")
    readonly property int enteredDurationSeconds: {
        const digits = paddedDurationDigits;
        return Number(digits.slice(0, 2)) * 3600
            + Number(digits.slice(2, 4)) * 60
            + Number(digits.slice(4, 6));
    }

    function formatPomodoro(seconds) {
        const total = Math.max(0, Math.floor(seconds));
        return Math.floor(total / 60).toString().padStart(2, "0") + ":" + (total % 60).toString().padStart(2, "0");
    }

    function formatStopwatch(milliseconds) {
        const tenths = Math.max(0, Math.floor(milliseconds / 100));
        const hours = Math.floor(tenths / 36000);
        const minutes = Math.floor(tenths % 36000 / 600);
        const seconds = Math.floor(tenths % 600 / 10);
        const fraction = tenths % 10;
        return hours > 0
            ? hours.toString().padStart(2, "0") + ":" + minutes.toString().padStart(2, "0") + ":" + seconds.toString().padStart(2, "0") + "." + fraction
            : minutes.toString().padStart(2, "0") + ":" + seconds.toString().padStart(2, "0") + "." + fraction;
    }

    function formatCountdown(milliseconds) {
        const total = Math.max(0, Math.ceil(milliseconds / 1000));
        const hours = Math.floor(total / 3600);
        const minutes = Math.floor(total % 3600 / 60);
        const seconds = total % 60;
        return hours > 0
            ? hours.toString().padStart(2, "0") + ":" + minutes.toString().padStart(2, "0") + ":" + seconds.toString().padStart(2, "0")
            : minutes.toString().padStart(2, "0") + ":" + seconds.toString().padStart(2, "0");
    }

    function createTimer() {
        if (enteredDurationSeconds <= 0)
            return;
        if (TimerSource.createCountdown(enteredDurationSeconds * 1000, createOnce, "")) {
            durationDigits = "";
            createOnce = true;
            Qt.callLater(() => durationInput.forceActiveFocus());
        }
    }

    onSelectedTabChanged: {
        if (visible && selectedTab === 0)
            Qt.callLater(() => durationInput.forceActiveFocus());
    }
    onVisibleChanged: {
        if (visible && selectedTab === 0)
            Qt.callLater(() => durationInput.forceActiveFocus());
    }

    ColumnLayout {
        anchors {
            fill: parent
            margins: 14
        }
        spacing: 10

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 6

            TabButton {
                label: "Timers"
                selected: root.selectedTab === 0
                onClicked: root.selectedTab = 0
            }

            TabButton {
                label: "Pomodoro"
                selected: root.selectedTab === 1
                onClicked: root.selectedTab = 1
            }

            TabButton {
                label: "Stopwatch"
                selected: root.selectedTab === 2
                onClicked: root.selectedTab = 2
            }
        }

        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: root.selectedTab

            Item {
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        MiniAction {
                            icon: "add"
                            enabled: root.enteredDurationSeconds > 0
                            onClicked: root.createTimer()
                        }

                        Item {
                            Layout.fillWidth: true
                            implicitHeight: 38

                            RowLayout {
                                anchors.fill: parent
                                spacing: 4

                                DurationSegment {
                                    value: root.paddedDurationDigits.slice(0, 2)
                                }

                                StyledText {
                                    color: Theme.overlay0
                                    font.pixelSize: Theme.fontL
                                    text: ":"
                                }

                                DurationSegment {
                                    value: root.paddedDurationDigits.slice(2, 4)
                                }

                                StyledText {
                                    color: Theme.overlay0
                                    font.pixelSize: Theme.fontL
                                    text: ":"
                                }

                                DurationSegment {
                                    value: root.paddedDurationDigits.slice(4, 6)
                                    focused: durationInput.activeFocus
                                }
                            }

                            TextInput {
                                id: durationInput
                                anchors.fill: parent
                                opacity: 0
                                focus: root.visible && root.selectedTab === 0
                                inputMethodHints: Qt.ImhDigitsOnly
                                validator: RegularExpressionValidator { regularExpression: /[0-9]{0,6}/ }
                                text: root.durationDigits

                                onTextEdited: root.durationDigits = text
                                Keys.onReturnPressed: event => {
                                    root.createTimer();
                                    event.accepted = true;
                                }
                                Keys.onEnterPressed: event => {
                                    root.createTimer();
                                    event.accepted = true;
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.IBeamCursor
                                onClicked: durationInput.forceActiveFocus()
                            }
                        }

                        Rectangle {
                            implicitWidth: 24
                            implicitHeight: 24
                            radius: 5
                            color: onceMouse.containsMouse ? Theme.surface1 : Theme.base
                            border.width: 2
                            border.color: root.createOnce ? Theme.accent : Theme.overlay0

                            MaterialSymbol {
                                visible: root.createOnce
                                anchors.fill: parent
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                color: Theme.accent
                                iconSize: 19
                                text: "done"
                            }

                            MouseArea {
                                id: onceMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.createOnce = !root.createOnce;
                                    durationInput.forceActiveFocus();
                                }
                            }
                        }

                        StyledText {
                            color: Theme.text
                            text: "Once"
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: Theme.innerRadius
                        color: Theme.base
                        clip: true

                        StyledText {
                            visible: TimerSource.countdownTimers.length === 0
                            anchors.centerIn: parent
                            color: Theme.overlay0
                            text: "No timers"
                        }

                        ListView {
                            visible: TimerSource.countdownTimers.length > 0
                            anchors {
                                fill: parent
                                margins: 6
                            }
                            spacing: 4
                            clip: true
                            model: TimerSource.countdownTimers

                            delegate: Rectangle {
                                id: timerRow

                                required property var modelData
                                readonly property real remainingMs: TimerSource.countdownRemainingMs(modelData)
                                readonly property bool completed: modelData.state === "completed"
                                readonly property bool showActions: rowHover.hovered && !labelInput.activeFocus

                                width: ListView.view.width
                                height: 54
                                radius: 12
                                color: rowHover.hovered ? Theme.surface0 : "transparent"

                                HoverHandler {
                                    id: rowHover
                                }

                                RowLayout {
                                    anchors {
                                        fill: parent
                                        leftMargin: 6
                                        rightMargin: 8
                                    }
                                    spacing: 8

                                    Item {
                                        implicitWidth: 42
                                        implicitHeight: 42

                                        CircularProgressIcon {
                                            anchors.fill: parent
                                            icon: timerRow.completed ? "done" : timerRow.modelData.state === "running" ? "pause" : "play_arrow"
                                            value: timerRow.completed ? 1 : timerRow.remainingMs / timerRow.modelData.durationMs
                                            color: timerRow.completed ? Theme.peach : Theme.accent
                                            trackColor: Theme.alpha(color, 0.25)
                                            lineWidth: 3
                                            iconSize: 22
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (timerRow.completed)
                                                    TimerSource.acknowledgeCountdown(timerRow.modelData.id);
                                                else
                                                    TimerSource.toggleCountdown(timerRow.modelData.id);
                                            }
                                        }
                                    }

                                    Item {
                                        Layout.fillWidth: true
                                        implicitHeight: 34

                                        StyledText {
                                            visible: timerRow.modelData.label.length === 0 && !labelInput.activeFocus
                                            anchors.fill: parent
                                            verticalAlignment: Text.AlignVCenter
                                            color: Theme.overlay0
                                            elide: Text.ElideRight
                                            text: "Unnamed"
                                        }

                                        TextInput {
                                            id: labelInput
                                            anchors.fill: parent
                                            verticalAlignment: TextInput.AlignVCenter
                                            color: Theme.text
                                            selectionColor: Theme.accent
                                            selectedTextColor: Theme.base
                                            font.family: Theme.font
                                            font.pixelSize: Theme.fontM
                                            maximumLength: 120
                                            text: timerRow.modelData.label

                                            onEditingFinished: {
                                                TimerSource.renameCountdown(timerRow.modelData.id, text);
                                                focus = false;
                                            }
                                        }
                                    }

                                    MiniAction {
                                        visible: timerRow.showActions && (timerRow.modelData.state === "running" || timerRow.modelData.state === "paused")
                                        icon: "restart_alt"
                                        onClicked: TimerSource.restartCountdown(timerRow.modelData.id)
                                    }

                                    MiniAction {
                                        visible: timerRow.showActions
                                        danger: true
                                        icon: "delete"
                                        onClicked: TimerSource.deleteCountdown(timerRow.modelData.id)
                                    }

                                    StyledText {
                                        Layout.preferredWidth: timerRow.modelData.state === "idle" || timerRow.completed ? 52 : 104
                                        horizontalAlignment: Text.AlignRight
                                        color: timerRow.completed ? Theme.peach : Theme.subtext0
                                        font.weight: Theme.weightBold
                                        text: {
                                            if (timerRow.completed)
                                                return "00:00";
                                            if (timerRow.modelData.state === "idle")
                                                return root.formatCountdown(timerRow.modelData.durationMs);
                                            return root.formatCountdown(timerRow.remainingMs) + "/" + root.formatCountdown(timerRow.modelData.durationMs);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Item {
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 10

                    Item { Layout.fillHeight: true }

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        color: Theme.accent
                        font.pixelSize: 15
                        font.weight: Theme.weightBold
                        text: TimerSource.pomodoroPhaseName
                    }

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        color: Theme.text
                        font.pixelSize: 48
                        font.weight: Theme.weightBold
                        text: root.formatPomodoro(TimerSource.pomodoroRemaining)
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.leftMargin: 18
                        Layout.rightMargin: 18
                        implicitHeight: 6
                        radius: height / 2
                        color: Theme.surface0

                        Rectangle {
                            width: parent.width * Math.max(0, Math.min(1, 1 - TimerSource.pomodoroRemaining / TimerSource.pomodoroPhaseDuration))
                            height: parent.height
                            radius: height / 2
                            color: Theme.accent
                        }
                    }

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        color: Theme.overlay0
                        font.pixelSize: Theme.fontS
                        text: TimerSource.completedFocusSessions + " focus sessions completed"
                    }

                    Item { Layout.fillHeight: true }

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 12

                        ActionButton {
                            icon: "restart_alt"
                            onClicked: TimerSource.resetPomodoro()
                        }

                        ActionButton {
                            primary: true
                            icon: TimerSource.pomodoroRunning ? "pause" : "play_arrow"
                            onClicked: TimerSource.togglePomodoro()
                        }

                        ActionButton {
                            icon: "skip_next"
                            onClicked: TimerSource.advancePomodoro()
                        }
                    }

                    Item { Layout.fillHeight: true }
                }
            }

            Item {
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.topMargin: 8
                        color: Theme.text
                        font.pixelSize: 40
                        font.weight: Theme.weightBold
                        text: root.formatStopwatch(TimerSource.stopwatchElapsedMs)
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 12

                        ActionButton {
                            icon: "restart_alt"
                            onClicked: TimerSource.resetStopwatch()
                        }

                        ActionButton {
                            primary: true
                            icon: TimerSource.stopwatchRunning ? "pause" : "play_arrow"
                            onClicked: TimerSource.toggleStopwatch()
                        }

                        ActionButton {
                            icon: "flag"
                            enabled: TimerSource.stopwatchElapsedMs > 0
                            onClicked: TimerSource.addLap()
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.topMargin: 4
                        radius: Theme.innerRadius
                        color: Theme.base
                        clip: true

                        StyledText {
                            visible: TimerSource.stopwatchLaps.length === 0
                            anchors.centerIn: parent
                            color: Theme.overlay0
                            text: "No laps"
                        }

                        ListView {
                            visible: TimerSource.stopwatchLaps.length > 0
                            anchors {
                                fill: parent
                                margins: 8
                            }
                            spacing: 4
                            clip: true
                            model: TimerSource.stopwatchLaps.slice().reverse()

                            delegate: RowLayout {
                                required property int index
                                required property var modelData
                                width: ListView.view.width

                                StyledText {
                                    Layout.fillWidth: true
                                    color: Theme.subtext0
                                    text: "Lap " + (TimerSource.stopwatchLaps.length - index)
                                }

                                StyledText {
                                    color: Theme.text
                                    font.weight: Theme.weightBold
                                    text: root.formatStopwatch(modelData)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    component DurationSegment: Rectangle {
        required property string value
        property bool focused: false

        Layout.fillWidth: true
        implicitHeight: 38
        radius: 8
        color: Theme.base
        border.width: focused ? 2 : 0
        border.color: Theme.accent

        StyledText {
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: parent.focused ? Theme.text : Theme.subtext0
            font.pixelSize: Theme.fontL
            font.weight: Theme.weightBold
            text: parent.value
        }
    }

    component TabButton: Rectangle {
        id: tab

        required property string label
        property bool selected: false
        signal clicked

        implicitWidth: tabLabel.implicitWidth + 24
        implicitHeight: 32
        radius: height / 2
        color: selected ? Theme.alpha(Theme.accent, 0.22) : tabMouse.containsMouse ? Theme.surface0 : "transparent"

        StyledText {
            id: tabLabel
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: tab.selected ? Theme.accent : Theme.subtext0
            font.weight: Theme.weightBold
            text: tab.label
        }

        MouseArea {
            id: tabMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: tab.clicked()
        }
    }

    component MiniAction: Rectangle {
        id: mini

        required property string icon
        property bool danger: false
        signal clicked

        implicitWidth: 30
        implicitHeight: 30
        radius: width / 2
        color: miniMouse.containsMouse ? Theme.surface1 : Theme.surface0
        opacity: enabled ? 1 : 0.35

        MaterialSymbol {
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            iconSize: 18
            color: mini.danger ? Theme.red : Theme.text
            text: mini.icon
        }

        MouseArea {
            id: miniMouse
            anchors.fill: parent
            enabled: mini.enabled
            hoverEnabled: true
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: mini.clicked()
        }
    }

    component ActionButton: Rectangle {
        id: action

        required property string icon
        property bool primary: false
        signal clicked

        implicitWidth: primary ? 48 : 40
        implicitHeight: width
        radius: width / 2
        color: primary ? Theme.accent : actionMouse.containsMouse ? Theme.surface0 : Theme.base
        opacity: enabled ? 1 : 0.4

        MaterialSymbol {
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            iconSize: action.primary ? 26 : 22
            color: action.primary ? Theme.base : Theme.text
            text: action.icon
        }

        MouseArea {
            id: actionMouse
            anchors.fill: parent
            enabled: action.enabled
            hoverEnabled: true
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: action.clicked()
        }
    }
}
