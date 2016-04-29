#!/bin/bash
# original source from http://www.thecave.com/2014/09/16/using-xcodebuild-to-export-a-ipa-from-an-archive/

xcodebuild clean -project MicroReminders -configuration Release -alltargets
xcodebuild archive -workspace MicroReminders.xcworkspace -scheme MicroReminders -archivePath MicroReminders.xcarchive
xcodebuild -exportArchive -archivePath MicroReminders.xcarchive -exportPath MicroReminders -exportFormat ipa -exportProvisioningProfile "Delta"
