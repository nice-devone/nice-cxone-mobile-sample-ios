![](https://img.shields.io/badge/security-Veracode-blue)

# CXone Mobile SDK Sample App

CXone Mobile SDK lets you integrate CXone into your enterprise iOS mobile phone application with operating system iOS 16 and later.

The following sample code will help configure and customize application Digital First Omnichannel chat integration experience.


## Requirements

- iOS 16.0+
- Swift 6.0+ (Xcode 16 or later)


## Modules

- [Utility](https://github.com/nice-devone/nice-cxone-mobile-guide-utility-ios)
- [Core](https://github.com/nice-devone/nice-cxone-mobile-sdk-ios)
- [UI](https://github.com/nice-devone/nice-cxone-mobile-ui-ios)
- Sample


## How to Run the Application

- Clone the SDK repository
- *Prerequisites:* Install Xcodegen
    - [Xcodegen](https://github.com/yonaskolb/XcodeGen#installing) - a command line tool written in Swift that generates Xcode project using folder structure and a project spec.
    - [Swiftgen](https://github.com/SwiftGen/SwiftGen) - a tool to automatically generate Swift code for resources of projects (like images, localised strings, etc), to make them type-safe to use. It does not need to be installed manually — `setup.sh` downloads the required version.
- Run the `setup.sh` script from the root directory
    ```bash
    sh scripts/setup.sh
    ```
- Open project via `iOSSDKExample.xcodeproj`
- Build & run application


## Samples
Detailed [samples](https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/docs/samples.md) of CXoneChatSDK usage can be found in its docs folder, along with the [case studies](https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/docs/case-studies.md).

This sample app uses `ChatCoordinator`, so the [Inactivity Popup](https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/docs/cs-inactivity-popup.md) is presented automatically with no sample-app-specific code — see the case study for how the UI module handles it. The [Satisfaction Survey](https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/docs/cs-satisfaction-survey.md) is presented automatically the same way — see that case study for how the UI module handles it, including holding a multithread survey until its thread is opened.
