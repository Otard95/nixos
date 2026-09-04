import qs
import Quickshell

Scope {
    id: root

    property int maxCount: 200
    property double maxAgeMs: 30 * 24 * 60 * 60 * 1000

    readonly property bool ready: store.ready
    readonly property bool valid: store.valid
    readonly property var entries: store.document?.notifications ?? []
    readonly property string lastError: store.lastError
    readonly property var validationErrors: store.validationErrors

    signal saved

    function bounded(entries): var {
        const cutoff = Date.now() - maxAgeMs
        return entries
            .filter(entry => entry.time >= cutoff)
            .sort((left, right) => right.time - left.time)
            .slice(0, maxCount)
    }

    function replaceEntries(entries): bool {
        if (!ready || !valid)
            return false
        return store.replace({
            version: 1,
            notifications: bounded(entries)
        })
    }

    function clear(): bool {
        return replaceEntries([])
    }

    function validateDocument(document): var {
        const durableIds = ({})
        const reloadKeys = ({})
        for (const entry of document.notifications) {
            if (durableIds[entry.durableId] === true)
                return "notification durable IDs must be unique"
            durableIds[entry.durableId] = true

            const reloadKey = JSON.stringify([
                entry.originatingDaemonSessionId,
                entry.originatingProtocolId
            ])
            if (reloadKeys[reloadKey] === true)
                return "notification reload keys must be unique"
            reloadKeys[reloadKey] = true
        }
        return true
    }

    DocumentStore {
        id: store

        documentName: "notification-history"
        storageClass: DocumentStore.State
        writeDelay: 150
        defaults: ({
            version: 1,
            notifications: []
        })
        schema: ({
            type: "object",
            required: ["version", "notifications"],
            properties: {
                version: { type: "integer", const: 1 },
                notifications: {
                    type: "array",
                    maxItems: root.maxCount,
                    items: {
                        type: "object",
                        required: [
                            "durableId",
                            "originatingDaemonSessionId",
                            "originatingProtocolId",
                            "appName",
                            "appIcon",
                            "desktopEntry",
                            "category",
                            "summary",
                            "body",
                            "urgency",
                            "time",
                            "resident"
                        ],
                        properties: {
                            durableId: { type: "string", minLength: 1 },
                            originatingDaemonSessionId: {
                                type: "string",
                                minLength: 1
                            },
                            originatingProtocolId: { type: "string" },
                            appName: { type: "string" },
                            appIcon: { type: "string" },
                            desktopEntry: { type: "string" },
                            category: { type: "string" },
                            summary: { type: "string" },
                            body: { type: "string" },
                            image: { type: "string" },
                            urgency: {
                                type: "integer",
                                minimum: 0,
                                maximum: 2
                            },
                            time: { type: "number", minimum: 0 },
                            resident: { type: "boolean" }
                        },
                        additionalProperties: false
                    }
                }
            },
            additionalProperties: false
        })
        customValidator: root.validateDocument

        onSaved: root.saved()
    }
}
