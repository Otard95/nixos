import qs
import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../../Components"
import "../../../Sources/Notifications" as NotificationTypes

Rectangle {
    id: root

    required property NotificationTypes.NotificationEntry notification
    property bool expanded: false
    property bool compact: false
    property bool showSummary: true
    property bool showImage: false
    property bool preview: false
    property bool animationReady: false

    readonly property real dismissThreshold: 70
    readonly property real detachThreshold: 100
    readonly property real dismissOvershoot: 20
    readonly property real attractionStrength: 32
    readonly property int dragSmoothingDuration: 50
    property real swipeOffset: 0
    property real dragOffset: 0
    property real chainOffset: 0
    property bool dragging: false
    property bool passedThreshold: false
    readonly property bool hovered: !compact && !preview && hoverHandler.hovered
    readonly property string plainBody: notification === null
        ? ""
        : plainText(notification.body)
    readonly property NotificationTypes.NotificationActionEntry primaryAction:
        notification !== null && notification.actions.length === 1
            && isPrimaryAction(notification.actions[0])
                ? notification.actions[0]
                : null
    readonly property bool hasPrimaryAction: primaryAction !== null

    // Instant, non-animated final height. The group card animates its own
    // visual height and reveals this content via clip; the item itself does not
    // animate its layout height, so a group's settled height is exact and
    // immediate the moment its expanded state flips.
    implicitHeight: compact ? summaryRow.implicitHeight : content.implicitHeight + 16
    radius: 12
    color: hovered ? Theme.alpha(Theme.accent, 0.18) : "transparent"
    transform: Translate { x: root.dragOffset + root.chainOffset }

    Behavior on chainOffset {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    Behavior on dragOffset {
        enabled: !dismissAnimation.running
        NumberAnimation {
            duration: root.dragging ? root.dragSmoothingDuration : 200
            easing.type: Easing.OutCubic
        }
    }

    NumberAnimation {
        id: dismissAnimation
        target: root
        property: "dragOffset"
        duration: 200
        easing.type: Easing.OutCubic
        onFinished: {
            if (root.notification !== null)
                Notifications.dismiss(root.notification.notificationId)
        }
    }

    DragHandler {
        enabled: !root.compact && !dismissAnimation.running
        target: null
        xAxis.enabled: true
        yAxis.enabled: false
        onActiveChanged: {
            if (active)
                root.beginSwipe()
            else
                root.finishSwipe()
        }
        onTranslationChanged: {
            if (active)
                root.setSwipeOffset(translation.x)
        }
    }

    function beginSwipe(): void {
        gestureEndTimer.stop()
        root.dragging = true
    }

    function applySwipeDelta(delta: real): void {
        if (dismissAnimation.running)
            return
        root.beginSwipe()
        root.setSwipeOffset(root.swipeOffset + delta)
        gestureEndTimer.restart()
    }

    function setSwipeOffset(offset: real): void {
        root.swipeOffset = offset
        const distance = Math.abs(offset)
        if (!root.passedThreshold && distance >= root.detachThreshold)
            root.passedThreshold = true
        else if (root.passedThreshold && distance <= root.dismissThreshold)
            root.passedThreshold = false
        root.dragOffset = root.passedThreshold ? offset : root.visualOffset(offset)
    }

    // A static curve gives spring-like resistance without time-dependent state.
    function visualOffset(offset: real): real {
        const distance = Math.abs(offset)
        const direction = offset < 0 ? -1 : 1
        const attraction = root.attractionStrength
            * (1 - Math.exp(-distance / root.attractionStrength))
        return direction * Math.max(0, distance - attraction)
    }

    function finishSwipe(): void {
        root.dragging = false
        if (root.passedThreshold) {
            root.commitDismiss()
        } else {
            root.swipeOffset = 0
            root.dragOffset = 0
        }
    }

    Timer {
        id: gestureEndTimer
        interval: 100
        onTriggered: root.finishSwipe()
    }

    function commitDismiss(): void {
        gestureEndTimer.stop()
        const dir = root.swipeOffset < 0 ? -1 : 1
        dismissAnimation.to = dir * (root.width + root.dismissOvershoot)
        dismissAnimation.start()
    }

    HoverHandler {
        id: hoverHandler
        enabled: !root.compact && !root.preview
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.hasPrimaryAction
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (root.notification !== null) {
                Notifications.invokeAction(root.notification.notificationId,
                    root.primaryAction.identifier)
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.MiddleButton
        onClicked: {
            if (root.notification !== null)
                Notifications.dismiss(root.notification.notificationId)
        }
    }

    RowLayout {
        id: content
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: root.compact ? 0 : 8
        }

        spacing: 8

        ColumnLayout {
            id: textColumn
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            spacing: 3

        RowLayout {
            id: summaryRow

            Layout.fillWidth: true
            spacing: 6

            StyledText {
                visible: root.showSummary
                Layout.fillWidth: !root.compact
                // Bind the compact cap to the item's own width, not
                // summaryRow.width. summaryRow is the layout being arranged, so
                // reading its width here makes the rearrange recursive; Qt then
                // aborts it mid-pass and leaves the row's items overlapping.
                Layout.maximumWidth: root.compact
                    ? root.width * 0.6
                    : Number.POSITIVE_INFINITY
                color: Theme.text
                font.weight: Theme.weightBold
                elide: Text.ElideRight
                text: root.notification?.summary ?? ""
            }

            StyledText {
                visible: root.compact && (root.notification?.body ?? "") !== ""
                opacity: visible ? 1 : 0
                Layout.fillWidth: true

                Behavior on opacity {
                    enabled: root.animationReady
                    NumberAnimation { duration: 120 }
                }
                Layout.rightMargin: root.compact ? 8 : 0
                color: Theme.subtext0
                elide: Text.ElideRight
                text: root.plainBody.replace(/\n+/g, " ")
                textFormat: Text.PlainText
                maximumLineCount: 1
            }

            Item {
                visible: !root.compact
                    && (root.notification?.body ?? "") !== ""
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                opacity: root.hovered ? 1 : 0

                MaterialSymbol {
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    iconSize: 17
                    color: Theme.subtext0
                    text: copyTimer.running ? "check" : "content_copy"
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: root.hovered
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Quickshell.clipboardText = root.plainBody
                        copyTimer.restart()
                    }
                }

                Timer {
                    id: copyTimer
                    interval: 1200
                }
            }

            MaterialSymbol {
                visible: root.expanded
                    && (root.notification?.dismissible ?? false)
                text: "close"
                iconSize: 17
                color: Theme.subtext0

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.notification !== null)
                            Notifications.dismiss(root.notification.notificationId)
                    }
                }
            }
        }

        StyledText {
            id: bodyText

            visible: !root.compact
                && (root.notification?.body ?? "") !== ""
            opacity: visible ? 1 : 0
            Layout.fillWidth: true

            Behavior on opacity {
                enabled: root.animationReady
                NumberAnimation { duration: 150 }
            }
            color: Theme.subtext0
            text: (root.notification?.body ?? "")
                .replace(/\n+/g, root.expanded ? "\n" : " ")
            textFormat: Text.RichText
            wrapMode: root.expanded ? Text.Wrap : Text.NoWrap
            elide: root.expanded ? Text.ElideNone : Text.ElideRight
            maximumLineCount: root.expanded ? 20 : 1
            onLinkActivated: link => Qt.openUrlExternally(link)

            HoverHandler {
                id: linkHover

                cursorShape: bodyText.linkAt(
                    point.position.x, point.position.y) !== ""
                        ? Qt.PointingHandCursor
                        : Qt.ArrowCursor
            }
        }

        Flickable {
            visible: root.expanded && actionRow.implicitWidth > 0
            Layout.fillWidth: true
            Layout.preferredHeight: visible ? 32 : 0
            contentWidth: actionRow.implicitWidth
            contentHeight: height
            clip: true

            Row {
                id: actionRow
                height: parent.height
                spacing: 6

                Repeater {
                    model: root.hasPrimaryAction
                        ? []
                        : root.notification?.actions ?? []

                    delegate: Rectangle {
                        required property NotificationTypes.NotificationActionEntry modelData

                        implicitWidth: actionLabel.implicitWidth + 20
                        implicitHeight: 30
                        radius: height / 2
                        color: actionMouse.containsMouse ? Theme.surface2 : Theme.surface1

                        StyledText {
                            id: actionLabel
                            anchors.centerIn: parent
                            color: Theme.text
                            text: modelData.text
                        }

                        MouseArea {
                            id: actionMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (root.notification !== null) {
                                    Notifications.invokeAction(
                                        root.notification.notificationId,
                                        modelData.identifier)
                                }
                            }
                        }
                    }
                }

            }
        }
        }

        Rectangle {
            id: thumbnail
            visible: root.showImage && !root.compact
                && (root.notification?.image ?? "") !== ""
            Layout.alignment: Qt.AlignTop
            Layout.preferredWidth: visible ? 42 : 0
            Layout.preferredHeight: visible ? 42 : 0
            radius: 10
            color: Theme.surface0
            clip: true

            Image {
                anchors.fill: parent
                source: root.notification?.image ?? ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
            }
        }
    }

    Component.onCompleted: animationReady = true

    function isPrimaryAction(action: NotificationTypes.NotificationActionEntry): bool {
        const identifier = action.identifier.toLocaleLowerCase()
        const text = action.text.trim().toLocaleLowerCase()
        const primaryNames = ["activate", "open", "view", "show", "launch"]
        return identifier === "default"
            || primaryNames.includes(identifier)
            || primaryNames.includes(text)
    }

    function plainText(body: string): string {
        return body
            .replace(new RegExp("<br\\s*/?\\s*>", "gi"), "\n")
            .replace(new RegExp("</p\\s*>", "gi"), "\n")
            .replace(/<[^>]*>/g, "")
            .replace(/&nbsp;/gi, " ")
            .replace(/&amp;/gi, "&")
            .replace(/&lt;/gi, "<")
            .replace(/&gt;/gi, ">")
            .replace(/&quot;/gi, '"')
            .replace(/&#39;|&apos;/gi, "'")
            .replace(/&#(x[0-9a-f]+|[0-9]+);/gi, (_, value) =>
                String.fromCodePoint(value[0].toLowerCase() === "x"
                    ? parseInt(value.slice(1), 16)
                    : parseInt(value, 10)))
            .trim()
    }

}
