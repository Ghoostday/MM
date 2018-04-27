#!/bin/sh

#  build.sh
#
#  Created by Johan Wiig on 22/11/14.
#  Copyright (c) 2014 Innology. All rights reserved.

OUTPUT=build

set -e

if [ "$#" -lt "4" ]; then
echo
echo "USAGE: build.sh [PROJECT] [SCHEME] [BUILD] [PROFILE] [TEST DESTINATIONS...(optional)]";
echo
echo "Run from project root directory"
echo
echo "PROJECT       Name of XCode project, without file extention"
echo "SCHEME        Scheme to compile against (default XCode scheme equals project name)"
echo "BUILD         Build number to use"
echo "PROFILE       Provisioning profile"
echo "TEST DEST.    List of test destinations to run agains. If nothing is provided, no tests are run."
echo
echo "EXAMPLE: build.sh MyProject Production 10 'XC: *' 'platform=iOS Simulator,name=iPhone 5' 'platform=iOS Simulator,name=iPhone 6'"
echo
exit
fi

PROJECT=$1
SCHEME=$2
NEW_VERSION=$3
PROVISIONING_PROFILE=$4
TEST_DESTINATION=$5

echo
echo "PROJECT   $PROJECT"
echo "SCHEME    $SCHEME"
echo "BUILD     $NEW_VERSION"
echo "PROFILE   $PROVISIONING_PROFILE"
echo "TEST      $TEST_DESTINATION"
echo

echo "********* INNOLOGY iOS BUILD SCRIPT: CLEAN *********"
rm -rf $OUTPUT
xcodebuild SYMROOT="$OUTPUT" DSTROOT=$OUTPUT clean
agvtool new-version -all $NEW_VERSION



echo "********* INNOLOGY iOS BUILD SCRIPT: TEST *********"
xcodebuild -project "$PROJECT.xcodeproj" -scheme "$SCHEME" analyze
#xcodebuild -project "$PROJECT.xcodeproj" -scheme "$SCHEME" -destination "$TEST_DESTINATION" test



echo "********* INNOLOGY iOS BUILD SCRIPT: PACKAGE *********"
xcodebuild -project "$PROJECT.xcodeproj" -scheme "$SCHEME" -archivePath "$OUTPUT/$PROJECT.xcarchive" -sdk iphoneos archive
xcodebuild -exportArchive -exportFormat IPA -archivePath "$OUTPUT/$PROJECT.xcarchive" -exportPath "$OUTPUT/$PROJECT.ipa" -exportProvisioningProfile "$PROVISIONING_PROFILE"



if [ -d "$OUTPUT/$PROJECT.xcarchive/SwiftSupport" ]; then
echo "********* INNOLOGY iOS BUILD SCRIPT: ADDING SWIFT SUPPORT to IPA *********"
mv "$OUTPUT/$PROJECT.ipa" "$OUTPUT/$PROJECT.zip"
unzip "$OUTPUT/$PROJECT.zip" -d "$OUTPUT/tmp"
cp -r "$OUTPUT/$PROJECT.xcarchive/SwiftSupport" "$OUTPUT/tmp"
rm "$OUTPUT/$PROJECT.zip"
pushd "$OUTPUT/tmp"
zip -r "../$PROJECT.ipa" .
popd
fi

