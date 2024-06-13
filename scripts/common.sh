#!/bin/bash -xe
#
# Copyright (c) 2021-2024. NICE Ltd. All rights reserved.
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

PROJECT_DIR="$(pwd)"
NAME="iOSSDKExample"
BUILD="$PROJECT_DIR/build"
PROJECT="${NAME}".xcodeproj
BUILDLOG=$BUILD/build.log
SCHEME=${NAME}
ARCHIVE=$BUILD/"${NAME}".xcarchive
ZIPFILE=$BUILD/"${NAME}".zip

clean() {
    rm -rf sample/iOSSDKExample.xcodeproj \
       "iOSSDKExample/Support Files/Generated" \
       ~/Library/Developer/Xcode/DerivedData/iOSSDKExample-*

    # sometimes this mysteriously fails once, but works when run again
    if [ -x $BUILD ] ; then
        rm -rf $BUILD || rm -rf $BUILD
    fi
}

install_swiftgen() {
    mkdir -p $BUILD/swiftgen
    pushd $BUILD/swiftgen

    if ! [ -x bin/swiftgen ] ; then
        curl -L -o swiftgen.zip https://github.com/SwiftGen/SwiftGen/releases/download/6.6.2/swiftgen-6.6.2.zip
        unzip swiftgen.zip
    fi

    popd
}

swiftgen() {
    $BUILD/swiftgen/bin/swiftgen $*
}

setup() {
    # insure that local.yml exists
    echo -n >> local.yml

    # install swiftgen
    install_swiftgen
    
    mkdir -p "iOSSDKExample/Supporting Files/Generated"

    swiftgen config -c .swiftgen.yml

    xcodegen

    mkdir -p "$BUILD"
}

build() {
    local target=$1
    shift
    
    xcodebuild $target \
	       -project $PROJECT \
	       -scheme $SCHEME \
	       DEBUG_INFOMATION_FORMAT=dwarf-with-dsym \
	       ENABLE_BITCODE=NO \
	       "$@"
}
