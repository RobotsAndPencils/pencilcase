#!/bin/sh
set -e
set -u
set -o pipefail

if [ -z ${UNLOCALIZED_RESOURCES_FOLDER_PATH+x} ]; then
    # If UNLOCALIZED_RESOURCES_FOLDER_PATH is not set, then there's nowhere for us to copy
    # resources to, so exit 0 (signalling the script phase was successful).
    exit 0
fi

mkdir -p "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"

RESOURCES_TO_COPY=${PODS_ROOT}/resources-to-copy-${TARGETNAME}.txt
> "$RESOURCES_TO_COPY"

XCASSET_FILES=()

# This protects against multiple targets copying the same framework dependency at the same time. The solution
# was originally proposed here: https://lists.samba.org/archive/rsync/2008-February/020158.html
RSYNC_PROTECT_TMP_FILES=(--filter "P .*.??????")

case "${TARGETED_DEVICE_FAMILY:-}" in
  1,2)
    TARGET_DEVICE_ARGS="--target-device ipad --target-device iphone"
    ;;
  1)
    TARGET_DEVICE_ARGS="--target-device iphone"
    ;;
  2)
    TARGET_DEVICE_ARGS="--target-device ipad"
    ;;
  3)
    TARGET_DEVICE_ARGS="--target-device tv"
    ;;
  4)
    TARGET_DEVICE_ARGS="--target-device watch"
    ;;
  *)
    TARGET_DEVICE_ARGS="--target-device mac"
    ;;
esac

