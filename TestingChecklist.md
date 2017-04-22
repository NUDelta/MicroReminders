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
- Can open successfully, and display all tasks for the user key specified in the build (context unassigned).
- In task constraint view, all locations are present.
- In task constraint view, time presents correctly.
- Context can be assigned to unassigned tasks.
- Context can be reassigned to previously assigned tasks.
    - Changing location context doesn't crash and is reflected in Firebase.
    - Changing time context doesn't crash and is reflected in Firebase.

#### After termination
- All the same tests as in "first opening" succeed after terminating and relaunching the app.

#### After uninstall/reinstall
- All tasks retain context assigned before uninstall.

### Notifications
#### First opening
*Precondition*: 1+ tasks have been assigned to a beacon on hand. 1+ task has time context which includes now, 1+ task has time context which does not include now.
- Awakening a sleeping beacon triggers a reminder associated with that location, with time context including now.
    - The reminder is not for a task with time range excluding now.
- Notifications are not re-triggered before the cooldown period has expired.
    - Sleep beacon/remove phone from room, wait long enough for beacon to exit, bring phone back. Check no notification thrown.
    - Sleep beacon/remove phone from room, wait appropriate time, bring phone back. Check notification thrown.
- All notification actions are present in notification.
- Interaction with each notification action performs as expected, and logs correctly to Firebase.

#### After termination
- Terminate app. Sleep beacon. Wait appropriate amount of time for beacon exit and cooldown. Awaken beacon. Check notification thrown.
- Terminate app. Sleep beacon. Wait appropriate amount of time for beacon exit, but not enough for cooldown. Awaken beacon. Check no notification thrown.

### Switching beacons
*Precondition*: In Firebase:
1. All exit times for user's beacons are deleted.
2. All tasks with old beacon name are switched to new - UPPERCASED.
3. Beacon ID and name are replaced with new one - LOWERCASED