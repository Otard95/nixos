import QtQuick

Canvas {
    id: root

    property real amplitudeMultiplier: 0.5
    property real frequency: 6
    property color color: "white"
    property real lineWidth: 4
    property real fullLength: width
    property real horizontalOffset: 0
    property bool animated: true
    property int animationFps: 30

    onAmplitudeMultiplierChanged: requestPaint()
    onFrequencyChanged: requestPaint()
    onColorChanged: requestPaint()
    onLineWidthChanged: requestPaint()
    onFullLengthChanged: requestPaint()
    onHorizontalOffsetChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    onPaint: {
        const context = getContext("2d");
        const amplitude = root.lineWidth * root.amplitudeMultiplier;
        const phase = root.animated ? Date.now() / 400 : 0;
        const usableLength = Math.max(1, root.fullLength);
        const centerY = height / 2;

        context.clearRect(0, 0, width, height);
        context.strokeStyle = root.color;
        context.lineWidth = root.lineWidth;
        context.lineCap = "round";
        context.beginPath();

        for (let x = root.lineWidth / 2; x <= width - root.lineWidth / 2; x++) {
            const waveX = x + root.horizontalOffset;
            const waveY = centerY + amplitude * Math.sin(root.frequency * 2 * Math.PI * waveX / usableLength + phase);
            if (x === root.lineWidth / 2)
                context.moveTo(x, waveY);
            else
                context.lineTo(x, waveY);
        }
        context.stroke();
    }

    Timer {
        running: root.animated && root.visible && root.width > 0
        interval: Math.max(16, Math.round(1000 / root.animationFps))
        repeat: true
        onTriggered: root.requestPaint()
    }
}
