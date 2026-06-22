import qs
import QtQuick
import Quickshell
import Quickshell.Widgets

OuterPill {
    required property var screen

    readonly property var windowInfo: WM.activeWindowByMonitor[screen.name] ?? null

    visible: windowInfo !== null

    Item {
        implicitWidth:  row.implicitWidth + (Theme.innerPadH + 5) * 2
        implicitHeight: Theme.barHeight

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 6

            Image {
                id: appIcon
                anchors.verticalCenter: parent.verticalCenter
                width:  22
                height: 22
                sourceSize.width:  32
                sourceSize.height: 32

                readonly property string iconName: {
                    void DesktopEntries.applications
                    const info = windowInfo
                    if (!info) return ""
                    const entry = DesktopEntries.byId(info.appId)
                        ?? DesktopEntries.heuristicLookup(info.appId)
                    return entry?.icon ?? ""
                }

                // Track whether Papirus has this icon. Reset on each
                // icon change so we retry the preferred source first.
                property bool useFallback: false
                onIconNameChanged: useFallback = false

                source: {
                    if (iconName === "") return ""
                    if (useFallback) return "image://icon/" + iconName
                    return Theme.iconPath(iconName)
                }

                onStatusChanged: {
                    if (status === Image.Error && iconName !== "" && !useFallback)
                        Qt.callLater(() => { useFallback = true })
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.text
                font.family: Theme.font
                font.pixelSize: Theme.fontLg
                text: {
                    const info = windowInfo
                    if (!info) return ""
                    return info.title.length > 30
                        ? info.title.slice(0, 30) + "…"
                        : info.title
                }
            }
        }
    }
}
