//
// Copyright (c) 2021-2026. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-sample-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN "AS IS" BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

import CXoneChatUI

extension StatusStyleColorsImpl {
    
    @MainActor
    static var lightColors: StatusStyleColorsImpl {
        StatusStyleColorsImpl(
            success: ChatThemeColors.color(for: .status(.success), isDark: false),
            onSuccess: ChatThemeColors.color(for: .status(.onSuccess), isDark: false),
            successContainer: ChatThemeColors.color(for: .status(.successContainer), isDark: false),
            onSuccessContainer: ChatThemeColors.color(for: .status(.onSuccessContainer), isDark: false),
            warning: ChatThemeColors.color(for: .status(.warning), isDark: false),
            onWarning: ChatThemeColors.color(for: .status(.onWarning), isDark: false),
            warningContainer: ChatThemeColors.color(for: .status(.warningContainer), isDark: false),
            onWarningContainer: ChatThemeColors.color(for: .status(.onWarningContainer), isDark: false),
            error: ChatThemeColors.color(for: .status(.error), isDark: false),
            onError: ChatThemeColors.color(for: .status(.onError), isDark: false),
            errorContainer: ChatThemeColors.color(for: .status(.errorContainer), isDark: false),
            onErrorContainer: ChatThemeColors.color(for: .status(.onErrorContainer), isDark: false)
        )
    }
    
    @MainActor
    static var darkColors: StatusStyleColorsImpl {
        StatusStyleColorsImpl(
            success: ChatThemeColors.color(for: .status(.success), isDark: true),
            onSuccess: ChatThemeColors.color(for: .status(.onSuccess), isDark: true),
            successContainer: ChatThemeColors.color(for: .status(.successContainer), isDark: true),
            onSuccessContainer: ChatThemeColors.color(for: .status(.onSuccessContainer), isDark: true),
            warning: ChatThemeColors.color(for: .status(.warning), isDark: true),
            onWarning: ChatThemeColors.color(for: .status(.onWarning), isDark: true),
            warningContainer: ChatThemeColors.color(for: .status(.warningContainer), isDark: true),
            onWarningContainer: ChatThemeColors.color(for: .status(.onWarningContainer), isDark: true),
            error: ChatThemeColors.color(for: .status(.error), isDark: true),
            onError: ChatThemeColors.color(for: .status(.onError), isDark: true),
            errorContainer: ChatThemeColors.color(for: .status(.errorContainer), isDark: true),
            onErrorContainer: ChatThemeColors.color(for: .status(.onErrorContainer), isDark: true)
        )
    }
}
