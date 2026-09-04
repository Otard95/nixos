import qs
import QtQuick
import Quickshell
import Quickshell.Widgets

Item {
    id: root

    required property var screen

    readonly property var workspaces: WM.workspacesByMonitor[screen.name] ?? []

    implicitWidth: workspaceRow.implicitWidth
    implicitHeight: Theme.barHeight

    Row {
        id: workspaceRow
        anchors.centerIn: parent
        spacing: 2
        leftPadding: 2
        rightPadding: 2

        Repeater {
            model: root.workspaces

            delegate: Item {
                id: workspaceButton

                required property var modelData
                required property int index

                readonly property var appIds: modelData.appIds

                implicitWidth: Math.max(26, appIcons.implicitWidth + 8)
                implicitHeight: Theme.barHeight

                Rectangle {
                    anchors.centerIn: parent
                    width: Math.max(height, appIcons.implicitWidth + 4)
                    height: 26
                    radius: height / 2
                    color: Theme.alpha(Theme.accent, 0.15)
                    visible: !workspaceButton.modelData.active && workspaceButton.appIds.length > 0
                    z: -1
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: Math.max(height, appIcons.implicitWidth + 4)
                    height: 26
                    radius: height / 2
                    color: Theme.accent
                    opacity: workspaceButton.modelData.active ? 1 : 0
                    z: -1

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 140
                        }
                    }
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: 5
                    height: width
                    radius: width / 2
                    color: Theme.subtext0
                    visible: workspaceButton.appIds.length === 0
                }

                Row {
                    id: appIcons
                    anchors.centerIn: parent
                    leftPadding: 2.5
                    rightPadding: 2.5
                    spacing: 6

                    Repeater {
                        model: workspaceButton.appIds

                        delegate: Image {
                            required property string modelData

                            width: 18
                            height: width
                            sourceSize.width: 32
                            sourceSize.height: 32
                            visible: iconName !== ""

                            readonly property string iconName: {
                                void DesktopEntries.applications;
                                const entry = DesktopEntries.byId(modelData) ?? DesktopEntries.heuristicLookup(modelData);
                                return entry?.icon ?? "";
                            }

                            property bool useFallback: false
                            onIconNameChanged: useFallback = false

                            source: {
                                if (iconName === "")
                                    return "";
                                if (useFallback)
                                    return "image://icon/" + iconName;
                                return Theme.iconPath(iconName);
                            }

                            onStatusChanged: {
                                if (status === Image.Error && iconName !== "" && !useFallback)
                                    Qt.callLater(() => {
                                        useFallback = true;
                                    });
                            }
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: workspaceButton.modelData.activate()
                }
            }
        }
    }
}
