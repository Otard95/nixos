import QtQuick
import QtQuick.Shapes

Item {
    id: root

    property int corner: 0
    property int implicitSize: 25
    property color color: "#000000"

    implicitWidth: implicitSize
    implicitHeight: implicitSize

    property bool isTopLeft: corner === 0
    property bool isTopRight: corner === 1
    property bool isBottomLeft: corner === 2
    property bool isBottomRight: corner === 3
    property bool isTop: isTopLeft || isTopRight
    property bool isBottom: isBottomLeft || isBottomRight
    property bool isLeft: isTopLeft || isBottomLeft
    property bool isRight: isTopRight || isBottomRight

    Shape {
        anchors.fill: parent
        layer.enabled: true
        layer.smooth: true
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            id: shapePath
            strokeWidth: 0
            fillColor: root.color
            pathHints: ShapePath.PathSolid & ShapePath.PathNonIntersecting

            startX: root.isLeft ? 0 : root.implicitSize
            startY: root.isTop ? 0 : root.implicitSize
            PathAngleArc {
                moveToStart: false
                centerX: root.implicitSize - shapePath.startX
                centerY: root.implicitSize - shapePath.startY
                radiusX: root.implicitSize
                radiusY: root.implicitSize
                startAngle: {
                    switch (root.corner) {
                    case 0: return 180
                    case 1: return -90
                    case 2: return 90
                    case 3: return 0
                    }
                }
                sweepAngle: 90
            }
            PathLine { x: shapePath.startX; y: shapePath.startY }
        }
    }
}
