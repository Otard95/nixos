import QtQml

QtObject {
    enum Urgency {
        Low,
        Normal,
        Critical
    }

    required property string notificationId
    required property string appName

    property string appIcon: ""
    property string desktopEntry: ""
    property string category: ""
    property string summary: ""
    property string body: ""
    property string image: ""
    property int urgency: NotificationRecord.Normal
    property double time: 0
    property bool isTransient: false
    property bool resident: false
    property bool dismissible: true
    property list<NotificationAction> actions: []
}
