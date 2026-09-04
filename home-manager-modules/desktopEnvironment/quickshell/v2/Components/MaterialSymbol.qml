import QtQuick

Text {
    id: root

    property int iconSize: 16

    font.family: materialFont.name
    font.pixelSize: iconSize
    font.hintingPreference: Font.PreferNoHinting
    renderType: Text.NativeRendering

    FontLoader {
        id: materialFont
        source: "../assets/fonts/MaterialIconsRound-Regular.otf"
    }
}
