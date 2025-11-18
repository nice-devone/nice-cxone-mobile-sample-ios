//
// Copyright (c) 2021-2025. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-sample-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN “AS IS” BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

import CXoneChatUI

extension StatusStyleColorsImpl {
    private typealias Theme = Asset.Colors.ChatDefaultTheme
    
    static var lightColors: StatusStyleColorsImpl {
        StatusStyleColorsImpl(
            success: LocalStorageManager.statusSuccessLightColor ?? Theme.Status.successLight.swiftUIColor,
            onSuccess: LocalStorageManager.statusOnSuccessLightColor ?? Theme.Status.onSuccessLight.swiftUIColor,
            successContainer: LocalStorageManager.statusSuccessContainerLightColor ?? Theme.Status.successContainerLight.swiftUIColor,
            onSuccessContainer: LocalStorageManager.statusOnSuccessContainerLightColor ?? Theme.Status.onSuccessContainerLight.swiftUIColor,
            warning: LocalStorageManager.statusWarningLightColor ?? Theme.Status.warningLight.swiftUIColor,
            onWarning: LocalStorageManager.statusOnWarningLightColor ?? Theme.Status.onWarningLight.swiftUIColor,
            warningContainer: LocalStorageManager.statusWarningContainerLightColor ?? Theme.Status.warningContainerLight.swiftUIColor,
            onWarningContainer: LocalStorageManager.statusOnWarningContainerLightColor ?? Theme.Status.onWarningContainerLight.swiftUIColor,
            error: LocalStorageManager.statusErrorLightColor ?? Theme.Status.errorLight.swiftUIColor,
            onError: LocalStorageManager.statusOnErrorLightColor ?? Theme.Status.onErrorLight.swiftUIColor,
            errorContainer: LocalStorageManager.statusErrorContainerLightColor ?? Theme.Status.errorContainerLight.swiftUIColor,
            onErrorContainer: LocalStorageManager.statusOnErrorContainerLightColor ?? Theme.Status.onErrorContainerLight.swiftUIColor
        )
    }
    
    static var darkColors: StatusStyleColorsImpl {
        StatusStyleColorsImpl(
            success: LocalStorageManager.statusSuccessDarkColor ?? Theme.Status.successDark.swiftUIColor,
            onSuccess: LocalStorageManager.statusOnSuccessDarkColor ?? Theme.Status.onSuccessDark.swiftUIColor,
            successContainer: LocalStorageManager.statusSuccessContainerDarkColor ?? Theme.Status.successContainerDark.swiftUIColor,
            onSuccessContainer: LocalStorageManager.statusOnSuccessContainerDarkColor ?? Theme.Status.onSuccessContainerDark.swiftUIColor,
            warning: LocalStorageManager.statusWarningDarkColor ?? Theme.Status.warningDark.swiftUIColor,
            onWarning: LocalStorageManager.statusOnWarningDarkColor ?? Theme.Status.onWarningDark.swiftUIColor,
            warningContainer: LocalStorageManager.statusWarningContainerDarkColor ?? Theme.Status.warningContainerDark.swiftUIColor,
            onWarningContainer: LocalStorageManager.statusOnWarningContainerDarkColor ?? Theme.Status.onWarningContainerDark.swiftUIColor,
            error: LocalStorageManager.statusErrorDarkColor ?? Theme.Status.errorDark.swiftUIColor,
            onError: LocalStorageManager.statusOnErrorDarkColor ?? Theme.Status.onErrorDark.swiftUIColor,
            errorContainer: LocalStorageManager.statusErrorContainerDarkColor ?? Theme.Status.errorContainerDark.swiftUIColor,
            onErrorContainer: LocalStorageManager.statusOnErrorContainerDarkColor ?? Theme.Status.onErrorContainerDark.swiftUIColor
        )
    }
}
