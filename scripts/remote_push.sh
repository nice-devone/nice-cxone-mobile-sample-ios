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

# This script sends a push notification to the iOS simulator using the `xcrun simctl push` command.
#
# It requires the simulator to be booted and the app with the specified bundle identifier to be installed.
# The script takes an optional argument for the `threadIdOnExternalPlatform` parameter.
# It also accepts an optional -scheme parameter ("iOS" or "Android") to adjust the deeplink.
#
# Usage: sh remote_push.sh [-scheme iOS|Android] [threadIdOnExternalPlatform]

# Default values
scheme="iOS"
# Channel ID is not parsed in the iOS sample app so it's only for mocking the Android deeplink
channelId="$(uuidgen)"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -scheme)
      shift
      
      if [[ "$1" != "iOS" && "$1" != "Android" ]]; then
        echo "Error: -scheme must be 'iOS' or 'Android'"
        exit 1
      fi
      
      scheme="$1"
      shift;;
    -channelId)
      shift
      
      if [ -z "$1" ]; then
        echo "Error: -channelId requires a value."
        exit 1
      fi
      
      channelId="$1"
      shift;;
    *)
      
      if [ -z "$threadIdOnExternalPlatform" ]; then
        threadIdOnExternalPlatform="$1"
      fi
      
      shift;;
  esac
done

if [ -z "$threadIdOnExternalPlatform" ]; then
  echo "threadIdOnExternalPlatform of existing thread: "
  read threadIdOnExternalPlatform

  if [ -z "$threadIdOnExternalPlatform" ]; then
    echo "Error: threadIdOnExternalPlatform cannot be empty."
    exit 1
  fi
else
  echo "Setting threadIdOnExternalPlatform to \"$threadIdOnExternalPlatform\"."
fi

# Set deeplink based on scheme
if [ "$scheme" = "iOS" ]; then
  deeplink="com.incontact.mobileSDK.sample://threads?idOnExternalPlatform=$threadIdOnExternalPlatform"
else
  deeplink="com.nice.cxonechat.sample://$channelId/threads?idOnExternalPlatform=$threadIdOnExternalPlatform"
fi

# Use mktemp for a safe temporary file
PUSH_APNS_FILE=$(mktemp /tmp/push.apns)

# Ensure cleanup of the temporary file
trap "rm -f \"$PUSH_APNS_FILE\"" EXIT

# Generate JSON payload
cat > "$PUSH_APNS_FILE" <<EOF
{
  "Simulator Target Bundle": "com.incontact.mobileSDK.sample",
  "data": {
    "pinpoint": {
      "deeplink": "$deeplink"
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
EOF

# Check if the app is installed on the simulator
if ! xcrun simctl get_app_container booted com.incontact.mobileSDK.sample &>/dev/null; then
  echo "Error: App with bundle identifier 'com.incontact.mobileSDK.sample' is not installed on the booted simulator."
  exit 1
fi

# Send the push notification
xcrun simctl push booted com.incontact.mobileSDK.sample "$PUSH_APNS_FILE"
