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

extension BrandStyleColorsImpl {
    
    @MainActor
    static var lightColors: BrandStyleColorsImpl {
        BrandStyleColorsImpl(
            primary: ChatThemeColors.color(for: .brand(.primary), isDark: false),
            onPrimary: ChatThemeColors.color(for: .brand(.onPrimary), isDark: false),
            primaryContainer: ChatThemeColors.color(for: .brand(.primaryContainer), isDark: false),
            onPrimaryContainer: ChatThemeColors.color(for: .brand(.onPrimaryContainer), isDark: false),
            secondary: ChatThemeColors.color(for: .brand(.secondary), isDark: false),
            onSecondary: ChatThemeColors.color(for: .brand(.onSecondary), isDark: false),
            secondaryContainer: ChatThemeColors.color(for: .brand(.secondaryContainer), isDark: false),
            onSecondaryContainer: ChatThemeColors.color(for: .brand(.onSecondaryContainer), isDark: false)
        )
    }
    
    @MainActor
    static var darkColors: BrandStyleColorsImpl {
        BrandStyleColorsImpl(
            primary: ChatThemeColors.color(for: .brand(.primary), isDark: true),
            onPrimary: ChatThemeColors.color(for: .brand(.onPrimary), isDark: true),
            primaryContainer: ChatThemeColors.color(for: .brand(.primaryContainer), isDark: true),
            onPrimaryContainer: ChatThemeColors.color(for: .brand(.onPrimaryContainer), isDark: true),
            secondary: ChatThemeColors.color(for: .brand(.secondary), isDark: true),
            onSecondary: ChatThemeColors.color(for: .brand(.onSecondary), isDark: true),
            secondaryContainer: ChatThemeColors.color(for: .brand(.secondaryContainer), isDark: true),
            onSecondaryContainer: ChatThemeColors.color(for: .brand(.onSecondaryContainer), isDark: true)
        )
    }
}
