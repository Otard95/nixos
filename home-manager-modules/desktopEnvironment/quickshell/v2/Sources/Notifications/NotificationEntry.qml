import QtQml

QtObject {
    enum Urgency {
        Low,
        Normal,
        Critical
    }

    required property string notificationId
    required property string groupId
    required property string appName

    property string appIcon: ""
    property string category: ""
    property string summary: ""
    property string body: ""
    property string image: ""
    property int urgency: NotificationEntry.Normal
    property double time: 0
    property bool dismissible: true
    property list<NotificationActionEntry> actions: []
}
