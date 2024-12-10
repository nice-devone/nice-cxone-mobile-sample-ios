#!/bin/bash -xe
#
# Copyright (c) 2021-2024. NICE Ltd. All rights reserved.
#
# Licensed under the NICE License;
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/LICENSE
#
# TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
# AN “AS IS” BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
# OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
#

set -o pipefail

mkdir -p sample/iOSSDKExample/Supporting\ Files/Generated
mkdir -p cxone-chat-ui/Sources/Resources/Generated
mkdir -p "$RUNNER_TEMP/build"

pushd "$RUNNER_TEMP/build"

curl -L -o swiftgen.zip "https://github.com/SwiftGen/SwiftGen/releases/download/$SWIFTGEN_VERSION/swiftgen-$SWIFTGEN_VERSION.zip"
unzip swiftgen.zip
popd

pushd sample
"$RUNNER_TEMP/build/bin/swiftgen" config -c .swiftgen.yml
popd
          
pushd cxone-chat-ui
"$RUNNER_TEMP/build/bin/swiftgen" config -c .swiftgen.yml
