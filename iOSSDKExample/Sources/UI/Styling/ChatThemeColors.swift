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

import SwiftUI

/// Single access point for the chat theme colour tokens: stored override, default fallback and the
/// light/dark branching all live here, keyed by ``LocalStorageKey/Theme``.
@MainActor
enum ChatThemeColors {
    
    // MARK: - Nested Types
    
    typealias Token = LocalStorageKey.Theme
    
    private typealias Theme = Asset.Colors.ChatDefaultTheme
    
    // MARK: - Methods
    
    /// Stored colour for the token, falling back to its default value.
    static func color(for token: Token, isDark: Bool) -> Color {
        storedColor(for: token, isDark: isDark) ?? defaultColor(for: token, isDark: isDark)
    }
    
    /// Colour for the token in the currently active appearance.
    static func color(for token: Token) -> Color {
        color(for: token, isDark: UIApplication.isDarkModeActive)
    }
    
    /// Stores the colour for the currently active appearance. `nil` writes the default value.
    static func store(_ color: Color?, for token: Token) {
        let isDark = UIApplication.isDarkModeActive
        var storage = Storage<Color>(key: storageKey(for: token, isDark: isDark))
        
        storage.wrappedValue = color ?? defaultColor(for: token, isDark: isDark)
    }
}

// MARK: - Private methods

private extension ChatThemeColors {
    
    static func storageKey(for token: Token, isDark: Bool) -> LocalStorageKey {
        if isDark {
            .chatDarkTheme(token)
        } else {
            .chatLightTheme(token)
        }
    }
    
    static func storedColor(for token: Token, isDark: Bool) -> Color? {
        let storage = Storage<Color>(key: storageKey(for: token, isDark: isDark))
        
        return storage.wrappedValue
    }
    
    static func defaultColor(for token: Token, isDark: Bool) -> Color {
        let colors = defaultColors(for: token)
        
        return isDark ? colors.dark : colors.light
    }
    
    static func defaultColors(for token: Token) -> (light: Color, dark: Color) {
        switch token {
        case .background(let background):
            defaultColors(forBackground: background)
        case .content(let content):
            defaultColors(forContent: content)
        case .brand(let brand):
            defaultColors(forBrand: brand)
        case .border(let border):
            defaultColors(forBorder: border)
        case .status(let status):
            defaultColors(forStatus: status)
        }
    }

    static func defaultColors(forBackground background: Token.Background) -> (light: Color, dark: Color) {
        switch background {
        case .default:
            (light: Theme.Background.defaultLight.swiftUIColor, dark: Theme.Background.defaultDark.swiftUIColor)
        case .inverse:
            (light: Theme.Background.inverseLight.swiftUIColor, dark: Theme.Background.inverseDark.swiftUIColor)
        case .surface(.default):
            (light: Theme.Background.Surface.defaultLight.swiftUIColor, dark: Theme.Background.Surface.defaultDark.swiftUIColor)
        case .surface(.variant):
            (light: Theme.Background.Surface.variantLight.swiftUIColor, dark: Theme.Background.Surface.variantDark.swiftUIColor)
        case .surface(.container):
            (light: Theme.Background.Surface.containerLight.swiftUIColor, dark: Theme.Background.Surface.containerDark.swiftUIColor)
        case .surface(.subtle):
            (light: Theme.Background.Surface.subtleLight.swiftUIColor, dark: Theme.Background.Surface.subtleDark.swiftUIColor)
        case .surface(.emphasis):
            (light: Theme.Background.Surface.emphasisLight.swiftUIColor, dark: Theme.Background.Surface.emphasisDark.swiftUIColor)
        }
    }

    static func defaultColors(forContent content: Token.Content) -> (light: Color, dark: Color) {
        switch content {
        case .primary:
            (light: Theme.Content.primaryLight.swiftUIColor, dark: Theme.Content.primaryDark.swiftUIColor)
        case .secondary:
            (light: Theme.Content.secondaryLight.swiftUIColor, dark: Theme.Content.secondaryDark.swiftUIColor)
        case .tertiary:
            (light: Theme.Content.tertiaryLight.swiftUIColor, dark: Theme.Content.tertiaryDark.swiftUIColor)
        case .inverse:
            (light: Theme.Content.inverseLight.swiftUIColor, dark: Theme.Content.inverseDark.swiftUIColor)
        }
    }

