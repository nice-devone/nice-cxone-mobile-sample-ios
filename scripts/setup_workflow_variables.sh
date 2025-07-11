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
	    echo "$name=${value}" >> $GITHUB_ENV
	fi
    fi
}

# Common
prepare_env SWIFTGEN_VERSION '6.6.3'

export RUNNER_TEMP="${RUNNER_TEMP:-$(pwd)}"

prepare_env PROJECT_DIR "$RUNNER_TEMP"
prepare_env BUILD "$PROJECT_DIR/build"

