# DocumentStore

`DocumentStore` persists one schema-validated JSON document using Quickshell's
per-shell data or state directory.

`DocumentStore` is registered in the configuration's root `qmldir` and is
available to files that import `qs`.

```qml
import qs

DocumentStore {
    id: timerStore

    documentName: "timer"
    storageClass: DocumentStore.State
    defaults: ({ version: 1, running: false })
    schema: ({
        type: "object",
        required: ["version", "running"],
        properties: {
            version: { type: "integer", const: 1 },
            running: { type: "boolean" }
        },
        additionalProperties: false
    })
}
```

Consumers replace a document atomically:

```qml
timerStore.replace({ version: 1, running: true })
```

or update a cloned document:

```qml
timerStore.update(document => {
    document.running = true;
})
```

Nested mutation of `document` is not observed. Use `replace()` or `update()` so
changes are validated and persisted.

## Storage classes

- `DocumentStore.State` uses `Quickshell.statePath()` and is the default.
- `DocumentStore.Data` uses `Quickshell.dataPath()`.

A missing file is initialized from `defaults`. Invalid JSON or a schema-invalid
existing document is not overwritten automatically; defaults are exposed in
memory and details are available through `lastError` and `validationErrors`.

## Supported schema keywords

The validator intentionally implements a subset of JSON Schema:

- `type`, including an array of allowed types
- `required`, `properties`, `additionalProperties`
- `items`
- `enum`, `const`
- `minimum`, `maximum`
- `minLength`, `maxLength`, `pattern`
- `minItems`, `maxItems`

Use `customValidator` for cross-field invariants. It may return `true`, `false`,
a message string, an error array, or `{ valid, errors }`.

## Current consumer

`Sources/Timer.qml` stores its versioned Pomodoro and stopwatch document in the
state directory. Operational values are wall-clock timestamps so reloads do not
lose elapsed time; recorded lap durations are historical output and do not drive
the stopwatch clock.