    static func defaultColors(forBrand brand: Token.Brand) -> (light: Color, dark: Color) {
        switch brand {
        case .primary:
            (light: Theme.Brand.primaryLight.swiftUIColor, dark: Theme.Brand.primaryDark.swiftUIColor)
        case .onPrimary:
            (light: Theme.Brand.onPrimaryLight.swiftUIColor, dark: Theme.Brand.onPrimaryDark.swiftUIColor)
        case .primaryContainer:
            (light: Theme.Brand.primaryContainerLight.swiftUIColor, dark: Theme.Brand.primaryContainerDark.swiftUIColor)
        case .onPrimaryContainer:
            (light: Theme.Brand.onPrimaryContainerLight.swiftUIColor, dark: Theme.Brand.onPrimaryContainerDark.swiftUIColor)
        case .secondary:
            (light: Theme.Brand.secondaryLight.swiftUIColor, dark: Theme.Brand.secondaryDark.swiftUIColor)
        case .onSecondary:
            (light: Theme.Brand.onSecondaryLight.swiftUIColor, dark: Theme.Brand.onSecondaryDark.swiftUIColor)
        case .secondaryContainer:
            (light: Theme.Brand.secondaryContainerLight.swiftUIColor, dark: Theme.Brand.secondaryContainerDark.swiftUIColor)
        case .onSecondaryContainer:
            (light: Theme.Brand.onSecondaryContainerLight.swiftUIColor, dark: Theme.Brand.onSecondaryContainerDark.swiftUIColor)
        }
    }

    static func defaultColors(forBorder border: Token.Border) -> (light: Color, dark: Color) {
        switch border {
        case .default:
            (light: Theme.Border.defaultLight.swiftUIColor, dark: Theme.Border.defaultDark.swiftUIColor)
        case .subtle:
            (light: Theme.Border.subtleLight.swiftUIColor, dark: Theme.Border.subtleDark.swiftUIColor)
        }
    }

    static func defaultColors(forStatus status: Token.Status) -> (light: Color, dark: Color) {
        switch status {
        case .success:
            (light: Theme.Status.successLight.swiftUIColor, dark: Theme.Status.successDark.swiftUIColor)
        case .onSuccess:
            (light: Theme.Status.onSuccessLight.swiftUIColor, dark: Theme.Status.onSuccessDark.swiftUIColor)
        case .successContainer:
            (light: Theme.Status.successContainerLight.swiftUIColor, dark: Theme.Status.successContainerDark.swiftUIColor)
        case .onSuccessContainer:
            (light: Theme.Status.onSuccessContainerLight.swiftUIColor, dark: Theme.Status.onSuccessContainerDark.swiftUIColor)
        case .warning:
            (light: Theme.Status.warningLight.swiftUIColor, dark: Theme.Status.warningDark.swiftUIColor)
        case .onWarning:
            (light: Theme.Status.onWarningLight.swiftUIColor, dark: Theme.Status.onWarningDark.swiftUIColor)
        case .warningContainer:
            (light: Theme.Status.warningContainerLight.swiftUIColor, dark: Theme.Status.warningContainerDark.swiftUIColor)
        case .onWarningContainer:
            (light: Theme.Status.onWarningContainerLight.swiftUIColor, dark: Theme.Status.onWarningContainerDark.swiftUIColor)
        case .error:
            (light: Theme.Status.errorLight.swiftUIColor, dark: Theme.Status.errorDark.swiftUIColor)
        case .onError:
            (light: Theme.Status.onErrorLight.swiftUIColor, dark: Theme.Status.onErrorDark.swiftUIColor)
        case .errorContainer:
            (light: Theme.Status.errorContainerLight.swiftUIColor, dark: Theme.Status.errorContainerDark.swiftUIColor)
        case .onErrorContainer:
            (light: Theme.Status.onErrorContainerLight.swiftUIColor, dark: Theme.Status.onErrorContainerDark.swiftUIColor)
        }
    }
}
