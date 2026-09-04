import qs
import QtQuick
import Quickshell
import Quickshell.Widgets
import "../../../Components"

Rectangle {
    id: root

    required property string appIcon
    required property string image
    required property int urgency
    property string appName: ""
    property string category: ""

    // The first icon name that actually exists in the theme, or "".
    readonly property string resolvedIcon: {
        if (appIcon !== "") {
            const path = Quickshell.iconPath(appIcon, true)
            if (path !== "")
                return path
        }
        if (appName !== "") {
            const path = Quickshell.iconPath(appName, true)
            if (path !== "")
                return path
        }
        return ""
    }

    // Freedesktop notification categories mapped to Material Symbol slugs.
    // Matched by exact category or by a type prefix before a dot.
    readonly property var categoryIcons: ({
        "email": "mail",
        "im": "chat",
        "call": "call",
        "network": "wifi",
        "device": "devices",
        "transfer": "swap_vert",
        "presence": "person",
        "mount": "usb",
        "system": "settings",
        "security": "security",
        "update": "system_update",
        "weather": "cloud",
        "quickshell.timer": "timer"
    })

    readonly property string categoryIcon: categorySymbol(category)

    function categorySymbol(value: string): string {
        if (value === "")
            return ""
        if (categoryIcons[value] !== undefined)
            return categoryIcons[value]
        for (const key in categoryIcons) {
            if (value === key || value.startsWith(key + "."))
                return categoryIcons[key]
        }
        return ""
    }

    implicitWidth: 38
    implicitHeight: 38
    radius: 12
    color: urgency === 2 ? Theme.alpha(Theme.red, 0.25) : Theme.surface0
    clip: true

    Image {
        visible: root.image !== ""
        anchors.fill: parent
        source: root.image
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }

    Loader {
        active: root.image === "" && root.resolvedIcon !== ""
        anchors.centerIn: parent

        sourceComponent: IconImage {
            implicitSize: 28
            source: root.resolvedIcon
            asynchronous: true
        }
    }

    MaterialSymbol {
        visible: root.image === "" && root.resolvedIcon === ""
        anchors.fill: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        iconSize: 21
        color: root.urgency === 2 ? Theme.red : Theme.text
        text: root.categoryIcon !== ""
            ? root.categoryIcon
            : (root.urgency === 2 ? "priority_high" : "notifications")
    }
}
