pragma Singleton

import qs
import Quickshell

Singleton {
    id: root

    readonly property int selectedTool: store.document?.selectedTool ?? 0
    readonly property bool collapsed: store.document?.collapsed ?? false
    property var openPanelIds: ({})
    readonly property bool anyOpen: Object.keys(openPanelIds).length > 0

    function setPanelOpen(panelId, open) {
        if (panelId === "" || (openPanelIds[panelId] === true) === open)
            return;
        const next = Object.assign({}, openPanelIds);
        if (open)
            next[panelId] = true;
        else
            delete next[panelId];
        openPanelIds = next;
    }

    function setSelectedTool(value) {
        const selected = Math.max(0, Math.min(2, Math.round(value)));
        store.update(document => {
            document.selectedTool = selected;
        });
    }

    function setCollapsed(value) {
        store.update(document => {
            document.collapsed = Boolean(value);
        });
    }

    DocumentStore {
        id: store

        documentName: "status-panel"
        storageClass: DocumentStore.State
        defaults: ({
            version: 1,
            selectedTool: 0,
            collapsed: false
        })
        schema: ({
            type: "object",
            required: ["version", "selectedTool", "collapsed"],
            properties: {
                version: { type: "integer", const: 1 },
                selectedTool: { type: "integer", minimum: 0, maximum: 2 },
                collapsed: { type: "boolean" }
            },
            additionalProperties: false
        })

        onLoadRejected: errors => console.warn("Status panel state rejected:", JSON.stringify(errors))
        onSaveRejected: errors => console.warn("Status panel state save rejected:", JSON.stringify(errors))
    }
}
