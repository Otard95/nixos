import qs

QuickToggle {
    label: "Microphone"
    icon: VolumeSource.sourceMuted ? "mic_off" : "mic"
    shapeOn: !VolumeSource.sourceMuted
    onTriggered: VolumeSource.toggleSourceMute()
}