install_resource()
{
  if [[ "$1" = /* ]] ; then
    RESOURCE_PATH="$1"
  else
    RESOURCE_PATH="${PODS_ROOT}/$1"
  fi
  if [[ ! -e "$RESOURCE_PATH" ]] ; then
    cat << EOM
error: Resource "$RESOURCE_PATH" not found. Run 'pod install' to update the copy resources script.
EOM
    exit 1
  fi
  case $RESOURCE_PATH in
    *.storyboard)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile ${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .storyboard`.storyboardc $RESOURCE_PATH --sdk ${SDKROOT} ${TARGET_DEVICE_ARGS}" || true
      ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .storyboard`.storyboardc" "$RESOURCE_PATH" --sdk "${SDKROOT}" ${TARGET_DEVICE_ARGS}
      ;;
    *.xib)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile ${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .xib`.nib $RESOURCE_PATH --sdk ${SDKROOT} ${TARGET_DEVICE_ARGS}" || true
      ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .xib`.nib" "$RESOURCE_PATH" --sdk "${SDKROOT}" ${TARGET_DEVICE_ARGS}
      ;;
    *.framework)
      echo "mkdir -p ${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}" || true
      mkdir -p "${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      echo "rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" $RESOURCE_PATH ${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}" || true
      rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      ;;
    *.xcdatamodel)
      echo "xcrun momc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH"`.mom\"" || true
      xcrun momc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodel`.mom"
      ;;
    *.xcdatamodeld)
      echo "xcrun momc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodeld`.momd\"" || true
      xcrun momc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodeld`.momd"
      ;;
    *.xcmappingmodel)
      echo "xcrun mapc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcmappingmodel`.cdm\"" || true
      xcrun mapc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcmappingmodel`.cdm"
      ;;
    *.xcassets)
      ABSOLUTE_XCASSET_FILE="$RESOURCE_PATH"
      XCASSET_FILES+=("$ABSOLUTE_XCASSET_FILE")
      ;;
    *)
      echo "$RESOURCE_PATH" || true
      echo "$RESOURCE_PATH" >> "$RESOURCES_TO_COPY"
      ;;
  esac
}
if [[ "$CONFIGURATION" == "Debug" ]]; then
  install_resource "${PODS_ROOT}/GHMarkdownParser/discount/blocktags"
  install_resource "${PODS_ROOT}/../../Assets/bind.js"
  install_resource "${PODS_ROOT}/../../Assets/CameraIcon.png"
  install_resource "${PODS_ROOT}/../../Assets/CameraIcon@2x.png"
  install_resource "${PODS_ROOT}/../../Assets/co.js"
  install_resource "${PODS_ROOT}/../../Assets/creation.js"
  install_resource "${PODS_ROOT}/../../Assets/eraseIcon.png"
  install_resource "${PODS_ROOT}/../../Assets/eraseIcon@2x.png"
  install_resource "${PODS_ROOT}/../../Assets/extendNonEnumerable.js"
  install_resource "${PODS_ROOT}/../../Assets/force-arrow.png"
  install_resource "${PODS_ROOT}/../../Assets/force-arrow@2x.png"
  install_resource "${PODS_ROOT}/../../Assets/keypath.js"
  install_resource "${PODS_ROOT}/../../Assets/lodash.js"
  install_resource "${PODS_ROOT}/../../Assets/ModuleExample.js"
  install_resource "${PODS_ROOT}/../../Assets/PCPlayerPlay.png"
  install_resource "${PODS_ROOT}/../../Assets/PCPlayerPlay@2x.png"
  install_resource "${PODS_ROOT}/../../Assets/photolibrary.js"
  install_resource "${PODS_ROOT}/../../Assets/REPLArrow.png"
  install_resource "${PODS_ROOT}/../../Assets/REPLArrow@2x.png"
  install_resource "${PODS_ROOT}/../../Assets/sound.js"
  install_resource "${PODS_ROOT}/../../Assets/watch.js"
  install_resource "${PODS_ROOT}/../../Source/View Controllers/PCAppView.xib"
  install_resource "${PODS_ROOT}/../../Source/View Controllers/PCREPLView.xib"
  install_resource "${PODS_ROOT}/RPJSContext/Assets/JS/Core Modules/request.js"
  install_resource "${PODS_ROOT}/RPJSContext/Assets/JS/EventEmitter.js"
  install_resource "${PODS_ROOT}/RPJSContext/Assets/JS/regenerator.js"
  install_resource "${PODS_ROOT}/RPJSContext/Assets/JS/rsvp.js"
  install_resource "${PODS_ROOT}/SVProgressHUD/SVProgressHUD/SVProgressHUD.bundle"
fi
if [[ "$CONFIGURATION" == "Release" ]]; then
  install_resource "${PODS_ROOT}/GHMarkdownParser/discount/blocktags"
  install_resource "${PODS_ROOT}/../../Assets/bind.js"
  install_resource "${PODS_ROOT}/../../Assets/CameraIcon.png"
  install_resource "${PODS_ROOT}/../../Assets/CameraIcon@2x.png"
  install_resource "${PODS_ROOT}/../../Assets/co.js"
  install_resource "${PODS_ROOT}/../../Assets/creation.js"
  install_resource "${PODS_ROOT}/../../Assets/eraseIcon.png"
  install_resource "${PODS_ROOT}/../../Assets/eraseIcon@2x.png"
  install_resource "${PODS_ROOT}/../../Assets/extendNonEnumerable.js"
  install_resource "${PODS_ROOT}/../../Assets/force-arrow.png"
  install_resource "${PODS_ROOT}/../../Assets/force-arrow@2x.png"
  install_resource "${PODS_ROOT}/../../Assets/keypath.js"
  install_resource "${PODS_ROOT}/../../Assets/lodash.js"
  install_resource "${PODS_ROOT}/../../Assets/ModuleExample.js"
  install_resource "${PODS_ROOT}/../../Assets/PCPlayerPlay.png"
  install_resource "${PODS_ROOT}/../../Assets/PCPlayerPlay@2x.png"
  install_resource "${PODS_ROOT}/../../Assets/photolibrary.js"
  install_resource "${PODS_ROOT}/../../Assets/REPLArrow.png"
  install_resource "${PODS_ROOT}/../../Assets/REPLArrow@2x.png"
  install_resource "${PODS_ROOT}/../../Assets/sound.js"
  install_resource "${PODS_ROOT}/../../Assets/watch.js"
  install_resource "${PODS_ROOT}/../../Source/View Controllers/PCAppView.xib"
  install_resource "${PODS_ROOT}/../../Source/View Controllers/PCREPLView.xib"
  install_resource "${PODS_ROOT}/RPJSContext/Assets/JS/Core Modules/request.js"
  install_resource "${PODS_ROOT}/RPJSContext/Assets/JS/EventEmitter.js"
  install_resource "${PODS_ROOT}/RPJSContext/Assets/JS/regenerator.js"
  install_resource "${PODS_ROOT}/RPJSContext/Assets/JS/rsvp.js"
  install_resource "${PODS_ROOT}/SVProgressHUD/SVProgressHUD/SVProgressHUD.bundle"
fi

mkdir -p "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
if [[ "${ACTION}" == "install" ]] && [[ "${SKIP_INSTALL}" == "NO" ]]; then
  mkdir -p "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
  rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
rm -f "$RESOURCES_TO_COPY"

if [[ -n "${WRAPPER_EXTENSION}" ]] && [ "`xcrun --find actool`" ] && [ -n "${XCASSET_FILES:-}" ]
then
  # Find all other xcassets (this unfortunately includes those of path pods and other targets).
  OTHER_XCASSETS=$(find "$PWD" -iname "*.xcassets" -type d)
  while read line; do
    if [[ $line != "${PODS_ROOT}*" ]]; then
      XCASSET_FILES+=("$line")
    fi
  done <<<"$OTHER_XCASSETS"

  if [ -z ${ASSETCATALOG_COMPILER_APPICON_NAME+x} ]; then
    printf "%s\0" "${XCASSET_FILES[@]}" | xargs -0 xcrun actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${!DEPLOYMENT_TARGET_SETTING_NAME}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
  else
    printf "%s\0" "${XCASSET_FILES[@]}" | xargs -0 xcrun actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${!DEPLOYMENT_TARGET_SETTING_NAME}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}" --app-icon "${ASSETCATALOG_COMPILER_APPICON_NAME}" --output-partial-info-plist "${TARGET_TEMP_DIR}/assetcatalog_generated_info_cocoapods.plist"
  fi
fi
