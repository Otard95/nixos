import qs
import QtQuick

Item {
    id: root

    required property string icon
    required property real value
    property color color: Theme.accent
    property color trackColor: Theme.alpha(color, 0.25)
    property color iconColor: Theme.text
    property real lineWidth: 2.5
    property real inset: 2
    property int iconSize: 13

    implicitWidth: 24
    implicitHeight: 24
    clip: true

    Canvas {
        id: canvas
        anchors.fill: parent

        onPaint: {
            const context = getContext("2d");
            context.reset();
            const centerX = width / 2;
            const centerY = height / 2;
            const radius = Math.min(width, height) / 2 - root.inset;

            context.lineWidth = root.lineWidth;
            context.lineCap = "round";
            context.strokeStyle = root.trackColor;
            context.beginPath();
            context.arc(centerX, centerY, radius, 0, Math.PI * 2);
            context.stroke();

            context.strokeStyle = root.color;
            context.beginPath();
            context.arc(centerX, centerY, radius, -Math.PI / 2,
                -Math.PI / 2 + Math.PI * 2 * Math.max(0, Math.min(1, root.value)));
            context.stroke();
        }

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
    }

    MaterialSymbol {
        anchors.fill: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: root.icon
        iconSize: root.iconSize
        color: root.iconColor
    }

    onValueChanged: canvas.requestPaint()
    onColorChanged: canvas.requestPaint()
    onTrackColorChanged: canvas.requestPaint()
    onLineWidthChanged: canvas.requestPaint()
    onInsetChanged: canvas.requestPaint()
}
