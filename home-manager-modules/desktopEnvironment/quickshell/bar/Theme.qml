pragma Singleton

import QtQuick
import Quickshell

Singleton {
    // Catppuccin Frappé palette
    readonly property color rosewater: "#f2d5cf"
    readonly property color flamingo: "#eebebe"
    readonly property color pink: "#f4b8e4"
    readonly property color mauve: "#ca9ee6"
    readonly property color red: "#e78284"
    readonly property color maroon: "#ea999c"
    readonly property color peach: "#ef9f76"
    readonly property color yellow: "#e5c890"
    readonly property color green: "#a6d189"
    readonly property color teal: "#81c8be"
    readonly property color sky: "#99d1db"
    readonly property color sapphire: "#85c1dc"
    readonly property color blue: "#8caaee"
    readonly property color lavender: "#babbf1"
    readonly property color text: "#c6d0f5"
    readonly property color subtext1: "#b5bfe2"
    readonly property color subtext0: "#a5adce"
    readonly property color overlay2: "#949cbb"
    readonly property color overlay1: "#838ba7"
    readonly property color overlay0: "#737994"
    readonly property color surface2: "#626880"
    readonly property color surface1: "#51576d"
    readonly property color surface0: "#414559"
    readonly property color base: "#303446"
    readonly property color mantle: "#292c3c"
    readonly property color crust: "#232634"

    readonly property color accent: teal

    // Typography
    readonly property string font: "Meslo LG M"
    readonly property int fontXs: 9   // captions, labels
    readonly property int fontSm: 11   // secondary values
    readonly property int fontMd: 12   // body text
    readonly property int fontLg: 14   // pill content
    readonly property int fontXl: 16   // popup headings
    readonly property int fontDisplay: 50  // large display
    readonly property int fontDisplaySm: 25  // display secondary

    // Bar geometry
    readonly property int barHeight: 36
    readonly property int barMarginTop: 10
    readonly property int barMarginH: 15
    readonly property int outerRadius: 18
    readonly property int innerRadius: 15
    readonly property real bgAlpha: 1.0
    readonly property int innerSpacing: 10
    readonly property int innerPadH: 10
    readonly property int innerPadV: 0

    function alpha(color, a) {
        return Qt.rgba(color.r, color.g, color.b, a);
    }

    // Should match gtk-icon-theme-name in ~/.config/gtk-3.0/settings.ini
    readonly property string iconTheme: "Papirus-Dark"
    readonly property string iconSize: "32x32"

    function iconPath(name) {
        return "file:///etc/profiles/per-user/otard/share/icons/" + iconTheme + "/" + iconSize + "/apps/" + name + ".svg";
    }
}
