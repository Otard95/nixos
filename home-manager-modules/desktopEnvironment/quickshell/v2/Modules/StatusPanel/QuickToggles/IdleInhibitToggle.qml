import qs

QuickToggle {
    label: "Idle inhibit"
    icon: "coffee"
    shapeOn: IdleInhibit.active
    onTriggered: IdleInhibit.toggle()
}
