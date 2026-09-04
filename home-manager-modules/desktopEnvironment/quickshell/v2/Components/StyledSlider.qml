import qs
import QtQuick
import QtQuick.Controls

Slider {
    id: root

    enum TrackSize {
        Thin,
        Regular,
        Wide,
        Wavy
    }

    property int trackSize: StyledSlider.Regular
    property list<SliderMarker> markers: []
    property bool animateWave: true
    property real waveAmplitudeMultiplier: 0.5
    property real waveFrequency: 6
    property int waveFps: 30
    property bool smoothPosition: false
    property int positionAnimationDuration: 200
    property int positionAnimationEasing: Easing.Linear

    property color fillColor: Theme.accent
    property color trackColor: Theme.surface0
    property color handleColor: Theme.accent
    property color filledContentColor: Theme.base
    property color unfilledContentColor: Theme.text

    property real handleDefaultWidth: 3
    property real handlePressedWidth: 1.5
    property real handleMargin: 4
    property real dividerMargin: 2
    property real stopIndicatorSize: 3
    property real markerIconSize: 20
    property real markerIconGap: 8
    property var tooltipFormatter: function (sliderValue) {
        if (root.to === root.from)
            return "0%";
        return Math.round((sliderValue - root.from) / (root.to - root.from) * 100) + "%";
    }

    readonly property bool wavy: trackSize === StyledSlider.Wavy
    readonly property real targetTrackHeight: wavy ? 4 : trackSize === StyledSlider.Thin ? 12 : trackSize === StyledSlider.Wide ? 30 : 18
    property real trackHeight: targetTrackHeight
    property real handleHeight: Math.max(33, targetTrackHeight + 9)
    property real waveMix: wavy ? 1 : 0
    readonly property real trackRadius: trackHeight >= 30 ? 9 : trackHeight >= 18 ? 6 : trackHeight / 2
    readonly property real waveLineWidth: 4
    readonly property real waveHeight: waveLineWidth * (1 + 2 * waveAmplitudeMultiplier)
    readonly property real currentHandleWidth: pressed ? handlePressedWidth : handleDefaultWidth
    readonly property real effectiveTrackWidth: width - leftPadding - rightPadding
    property real renderedPosition: visualPosition
    readonly property string tooltipText: String(tooltipFormatter(value))

    readonly property var trackSegments: {
        const handleGap = root.handleMargin + root.currentHandleWidth / 2;
        const points = [
            {
                position: 0,
                gap: 0,
                edge: true
            }
        ];

        for (const marker of root.markers) {
            if (!marker.divider)
                continue;
            const position = root.normalizedValue(marker.value);
            if (position <= 0 || position >= 1)
                continue;
            if (Math.abs(position - root.renderedPosition) * root.effectiveTrackWidth <= handleGap + root.dividerMargin)
                continue;
            points.push({
                position: position,
                gap: root.dividerMargin,
                edge: false
            });
        }

        points.push({
            position: root.renderedPosition,
            gap: handleGap,
            edge: false
        });
        points.push({
            position: 1,
            gap: 0,
            edge: true
        });
        points.sort((a, b) => a.position - b.position || Number(b.edge) - Number(a.edge));

        const segments = [];
        for (let index = 0; index < points.length - 1; index++) {
            const left = points[index];
            const right = points[index + 1];
            const start = root.leftPadding + left.position * root.effectiveTrackWidth + left.gap;
            const end = root.leftPadding + right.position * root.effectiveTrackWidth - right.gap;
            if (end <= start)
                continue;
            segments.push({
                x: start,
                width: end - start,
                filled: (left.position + right.position) / 2 < root.renderedPosition,
                first: left.position === 0,
                last: right.position === 1
            });
        }
        return segments;
    }

    function normalizedValue(markerValue) {
        if (to === from)
            return 0;
        return Math.max(0, Math.min(1, (markerValue - from) / (to - from)));
    }

    function centerForValue(markerValue) {
        return leftPadding + normalizedValue(markerValue) * effectiveTrackWidth;
    }

    leftPadding: handleMargin
    rightPadding: handleMargin
    implicitWidth: 180
    implicitHeight: Math.max(33, handleHeight)

    Behavior on trackHeight {
        NumberAnimation {
            duration: 180
            easing.type: Easing.OutCubic
        }
    }

    Behavior on handleHeight {
        NumberAnimation {
            duration: 180
            easing.type: Easing.OutCubic
        }
    }

    Behavior on waveMix {
        NumberAnimation {
            duration: 140
        }
    }

    Behavior on renderedPosition {
        enabled: root.smoothPosition && !root.pressed
        NumberAnimation {
            duration: root.positionAnimationDuration
            easing.type: root.positionAnimationEasing
        }
    }

    background: Item {
        id: track

        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        implicitHeight: root.trackHeight
        height: root.trackHeight

        Repeater {
            model: root.trackSegments

            Item {
                required property var modelData

                x: modelData.x
                width: modelData.width
                height: Math.max(root.trackHeight, root.waveHeight)
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    height: root.trackHeight
                    opacity: parent.modelData.filled ? 1 - root.waveMix : 1
                    topLeftRadius: parent.modelData.first ? root.trackRadius : 2
                    bottomLeftRadius: parent.modelData.first ? root.trackRadius : 2
                    topRightRadius: parent.modelData.last ? root.trackRadius : 2
                    bottomRightRadius: parent.modelData.last ? root.trackRadius : 2
                    color: parent.modelData.filled ? root.fillColor : root.trackColor
                }
            }
        }

        Item {
            visible: root.waveMix > 0
            anchors.verticalCenter: parent.verticalCenter
            x: root.leftPadding
            width: Math.max(0, root.renderedPosition * root.effectiveTrackWidth - root.handleMargin - root.currentHandleWidth / 2)
            height: root.waveHeight
            opacity: root.waveMix
            clip: true

            WavyLine {
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
                width: root.effectiveTrackWidth
                height: root.waveHeight
                color: root.fillColor
                lineWidth: root.waveLineWidth
                amplitudeMultiplier: root.waveAmplitudeMultiplier
                frequency: root.waveFrequency
                fullLength: root.effectiveTrackWidth
                animated: root.animateWave
                animationFps: root.waveFps
            }
        }

        Repeater {
            model: root.markers

            Rectangle {
                required property SliderMarker modelData

                visible: modelData.stopIndicator
                anchors.verticalCenter: parent.verticalCenter
                x: root.centerForValue(modelData.value) - width / 2
                width: root.stopIndicatorSize
                height: width
                radius: width / 2
                color: root.normalizedValue(modelData.value) <= root.renderedPosition ? root.filledContentColor : root.unfilledContentColor
            }
        }

        Repeater {
            model: root.markers

            Item {
                required property SliderMarker modelData

                readonly property real markerPosition: root.normalizedValue(modelData.value)
                readonly property real centeredX: root.centerForValue(modelData.value) - width / 2
                readonly property real dividerX: markerPosition < 0.1 ? root.centerForValue(modelData.value) + root.markerIconGap : root.centerForValue(modelData.value) - width - root.markerIconGap
                readonly property real desiredX: modelData.divider ? dividerX : centeredX
                readonly property real activeTrackEdge: root.leftPadding + root.renderedPosition * root.effectiveTrackWidth - root.handleMargin - root.currentHandleWidth / 2
                readonly property real activeWidth: Math.max(0, Math.min(width, activeTrackEdge - x))

                visible: modelData.icon !== ""
                anchors.verticalCenter: parent.verticalCenter
                width: root.markerIconSize
                height: width
                x: Math.max(root.leftPadding + 4, Math.min(root.width - root.rightPadding - width - 4, desiredX))

                MaterialSymbol {
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    iconSize: root.markerIconSize
                    color: root.unfilledContentColor
                    text: modelData.icon
                }

                Item {
                    anchors {
                        left: parent.left
                        top: parent.top
                        bottom: parent.bottom
                    }
                    width: parent.activeWidth
                    clip: true

                    MaterialSymbol {
                        width: parent.parent.width
                        height: parent.parent.height
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        iconSize: root.markerIconSize
                        color: root.filledContentColor
                        text: modelData.icon
                    }
                }
            }
        }
    }

    handle: Rectangle {
        id: sliderHandle

        implicitWidth: root.currentHandleWidth
        implicitHeight: root.handleHeight
        x: root.leftPadding + root.renderedPosition * root.effectiveTrackWidth - width / 2
        anchors.verticalCenter: parent.verticalCenter
        radius: width / 2
        color: root.handleColor

        Behavior on implicitWidth {
            NumberAnimation {
                duration: 100
            }
        }

        Rectangle {
            visible: root.pressed
            anchors.horizontalCenter: parent.horizontalCenter
            y: -height - 7
            width: tooltipLabel.implicitWidth + 12
            height: 24
            radius: height / 2
            color: Theme.surface0

            StyledText {
                id: tooltipLabel
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: Theme.text
                font.pixelSize: Theme.fontS
                text: root.tooltipText
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        cursorShape: root.pressed ? Qt.ClosedHandCursor : Qt.PointingHandCursor
    }
}
