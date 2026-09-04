//@ pragma NativeTextRendering
import Quickshell
import Quickshell.Wayland
import QtQuick
import "Modules"
import "Modules/Notifications"
import "Modules/StatusPanel"

Scope {
    id: root

    NotificationPopupHost {}

    Variants {
        model: Quickshell.screens

        delegate: Component {
            Scope {
                required property var modelData

                StatusPanel {
                    id: statusPanel
                    screen: modelData
                }

                PanelWindow {
                    id: panel // qmllint disable uncreatable-type
                    screen: modelData

                    anchors {
                        top: true
                        left: true
                        right: true
                    }

                    implicitHeight: Theme.barHeight + Theme.outerRadius
                    margins.top: 0
                    exclusiveZone: Theme.barHeight
                    color: "transparent"

                    Component.onCompleted: {
                        if (IdleInhibit.window === null)
                            IdleInhibit.window = panel;
                    }

                    PrimaryBar {
                        anchors.fill: parent
                        screen: modelData
                        panelWindow: panel
                        onToggleStatusPanel: statusPanel.open = !statusPanel.open
                    }
                }
            }
        }
    }
}
