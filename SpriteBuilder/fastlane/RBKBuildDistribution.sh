#!/bin/bash
#
# Usage:
# ./RBKBuildDistribution
# ./RBKBuildDistribution QA
#
# Arguments:
# - Build Configuration, defaults to "Release Prod"
#

CONFIGURATION=${1:-"Release Prod"}
echo "Configuration: ${CONFIGURATION}"
BUILD_NUMBER=${2}
echo $BUILD_NUMBER

# Remove build directory
cd ../..
CCB_DIR=$(pwd)

rm -r build/
rm -r SpriteBuilder/build/

# Update version for about box
## Grab some values
GIT_HASH=$(git rev-parse --short=10 HEAD)
PLIST_FILE="SpriteBuilder/ccBuilder/SpriteBuilder-Info.plist"
VERSION_STRING=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "${PLIST_FILE}")
## Update plist build number
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BUILD_NUMBER" "${PLIST_FILE}"
VERSION="${VERSION_STRING} (${BUILD_NUMBER}, $GIT_HASH)"
echo "Version: $VERSION"
echo "$VERSION" > Generated/Version.txt
touch Generated/Version.txt

# Generate default project
echo "=== GENERATING DEFAULT SB-PROJECT ==="
cd Support/RBK/PROJECTNAME.pcase/
rm -rf PROJECTNAME.xcodeproj/xcuserdata/
rm -rf PROJECTNAME.xcodeproj/project.xcworkspace/xcuserdata
rm ../../../Generated/PROJECTNAME.zip
zip -r ../../../Generated/RBKPROJECTNAME.zip * -x *.git*
cd ../../..

# Clean and build CocosBuilder
echo "=== CLEANING ==="
cd SpriteBuilder/
xcodebuild -workspace SpriteBuilder.xcworkspace -derivedDataPath "build" -scheme "SpriteBuilder" -configuration "$CONFIGURATION" clean

echo "=== BUILDING SPRITEBUILDER ==="
xcodebuild -workspace SpriteBuilder.xcworkspace -derivedDataPath "build" -scheme "SpriteBuilder" -configuration "$CONFIGURATION" build
cd ..

mkdir build

echo "=== COPY PRODUCTS ==="
echo $(pwd)
cp -R "SpriteBuilder/build/Build/Products/$CONFIGURATION/PencilCase.app" build/PencilCase.app
cp -R "SpriteBuilder/build/Build/Products/$CONFIGURATION/PencilCase.app.dSYM" build/PencilCase.app.dSYM

echo "=== ZIPPING UP FILES ==="
cd build/
zip -r "PencilCase.app.dSYM.zip" PencilCase.app.dSYM
