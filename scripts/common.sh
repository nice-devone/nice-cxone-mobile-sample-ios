#!/bin/bash -xe
#
# Copyright (c) 2021-2026. NICE Ltd. All rights reserved.
#
# Licensed under the NICE License;
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    https://github.com/nice-devone/nice-cxone-mobile-sample-ios/blob/main/LICENSE
#
# TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
# AN "AS IS" BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
# OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
#

set -o pipefail

. scripts/setup_workflow_variables.sh

clean() {
    rm -rf \
        sample/iOSSDKExample.xcodeproj \
        "sample/iOSSDKExample/Support Files/Generated" \
        ~/Library/Developer/Xcode/DerivedData/iOSSDKExample-* \
        cxone-chat-ui/Sources/Resources/Generated \
        cxone-chat-sdk/Sources/Resources/Generated

    # sometimes this mysteriously fails once, but works when run again
    if [ -x $BUILD ] ; then
        rm -rf $BUILD || rm -rf $BUILD
    fi
}

install_swiftgen() {
    mkdir -p $BUILD/swiftgen
    pushd $BUILD/swiftgen

    if ! [ -x bin/swiftgen ] ; then
        curl -L -o swiftgen.zip https://github.com/SwiftGen/SwiftGen/releases/download/$SWIFTGEN_VERSION/swiftgen-$SWIFTGEN_VERSION.zip
        unzip swiftgen.zip
    fi

    popd
}

swiftgen() {
    $BUILD/swiftgen/bin/swiftgen $*
}

setup() {
    pushd cxone-chat-sdk > /dev/null
    setup_sdk
    popd > /dev/null

    pushd cxone-chat-ui > /dev/null
    setup_ui
    popd > /dev/null

    pushd sample
    setup_sample
    popd

    setup_file_headers
}

write_ide_template_macros() {
    local dir="$1"
    local license_url="$2"

    mkdir -p "$dir"
    cat > "$dir/IDETemplateMacros.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>FILEHEADER</key>
    <string>
// Copyright (c) 2021-2026. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    ${license_url}
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN "AS IS" BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//</string>
</dict>
</plist>
EOF
}

setup_file_headers() {
    write_ide_template_macros \
        "cxone-chat-sdk/.swiftpm/xcode/package.xcworkspace/xcshareddata" \
        "https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/LICENSE"

    write_ide_template_macros \
        "cxone-chat-ui/.swiftpm/xcode/package.xcworkspace/xcshareddata" \
        "https://github.com/nice-devone/nice-cxone-mobile-ui-ios/blob/main/LICENSE"

    write_ide_template_macros \
        "cxone-guide-utility/.swiftpm/xcode/package.xcworkspace/xcshareddata" \
        "https://github.com/nice-devone/nice-cxone-mobile-guide-utility-ios/blob/main/LICENSE"

    write_ide_template_macros \
        "sample/iOSSDKExample.xcodeproj/xcshareddata" \
        "https://github.com/nice-devone/nice-cxone-mobile-sample-ios/blob/main/LICENSE"
}

setup_sample() {
    # insure that local.yml exists
    echo -n >> local.yml

    # install swiftgen
    install_swiftgen
    
    mkdir -p "iOSSDKExample/Supporting Files/Generated"

    swiftgen config -c .swiftgen.yml

    xcodegen

    mkdir -p "$BUILD"
}

setup_ui() {
    # install swiftgen if needed
    install_swiftgen
    
    mkdir -p "Sources/Resources/Generated"

    swiftgen config -c .swiftgen.yml

    updateMarketingVersion -module "CXoneChatUIModule" \
        -license_path "https://github.com/nice-devone/nice-cxone-mobile-ui-ios/blob/main/LICENSE"
}

setup_sdk() {
    mkdir -p "Sources/Resources/Generated"

    updateMarketingVersion -module "CXoneChatSDKModule" \
        -license_path "https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/LICENSE"
}

xcode() {
    local target=$1
    shift
    
    xcodebuild $target \
	       DEBUG_INFOMATION_FORMAT=dwarf-with-dsym \
	       ENABLE_BITCODE=NO \
	       -skipPackagePluginValidation \
	       -skipMacroValidation \
	       "$@"
}

archive() {
    local archive="$1"
    shift

    xcode archive \
	  -configuration Release \
	  -scheme $SCHEME \
	  -archivePath "${archive}" \
	  -destination "${ARCHIVE_DESTINATION:-generic/platform=iOS}" \
	  "$@"
}

exportToIPA() {
    local archive="$1"
    local optionsPlist="$2"
    local ipaPath="$3"
    shift 2
    
    xcode \
	-exportArchive \
	-archivePath "${archive}" \
        -exportOptionsPlist "$optionsPlist" \
        -allowProvisioningUpdates \
        -exportPath "$ipaPath"
}

updateMarketingVersion() {
    MODULE_NAME=""
    LICENSE_PATH=""

    while [[ "$#" -gt 0 ]]; do
        case $1 in
            -module)
                MODULE_NAME="$2"
                shift 2
                ;;
            -license_path)
                LICENSE_PATH="$2"
                shift 2
                ;;
            *)
                echo "Unknown parameter passed: $1" >&2
                exit 1
                ;;
        esac
    done

    if [ -z "$MODULE_NAME" ]; then
        echo "error: --extension_name is required." >&2
        exit 1
    fi
    if [ -z "$LICENSE_PATH" ]; then
        echo "error: --license_path is required." >&2
        exit 1
    fi

    . ../scripts/update_marketing_version.sh $MODULE_NAME $LICENSE_PATH
}
