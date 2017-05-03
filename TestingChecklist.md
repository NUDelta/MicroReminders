# Checklist to be evaluated before any major deployment of MicroReminders
Last updated 4/20/17.

## Building
- Builds to latest version of iOS.
- Can be signed with Delta Lab M.
- Can install on simulator, Delta iPhone, and non-DTR iPhone.
- Can be archived for distribution.

## Functionality
### UI
#### First opening
- Can open successfully, and display all tasks for the user key specified in the build.

#### After termination
- All the same tests as in "first opening" succeed after terminating and relaunching the app.

#### After uninstall/reinstall

### Notifications and context
Note: test all of these with the app on the debugger, but also with the app terminated prior to the notification trigger.

#### Notification responses
- Verify notification actions for "I'll do that now!" and "Not now..." are present
- Tapping "I'll do that now" logs an acceptance to Firebase
- Tapping "Not now" offers a text input, which logs as a decline_with_reason to Firebase
- Both the above options are available via an alert if app is opened (notification tapped)

#### Vanilla time/location
*Precondition*: a task with location L, with entering trigger, with time context that includes right now
- "Enter" region L. Verify notification is thrown.
- Modify time context to not include now. Enter region L. Verify notification is not thrown.

Repeat with a task with exiting trigger.

#### Time/location with delay
*Precondition*: a task with location L, with a delay D < 3, with time context that includes right now
- Enter region L. Wait D minutes. Verify notification is thrown.
- Exit region L. Wait 60 seconds. Reenter region L. Wait D minutes. Verify notification is thrown.
- Exit region L. Wait 60 seconds. Reenter region L. Wait < D minutes. Exit region L. Verify no notification is thrown.

Repeat with a D > 3, to verify background tasking really works.

#### Plug in/unplug
*Precondition*: a task with location L, with time context that includes right now, with a plug/unplug context without a delay.
- Enter region L. Plug in the phone. Verify a notification is thrown.
- Exit region L. Wait 60 seconds. Plug in the phone. Verify no notification is thrown.
- Enter region L, with phone plugged in. Unplug. Verify no notification is thrown.

Repeat, with plug and unplug reversed.

#### Plug in/unplug with delay
*Precondition*: a task with location L, with time context that includes right now, with a plug/unplug context with a delay D (see notes on D above).
- Enter region L. Plug in the phone. Wait D seconds. Verify notification is thrown, only at end of D.
- Exit region L. Wait 60 seconds. Plug in the phone. Wait D minutes. Verify no notification is thrown.
- Enter region L, with phone plugged in. Unplug. Verify no notification is thrown.

Repeat, with plug and unplug reversed.

#### Switching context
- Make change in Firebase. Terminate app. Reopen. Verify slight lag as habits repopulate.

