import QtQml

QtObject {
    required property string groupId
    required property string appName

    property string appIcon: ""
    property double time: 0
    property list<NotificationEntry> notifications: []
}
