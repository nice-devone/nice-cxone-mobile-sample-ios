#!/bin/bash -xe
#
# Copyright (c) 2021-2025. NICE Ltd. All rights reserved.
#
# Licensed under the NICE License;
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    https://github.com/nice-devone/nice-cxone-mobile-sample-ios/blob/main/LICENSE
#
# TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
# AN “AS IS” BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
# OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
#

set -o pipefail

prepare_env() {
    local name="$1"
    local value="$2"

    if [[ -z ${!name} ]] ; then
	export "${name}"="${value}"

	    if [[ x$GITHUB_ENV != x ]] ; then
            # Export to GitHub Actions environment
	        echo "$name=${value}" >> "$GITHUB_ENV"
	    fi
    fi
}

# Common
prepare_env SWIFTGEN_VERSION '6.6.3'
prepare_env XCODEGEN_VERSION '2.44.1'
prepare_env XCODE_VERSION '26.2'
prepare_env SWIFT_VERSION '6.2'
prepare_env IOS_VERSION '26.2'
prepare_env DETECT_VERSION '8.4.0'

export RUNNER_TEMP="${RUNNER_TEMP:-$(pwd)}"

prepare_env SDK_SCHEME "CXoneChatSDK"
prepare_env UI_SCHEME "CXoneChatUI"
prepare_env SAMPLE_SCHEME "iOSSDKExample"
prepare_env UTILITY_SCHEME "CXoneGuideUtility"
prepare_env RUN_DESTINATION "platform=iOS Simulator,arch=arm64,OS=$IOS_VERSION,name=iPhone 17"
prepare_env PROJECT_DIR "$RUNNER_TEMP"
prepare_env ARCHIVE "${RUNNER_TEMP}/build/iOSSDKExample.xcarchive"

prepare_env NAME "iOSSDKExample"
prepare_env BUILD "$PROJECT_DIR/build"
prepare_env PROJECT "${NAME}".xcodeproj
prepare_env BUILDLOG "$BUILD/build.log"
prepare_env SCHEME "${NAME}"
prepare_env ZIPFILE "$BUILD/"${NAME}".zip"

