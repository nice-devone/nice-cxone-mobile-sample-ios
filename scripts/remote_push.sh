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

set -o pipefail

if [ -z "$1" ]
  then
    echo 'threadIdOnExternalPlatform of existing thread: '
    read threadIdOnExternalPlatform
  else
    echo "Setting threadIdOnExternalPlatform to \"$1\"."
    threadIdOnExternalPlatform="$1"
fi

read -r -d '' JSON << \
_______________________________________________________________________________
{
  "Simulator Target Bundle": "com.incontact.mobileSDK.sample",
  "data": {
    "pinpoint": {
      "deeplink": "com.incontact.mobileSDK.sample://threads?idOnExternalPlatform=$threadIdOnExternalPlatform"
    }
  },
  "aps": {
    "alert": {
      "title": "New Message!",
      "body": "You have received new message from an agent."
    },
    "content-available": 1,
    "mutable-content": 0
  }
}
_______________________________________________________________________________

echo $JSON > push.apns

xcrun simctl push booted com.incontact.mobileSDK.sample push.apns

rm push.apns
