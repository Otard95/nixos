import qs
import QtQuick
import Quickshell
import Quickshell.Io
import "SchemaValidator.js" as SchemaValidator

Scope {
    id: root

    enum StorageClass {
        Data,
        State
    }

    required property string documentName
    property int storageClass: DocumentStore.State
    property var defaults: ({})
    property var schema: true
    property var customValidator: null
    property int writeDelay: 100
    property bool prettyPrint: true

    readonly property var document: internalDocument
    readonly property bool ready: internalReady
    readonly property bool valid: internalValid
    readonly property bool dirty: internalDirty
    readonly property bool saving: internalSaving
    readonly property var validationErrors: internalValidationErrors
    readonly property string lastError: internalLastError
    readonly property string fileName: documentName.endsWith(".json") ? documentName : documentName + ".json"
    readonly property string path: storageClass === DocumentStore.Data
        ? Quickshell.dataPath(fileName)
        : Quickshell.statePath(fileName)

    property var internalDocument: null
    property bool internalReady: false
    property bool internalValid: false
    property bool internalDirty: false
    property bool internalSaving: false
    property var internalValidationErrors: []
    property string internalLastError: ""
    property int revision: 0
    property int savingRevision: -1

    signal loaded
    signal loadRejected(var errors)
    signal saved
    signal saveRejected(var errors)

    function clone(value) {
        return JSON.parse(JSON.stringify(value));
    }

    function validate(value) {
        const result = SchemaValidator.validate(value, schema);
        if (!result.valid || customValidator === null)
            return result;

        const customResult = customValidator(value);
        if (customResult === true || customResult === undefined || customResult === null)
            return result;
        if (customResult === false)
            result.errors.push({ path: "$", keyword: "custom", message: "custom validation failed" });
        else if (typeof customResult === "string")
            result.errors.push({ path: "$", keyword: "custom", message: customResult });
        else if (Array.isArray(customResult))
            result.errors = result.errors.concat(customResult);
        else if (customResult.valid === false)
            result.errors = result.errors.concat(customResult.errors ?? []);
        result.valid = result.errors.length === 0;
        return result;
    }

    function replace(value) {
        const candidate = clone(value);
        const result = validate(candidate);
        internalValidationErrors = result.errors;
        internalValid = result.valid;
        if (!result.valid) {
            saveRejected(result.errors);
            return false;
        }

        internalDocument = candidate;
        internalLastError = "";
        internalDirty = true;
        revision++;
        saveTimer.restart();
        return true;
    }

    function update(updater) {
        if (typeof updater !== "function")
            throw new Error("DocumentStore.update expects a function");
        const candidate = clone(internalDocument);
        const replacement = updater(candidate);
        return replace(replacement === undefined ? candidate : replacement);
    }

    function reset() {
        return replace(defaults);
    }

    function flush() {
        if (!internalReady || !internalDirty || internalSaving)
            return;
        internalSaving = true;
        savingRevision = revision;
        const indentation = prettyPrint ? 2 : 0;
        file.setText(JSON.stringify(internalDocument, null, indentation) + "\n");
    }

    function acceptLoadedDocument(value) {
        const result = validate(value);
        internalValidationErrors = result.errors;
        internalValid = result.valid;
        if (result.valid) {
            internalDocument = clone(value);
            internalLastError = "";
            internalReady = true;
            loaded();
        } else {
            internalDocument = clone(defaults);
            internalLastError = "Document failed schema validation";
            internalReady = true;
            loadRejected(result.errors);
        }
    }

    Component.onCompleted: {
        if (!/^[A-Za-z0-9][A-Za-z0-9._-]*$/.test(documentName))
            throw new Error("DocumentStore.documentName contains unsupported characters");
        const defaultResult = validate(defaults);
        if (!defaultResult.valid)
            throw new Error("DocumentStore defaults do not match its schema: " + JSON.stringify(defaultResult.errors));
        internalDocument = clone(defaults);
    }

    Timer {
        id: saveTimer
        interval: root.writeDelay
        repeat: false
        onTriggered: root.flush()
    }

    FileView {
        id: file

        path: root.path
        atomicWrites: true

        onLoaded: {
            try {
                root.acceptLoadedDocument(JSON.parse(text()));
            } catch (error) {
                root.internalValid = false;
                root.internalDocument = root.clone(root.defaults);
                root.internalLastError = "Failed to parse document: " + error;
                root.internalReady = true;
                root.loadRejected([{ path: "$", keyword: "parse", message: String(error) }]);
            }
        }

        onLoadFailed: error => {
            root.internalDocument = root.clone(root.defaults);
            if (error === FileViewError.FileNotFound) {
                root.internalValid = true;
                root.internalDirty = true;
                root.revision++;
                root.internalReady = true;
                root.loaded();
                saveTimer.restart();
            } else {
                root.internalValid = false;
                root.internalLastError = "Failed to load document: " + error;
                root.internalReady = true;
            }
        }

        onSaved: {
            root.internalSaving = false;
            if (root.savingRevision === root.revision) {
                root.internalDirty = false;
                root.saved();
            } else {
                saveTimer.restart();
            }
        }

        onSaveFailed: error => {
            root.internalSaving = false;
            root.internalLastError = "Failed to save document: " + error;
        }
    }
}
