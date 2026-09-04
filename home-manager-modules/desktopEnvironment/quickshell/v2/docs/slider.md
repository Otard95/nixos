# StyledSlider

`StyledSlider` is the reusable presentation and interaction primitive for the
status panel. This document is the canonical reference for its design, API, and
current integrations.

## Upstream model

The three inspected Material-style examples all use upstream's shared
`modules/common/widgets/StyledSlider.qml`. They are not separate theme variants.
The Waffle panel family has a different Windows-style component at
`modules/waffle/looks/WSlider.qml`, which is outside the scope of this port.

| Example | Track configuration | Extra behavior |
|---|---:|---|
| Brightness | `M` = 30px | Icons inside track, divider at 30%, optional stop marker |
| Font weight | `XS` = 12px | Stop marker at weight 350, endpoint marker |
| Application volume | `S` = 18px | Endpoint marker; application icon outside slider |

Upstream's configuration enum values are the actual track heights:

```qml
enum Configuration {
    Wavy = 4
    XS = 12
    S = 18
    M = 30
    L = 42
    XL = 72
}
```

The thin vertical line is the handle. It is normally 3px wide and narrows while
pressed.

### Upstream marker concepts

Upstream exposes two lists of values in the slider's `from`–`to` range:

- `stopIndicatorValues`: dots drawn on the track
- `dividerValues`: gaps that split the filled and unfilled track

Both are visual only. They do not snap, clamp, or prevent the handle from
crossing them. Standard Qt `Slider.stepSize` and `snapMode` remain responsible
for ordinary step snapping.

The brightness icons are not part of upstream's base `StyledSlider`. Its
sidebar-specific `QuickSlider` wrapper overlays Material icons and supplies a
divider at the secondary icon's position.

## Local architecture

The local implementation keeps one reusable Qt `Slider` core and replaces the
two numeric marker lists with typed marker objects:

- `Components/StyledSlider.qml`
- `Components/SliderMarker.qml`
- `Components/WavyLine.qml`
- `Modules/StatusPanel/QuickSliders.qml` and `Modules/StatusPanel/Widgets/Media.qml`
  for real integrations

Backend state and writes remain in `Sources/`; the reusable components contain
only presentation and interaction behavior.

## `SliderMarker`

```qml
QtObject {
    required property real value
    property bool divider: false
    property bool stopIndicator: false
    property string icon: ""
}
```

`value` uses the parent slider's actual numeric range, not a mandatory 0–1
normalized range. A marker may combine roles:

```qml
SliderMarker {
    value: 350
    divider: true
    stopIndicator: true
}
```

Typed QML objects were chosen instead of JavaScript dictionaries because they
provide property type checking, required-property validation, reactive
bindings, change notifications, and better tooling. The object overhead is
irrelevant for the small marker lists used by sliders.

Markers are visual only. Arbitrary magnetic snapping or hard barriers are not
implemented.

## `StyledSlider`

`StyledSlider` inherits `QtQuick.Controls.Slider`, retaining its standard API:

- `from`, `to`, `value`
- `stepSize`, `snapMode`, `live`
- `pressed`, `position`, `visualPosition`
- `moved()`

### Track sizes

The local component provides four track styles:

```qml
enum TrackSize {
    Thin     // 12px
    Regular  // 18px
    Wide     // 30px
    Wavy     // animated 4px line
}
```

The computed `trackHeight` remains readable for geometry and wrappers. Wavy is
opt-in and preserves the slider's 33px layout and handle height, so switching
between Thin and Wavy does not move surrounding content.

### Public customization

The component currently exposes:

```qml
property int trackSize
property list<SliderMarker> markers

property color fillColor
property color trackColor
property color handleColor
property color filledContentColor
property color unfilledContentColor

property real handleDefaultWidth
property real handlePressedWidth
property real handleMargin
property real dividerMargin
property real stopIndicatorSize
property real markerIconSize
property real markerIconGap
property var tooltipFormatter
property bool animateWave
property real waveAmplitudeMultiplier
property real waveFrequency
property int waveFps
property bool smoothPosition
property int positionAnimationDuration
property int positionAnimationEasing
```

It also provides helpers for wrappers and marker positioning:

```qml
normalizedValue(value)
centerForValue(value)
```

### Track rendering

The track is rendered as a set of rounded rectangle segments. Segment
boundaries are derived from:

1. the beginning of the range,
2. every enabled divider marker,
3. the current handle position,
4. the end of the range.

Small margins around dividers create visible breaks. A wider margin around the
handle separates the filled and unfilled tracks from the vertical handle.
Dividers too close to the handle are temporarily filtered to avoid overlapping
gaps.

The logical position comes from Qt's right-to-left-aware `visualPosition`.
Rendering uses `renderedPosition`, which normally follows it immediately and
can optionally interpolate external updates.

### External-position smoothing

`smoothPosition` is disabled by default. When enabled, the component animates
only `renderedPosition`; `value`, seeking, `moved()`, and tooltip values stay
immediate and correct. The animation is disabled while pressed, so the handle
never lags behind a drag.

```qml
smoothPosition: true
positionAnimationDuration: 1000
positionAnimationEasing: Easing.Linear
```

This is useful when a backend publishes discrete progress updates. Consumers
own domain-specific timing policy; the base slider does not infer track changes,
backward seeks, or other semantic events.

