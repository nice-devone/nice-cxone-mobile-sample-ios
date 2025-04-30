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
import SwiftUI

enum ChatAppearance {
    private typealias Theme = Asset.Colors.ChatDefaultTheme
    
    static var primaryColor: Color {
        .themedColor(
            light: LocalStorageManager.primaryLightColor ?? Theme.primary.swiftUIColor,
            dark: LocalStorageManager.primaryDarkColor ?? Theme.primaryDark.swiftUIColor
        )
    }
    static var onPrimaryColor: Color {
        .themedColor(
            light: LocalStorageManager.onPrimaryLightColor ?? Theme.onPrimary.swiftUIColor,
            dark: LocalStorageManager.onPrimaryDarkColor ?? Theme.onPrimaryDark.swiftUIColor
        )
    }
    static var backgroundColor: Color {
        .themedColor(
            light: LocalStorageManager.backgroundLightColor ?? Theme.background.swiftUIColor,
            dark: LocalStorageManager.backgroundDarkColor ?? Theme.backgroundDark.swiftUIColor
        )
    }
    static var onBackgroundColor: Color {
        .themedColor(
            light: LocalStorageManager.onBackgroundLightColor ?? Theme.onBackground.swiftUIColor,
            dark: LocalStorageManager.onBackgroundDarkColor ?? Theme.onBackgroundDark.swiftUIColor
        )
    }
    static var accentColor: Color {
        .themedColor(
            light: LocalStorageManager.accentLightColor ?? Theme.accent.swiftUIColor,
            dark: LocalStorageManager.accentDarkColor ?? Theme.accentDark.swiftUIColor
        )
    }
    static var onAccentColor: Color {
        .themedColor(
            light: LocalStorageManager.onAccentLightColor ?? Theme.onAccent.swiftUIColor,
            dark: LocalStorageManager.onAccentDarkColor ?? Theme.onAccentDark.swiftUIColor
        )
    }
    static var agentBackgroundColor: Color {
        .themedColor(
            light: LocalStorageManager.agentBackgroundLightColor ?? Theme.agentBackground.swiftUIColor,
            dark: LocalStorageManager.agentBackgroundDarkColor ?? Theme.agentBackgroundDark.swiftUIColor
        )
    }
    
    static var agentTextColor: Color {
        .themedColor(
            light: LocalStorageManager.agentTextLightColor ?? Theme.agentText.swiftUIColor,
            dark: LocalStorageManager.agentTextDarkColor ?? Theme.agentTextDark.swiftUIColor
        )
    }
    
    static var customerBackgroundColor: Color {
        .themedColor(
            light: LocalStorageManager.customerBackgroundLightColor ?? Theme.customerBackground.swiftUIColor,
            dark: LocalStorageManager.customerBackgroundDarkColor ?? Theme.customerBackgroundDark.swiftUIColor
        )
    }
    
    static var customerTextColor: Color {
        // This color need to be updated to use Color+Extensions
        .themedColor(
            light: LocalStorageManager.customerTextLightColor ?? Theme.customerText.swiftUIColor,
            dark: LocalStorageManager.customerTextDarkColor ?? Theme.customerTextDark.swiftUIColor
        )
    }
}

// MARK: - Methods

extension ChatAppearance {
    
    // periphery:ignore - will be used after the 3.0.0 release
    static func getChatStyle() -> ChatStyle {
        let lightModeColors = CustomizableStyleColorsImpl(
            primary: LocalStorageManager.primaryLightColor ?? Theme.primary.swiftUIColor,
            onPrimary: LocalStorageManager.onPrimaryLightColor ?? Theme.onPrimary.swiftUIColor,
            background: LocalStorageManager.backgroundLightColor ?? Theme.background.swiftUIColor,
            onBackground: LocalStorageManager.onBackgroundLightColor ?? Theme.onBackground.swiftUIColor,
            accent: LocalStorageManager.accentLightColor ?? Theme.accent.swiftUIColor,
            onAccent: LocalStorageManager.onAccentLightColor ?? Theme.onAccent.swiftUIColor,
            agentBackground: LocalStorageManager.agentBackgroundLightColor ?? Theme.agentBackground.swiftUIColor,
            agentText: LocalStorageManager.agentTextLightColor ?? Theme.agentText.swiftUIColor,
            customerBackground: LocalStorageManager.customerBackgroundLightColor ?? Theme.customerBackground.swiftUIColor,
            customerText: LocalStorageManager.customerTextLightColor ?? Theme.customerText.swiftUIColor
        )
        let darkModeColors = CustomizableStyleColorsImpl(
            primary: LocalStorageManager.primaryDarkColor ?? Theme.primaryDark.swiftUIColor,
            onPrimary: LocalStorageManager.onPrimaryDarkColor ?? Theme.onPrimaryDark.swiftUIColor,
            background: LocalStorageManager.backgroundDarkColor ?? Theme.backgroundDark.swiftUIColor,
            onBackground: LocalStorageManager.onBackgroundDarkColor ?? Theme.onBackgroundDark.swiftUIColor,
            accent: LocalStorageManager.accentDarkColor ?? Theme.accentDark.swiftUIColor,
            onAccent: LocalStorageManager.onAccentDarkColor ?? Theme.onAccentDark.swiftUIColor,
            agentBackground: LocalStorageManager.agentBackgroundDarkColor ?? Theme.agentBackgroundDark.swiftUIColor,
            agentText: LocalStorageManager.agentTextDarkColor ?? Theme.agentTextDark.swiftUIColor,
            customerBackground: LocalStorageManager.customerBackgroundDarkColor ?? Theme.customerBackgroundDark.swiftUIColor,
            customerText: LocalStorageManager.customerTextDarkColor ?? Theme.customerTextDark.swiftUIColor
        )
        
        return ChatStyle(colorsManager: StyleColorsManager(light: lightModeColors, dark: darkModeColors))
    }
}
