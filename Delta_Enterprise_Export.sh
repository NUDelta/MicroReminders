#!/bin/bash
xcodebuild clean \
    -workspace MicroReminders.xcworkspace/ \
    -scheme MicroReminders
    
xcodebuild \
    -workspace MicroReminders.xcworkspace \
    -scheme MicroReminders \
    -archivePath build/MicroReminders.xcarchive \
    archive 

xcodebuild \
    -exportArchive \
    -archivePath build/MicroReminders.xcarchive \
    -exportOptionsPlist exportEnterprise.plist \
    -exportPath MicroReminders.ipa

rm -rf build
mv MicroReminders.ipa/MicroReminders.ipa archives/$@.ipa
rmdir MicroReminders.ipa

