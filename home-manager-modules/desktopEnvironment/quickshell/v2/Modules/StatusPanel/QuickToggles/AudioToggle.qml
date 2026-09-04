import qs

QuickToggle {
    span: 2
    label: "Audio"
    status: VolumeSource.sinkMuted ? "Muted" : VolumeSource.sinkPercent + "%"
    icon: VolumeSource.sinkMuted ? "volume_off" : "volume_up"
    shapeOn: !VolumeSource.sinkMuted
    onTriggered: VolumeSource.toggleSinkMute()
}
