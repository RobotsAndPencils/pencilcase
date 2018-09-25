#!/bin/bash

ID="Developer ID Application: Robots and Pencils Inc."
PKGID="Developer ID Installer: Robots and Pencils Inc."
ENT="../SpriteBuilder/PlugIns.entitlements"
APP="PencilCase.app"

cd ../../build

# Sign command line tools
codesign --verbose --force --sign "$ID" "$APP/Contents/Resources/ccz"
codesign --verbose --force --sign "$ID" "$APP/Contents/Resources/oggenc"
codesign --verbose --force --sign "$ID" "$APP/Contents/Resources/pngquant"
codesign --verbose --force --sign "$ID" "$APP/Contents/Resources/run-in-sim"

# Sign plug-ins
PLUGINS="$APP/Contents/PlugIns"
for f in $PLUGINS/*.ccbPlugNode; do
  codesign --force --verbose --sign "$ID" $f
done

codesign --sign "$ID" "$APP/Contents/PlugIns/CCBI Exporter.ccbPlugExport"

# Sign Frameworks
FRAMEWORKS="$APP/Contents/Frameworks"
for f in $FRAMEWORKS/*.framework; do
  codesign --force --verbose --sign "$ID" "$f/Versions/A"
done

# Sign App
# codesign --verbose --force --sign "$ID" --deep "$APP"
codesign --force --verbose --sign "$ID" "$APP"

# Archive App
# productbuild --component "$APP" /Applications --sign "$PKGID" --product ../SpriteBuilder/Requirements.plist "$APP.pkg"
zip -ry "$APP.zip" "$APP"

# Verify
codesign --verify --verbose=4 "$APP"
spctl --assess --verbose=4 --type execute "$APP"

