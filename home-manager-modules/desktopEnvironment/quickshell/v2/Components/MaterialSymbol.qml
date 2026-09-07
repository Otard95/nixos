import QtQuick

Text {
    id: root

    property int iconSize: 16
    property bool filled: false

    font.family: materialFont.name
    font.variableAxes: { "FILL": filled ? 1 : 0 }
    font.pixelSize: iconSize
    font.hintingPreference: Font.PreferNoHinting
    renderType: Text.NativeRendering

    FontLoader {
        id: materialFont
        source: "../assets/fonts/MaterialSymbolsRounded.ttf"
    }
}
