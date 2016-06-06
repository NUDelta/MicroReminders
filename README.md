# MicroReminders

MicroReminders relies on iBeacon technology, and so both beacons and a physical device with bluetooth enabled are required to effectively use the app.

To run MicroReminders:

1) use CocoaPods to install the Estimote and Firebase SDKs.
2) verify that you have an appropriate code-signing certificate and permissions.
3) open MicroReminders.xcworkspace in Xcode.
4) in AppDelegate, update the "beacons" variable to be a dictionary of your beacons in the format [<beacon minor ID>:<beacon description>].
5) build to a physical device (simulator cannot interact with beacons).
