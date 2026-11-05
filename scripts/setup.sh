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

. scripts/common.sh

clean

# Mirrors the QA channel config into shared/ BEFORE setup(), which runs `xcodegen
# generate` for the sample: XcodeGen bakes each file under shared/assets into
# project.pbxproj as an individual build-file reference at generate time — running the
# fetch afterward would leave environment.json out of that reference until a *second*
# `xcodegen generate` picked it up. Guarded on the script's presence so it's a no-op
# where it isn't available. Failure here is non-fatal — under `-e` a failing command
# inside this `then` block would otherwise abort the rest of setup.sh, even though it
# only leaves the Configuration screen's custom-channel picker empty.
if [ -x scripts/fetch_sample_environments.sh ]; then
    scripts/fetch_sample_environments.sh \
        || echo "warning: failed to fetch sample environment config — shared/ left as-is" >&2
fi

setup
