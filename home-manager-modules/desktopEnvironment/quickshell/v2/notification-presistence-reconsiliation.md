 Persistence implementation plan

 ### 1. Add session identity

 Add PersistentProperties to the native strategy:

 ```qml
   PersistentProperties {
       reloadableId: "notificationDaemonSession"

       property string daemonSessionId: root.generateSessionId()

       onLoaded: {
           root.sessionIdentityReady = true
           root.tryCompleteInitialization()
       }
   }
 ```

 The generated ID will use a timestamp plus multiple random words, without relying on an external uuidgen binary.

 Semantics:

 - Configuration reload: previous ID replaces the initializer.
 - Full restart: initializer produces a fresh ID.
 - Reconciliation cannot start until loaded fires.

 ### 2. Add NotificationHistory.qml

 This helper will own a DocumentStore containing a versioned, validated document:

 ```json
   {
     "version": 1,
     "notifications": [
       {
         "durableId": "...",
         "originatingDaemonSessionId": "...",
         "originatingProtocolId": "42",
         "appName": "...",
         "appIcon": "...",
         "desktopEntry": "...",
         "category": "...",
         "summary": "...",
         "body": "...",
         "urgency": 1,
         "time": 1234567890,
         "resident": false
       }
     ]
   }
 ```

 It will not persist:

 - Actions
 - Native object references
 - Popup membership or deadlines
 - Unread state
 - Transient notifications
 - Process-backed image URLs

 Initial retention limits will be explicit constants, likely 200 entries and 30 days.

 ### 3. Split native receipt into binding and publication

 The current receive() does too much. Split it into:

 ```text
   acceptNotification(notification)
       └── create binding immediately

   stageBinding(binding)
   processBinding(binding)
   publishNewBinding(binding)
   reconcileLastGeneration(binding)
 ```

 The server handler remains:

 ```qml
   onNotification: notification => {
       notification.tracked = true
       root.acceptNotification(notification)
   }
 ```

 acceptNotification() immediately:

 - Captures arrival time.
 - Creates NativeNotificationBinding.
 - Connects replacement and close handling.
 - Places it in either the pending or active collection.

 This ensures staged notifications still observe replacements and sender closure.

 ### 4. Gate initial classification on two readiness conditions

 Initialization requires:

 ```qml
   readonly property bool initComplete:
       sessionIdentityReady && historyStoreReady
 ```

 Before that point, bindings remain in:

 ```text
   pendingBindings
 ```

 When both become ready:

 1. Index persisted candidates by session ID plus protocol ID.
 2. Process pending lastGeneration bindings first.
 3. Match and consume corresponding persisted candidates.
 4. Process pending ordinary bindings as new notifications.
 5. Restore all unconsumed persisted candidates as history.
 6. Publish the resulting typed record list.
 7. Persist the merged result.

 We will not require nativeReplayComplete to begin this process.

 ### 5. Keep reconciliation open after initialization

 Any later notification still follows:

 ```qml
   if (binding.lastGeneration)
       reconcileLastGeneration(binding)
   else
       publishNewBinding(binding)
 ```

 A lastGeneration binding matches only when:

 ```text
   persisted originatingDaemonSessionId == current daemonSessionId
   and
   persisted originatingProtocolId == binding.protocolId
 ```

 If a matching historical entry was already published, it is replaced/upgraded with the live binding. We will try to retain its durable ID and timestamp.

 A late unmatched lastGeneration binding becomes live but:

 - Does not become unread.
 - Does not create a popup.
 - Receives a new durable ID if necessary.

 ### 6. Distinguish live and historical operations

 Maintain separate internal lookups:

 ```text
   liveBindingsByProtocolId
   historicalRecordsByNotificationId
 ```

 Dispatch behavior:

 ┌───────────┬──────────────────────┬─────────────────────┐
 │ Operation │ Live                 │ Historical          │
 ├───────────┼──────────────────────┼─────────────────────┤
 │ Dismiss   │ Native dismiss()     │ Remove locally      │
 ├───────────┼──────────────────────┼─────────────────────┤
 │ Action    │ Invoke native action │ Unavailable         │
 ├───────────┼──────────────────────┼─────────────────────┤
 │ Close     │ Native close handler │ Not applicable      │
 ├───────────┼──────────────────────┼─────────────────────┤
 │ Popup     │ Eligible by policy   │ Never automatically │
 ├───────────┼──────────────────────┼─────────────────────┤
 │ Persist   │ Metadata only        │ Metadata only       │
 └───────────┴──────────────────────┴─────────────────────┘

 Restored IDs use:

 ```text
   history:<durable-id>
 ```

 Live IDs remain numeric protocol IDs represented as strings, preserving timer compatibility.

 ### 7. Persist after authoritative mutations

 Rewrite the bounded document after:

 - New retained notification
 - Replacement update
 - Native close
 - Live or historical dismissal
 - Dismiss all
 - Initial restore/reconciliation

 Do not write before DocumentStore.ready.

 Writes should be debounced so one replacement’s multiple field changes produce one persistence write.

 ### 8. UI behavior during initialization

 Initially, allow the list to populate normally. Replay is synchronous and the local history document is bounded, so this should be fast.

 Only add:

 ```qml
   Notifications.initializing
 ```

 and a loading placeholder if testing reveals a visible empty-state flash.

 ### 9. Validation before native ownership

 Construction-safe tests:

 - Invalid history document leaves the backend operational.
 - Old-session protocol-ID collision does not reconcile.
 - Same-session plus protocol ID does reconcile.
 - lastGeneration: false never reconciles.
 - Persistence-first and binding-first produce identical results.
 - Early binding closure removes it from pending state.
 - Replacement while pending updates the eventual record.
 - Restored actions are empty.
 - Transient notifications are not serialized.
 - History is bounded by count and age.

 The final real hot-reload and full-restart behavior still requires the controlled native ownership test later.

 The key adjustment from the previous plan is: create native bindings immediately, but delay classification/publication until session identity and history are ready.
 Reconciliation remains available afterward for late replayed bindings.
