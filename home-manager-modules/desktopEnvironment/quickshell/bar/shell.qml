import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

Scope {
    id: root

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panel // qmllint disable uncreatable-type
            required property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: Theme.barHeight
            // Push the surface 10px from the top edge, then reserve the
            // combined height so windows start below the gap + bar.
            margins.top: Theme.barMarginTop
            exclusiveZone: Theme.barHeight + Theme.barMarginTop
            color: "transparent"

            Component.onCompleted: {
                if (IdleInhibit.window === null)
                    IdleInhibit.window = panel
            }

            RowLayout {
                anchors {
                    fill: parent
                    leftMargin: Theme.barMarginH
                    rightMargin: Theme.barMarginH
                }
                spacing: 0

                // ── Left ──────────────────────────────────────────────────
                Row {
                    spacing: Theme.innerSpacing
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

                    Workspaces {
                        screen: modelData
                    }
                    ActiveWindow {
                        screen: modelData
                    }
                    Mode {
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // ── Spacer ────────────────────────────────────────────────
                Item {
                    Layout.fillWidth: true
                }

                // ── Right ─────────────────────────────────────────────────
                OuterPill {
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

                    Item {
                        implicitWidth: rightRow.implicitWidth + 8
                        implicitHeight: Theme.barHeight

                        Row {
                            id: rightRow
                            anchors.centerIn: parent
                            spacing: Theme.innerSpacing

                            Network {
                                panelWindow: panel
                            }
                            Volume {}
                            Brightness {}
                            KeyboardLayout {}
                            Battery {}
                            Misc {}
                            Clock {
                                panelWindow: panel
                            }
                            PowerMenu {
                                panelWindow: panel
                            }
                        }
                    }
                }
            }
        }
    }
}
