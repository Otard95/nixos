import qs
import QtQuick
import "../../Components"

MaterialSymbol {
    text: NetworkSource.icon
    iconSize: Theme.fontL
    color: {
        if (!NetworkSource.available)
            return Theme.red;
        if (!NetworkSource.isWifi)
            return Theme.withLightness(Theme.accent, 0.9);
        const s = NetworkSource.signalStrength;
        return s < 0.25 ? Theme.red : s < 0.50 ? Theme.peach : Theme.withLightness(Theme.accent, 0.9);
    }
}