### Handle and tooltip

The handle is a vertical rounded rectangle:

- default width: 3px
- pressed width: 1.5px
- height: at least 33px, or `trackHeight + 9px`

A tooltip appears while pressed. The default formatter displays a percentage:

```qml
tooltipFormatter: value =>
    Math.round((value - from) / (to - from) * 100) + "%"
```

Consumers can replace the formatter for values such as font weight.

### Stop indicators

A marker with `stopIndicator: true` renders a small dot centered at its value.
Its color switches according to whether it lies in the filled or unfilled
portion of the track.

```qml
SliderMarker {
    value: 0.3
    stopIndicator: true
}
```

### Divider markers

A marker with `divider: true` creates a real break in the track:

```qml
SliderMarker {
    value: 0.6
    divider: true
}
```

The handle can pass through the divider normally.

### Icon markers

A marker with an icon renders a Material icon on the track:

```qml
SliderMarker {
    value: 1
    icon: "light_mode"
}
```

Positioning rules:

- Icon-only markers are centered at their value and clamped inside the track.
- An icon-bearing divider places its icon to the left of the divider.
- If the divider is below 10%, the icon is placed to its right to avoid the
  beginning of the track.
- The default divider-to-icon gap is 8px.

Material ligature names must be verified against the local static font at
`assets/fonts/MaterialIconsRound-Regular.otf`; upstream uses a larger Material
Symbols font with a different icon set.

### Progressive icon coloring

Track icons do not switch color abruptly when the handle crosses them. Each
icon is rendered twice at exactly the same position:

1. a full copy using `unfilledContentColor`,
2. a second copy using `filledContentColor` above it.

The filled-color copy is clipped at the active track's moving edge. As the fill
passes through the glyph, the icon becomes spatially split between the two
colors and transitions continuously without graphical effects or masks.

## Current real integration

`Modules/StatusPanel/QuickSliders.qml` contains two real controls.

### Brightness

```qml
StyledSlider {
    trackSize: StyledSlider.Wide
    value: BrightnessSource.percent / 100
    onMoved: BrightnessSource.setPercent(value * 100)

    markers: [
        SliderMarker {
            value: 0.3
            divider: true
            icon: "wb_twilight"
        },
        SliderMarker {
            value: 1
            icon: "light_mode"
        }
    ]
}
```

The 30% divider and `wb_twilight` icon mirror the visual structure of the
upstream brightness slider. Unlike upstream, the local slider currently
controls hardware brightness only because `hyprsunset` is unavailable.

Rapid brightness drag updates are coalesced in `Sources/Brightness.qml`, so the
last requested value is not lost while a previous `brightnessctl` process is
still running.

### Sink volume

```qml
StyledSlider {
    trackSize: StyledSlider.Wide
    value: VolumeSource.sinkVolume
    onMoved: VolumeSource.setSinkVolume(value)

    markers: [
        SliderMarker {
            value: 0.75
            divider: true
            icon: "hearing"
        },
        SliderMarker {
            value: 1
            icon: VolumeSource.sinkMuted ? "volume_off" : "volume_up"
        }
    ]
}
```

The 75% divider exercises icon-bearing dividers. The end icon reflects sink
mute state.

## Wavy media integration

The Media timeline switches between `Thin` while paused and `Wavy` while
playing. Track height and fill opacity animate during the transition while the
slider and handle retain a stable layout height.

`MediaSource` refreshes MPRIS position once per second. The page uses seconds,
rather than a normalized range, so seeking and its `m:ss`/`h:mm:ss` tooltip share
the player's native units:

```qml
StyledSlider {
    trackSize: player?.isPlaying ? StyledSlider.Wavy : StyledSlider.Thin
    from: 0
    to: Math.max(player?.length ?? 0, 1)
    value: player?.position ?? 0
    enabled: (player?.canSeek ?? false) && (player?.positionSupported ?? false)
    tooltipFormatter: formatTime
    onMoved: {
        if (player?.canSeek && player?.positionSupported)
            player.position = value
    }
}
```

It opts into a 1000ms linear `renderedPosition` transition so those updates
appear continuous. It temporarily uses 150ms when MPRIS emits `trackChanged()`
or the active player changes. That policy belongs to the media page, not the
reusable slider.

The page keeps its timeline visible even while MPRIS temporarily lacks position
or length metadata during a transition: labels fall back to `0:00`, the track
rests at zero, and seeking is disabled. This prevents layout movement.

The wave uses one persistent `WavyLine` Canvas at 30fps. Progress changes resize
a clipping item over that full-width Canvas rather than rebuilding the Canvas,
which avoids blinking on the MPRIS refresh. Animation stops when the Media page
is hidden or playback is paused.

## Future reuse

The same core can support:

- thin configuration sliders with labels,
- regular per-application PipeWire volume sliders,
- wide quick sliders with embedded icons.

Context-specific wrappers should own labels, external application icons,
backend bindings, and domain-specific behavior. The base component should not
absorb Waffle styling, service calls, application lookup, or brightness policy.

Not currently ported:

- arbitrary marker delegates,
- arbitrary-value magnetic snapping,
- hard barriers or inaccessible ranges,
- upstream's full animation and tooltip infrastructure.
