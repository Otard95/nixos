import qs
import Quickshell.Services.UPower

QuickToggle {
    visible: PowerProfileSource.available
    span: 2
    label: "Power profile"
    status: {
        switch (PowerProfileSource.profile) {
        case PowerProfile.PowerSaver:
            return "Power saver"
        case PowerProfile.Performance:
            return "Performance"
        default:
            return "Balanced"
        }
    }
    icon: {
        switch (PowerProfileSource.profile) {
        case PowerProfile.PowerSaver:
            return "energy_savings_leaf"
        case PowerProfile.Performance:
            return "speed"
        default:
            return "balance"
        }
    }
    shapeOn: PowerProfileSource.profile !== PowerProfile.Balanced
    onTriggered: PowerProfileSource.cycle()
}
