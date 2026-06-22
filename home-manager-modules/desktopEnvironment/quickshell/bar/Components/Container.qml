import QtQuick

Item {
    id: root
    property real margin: 5
    default required property Item child

    children: [child]

    implicitWidth: child.implicitWidth + margin * 2
    implicitHeight: child.implicitHeight + margin * 2

    Binding {
        root.child.x: root.margin
    }
    Binding {
        root.child.y: root.margin
    }
    Binding {
        root.child.width: root.width - root.margin * 2
    }
    Binding {
        root.child.height: root.height - root.margin * 2
    }
}
