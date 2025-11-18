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

extension ContentStyleColorsImpl {
    private typealias Theme = Asset.Colors.ChatDefaultTheme
    
    static var lightColors: ContentStyleColorsImpl {
        ContentStyleColorsImpl(
            primary: LocalStorageManager.contentPrimaryLightColor ?? Theme.Content.primaryLight.swiftUIColor,
            secondary: LocalStorageManager.contentSecondaryLightColor ?? Theme.Content.secondaryLight.swiftUIColor,
            tertiary: LocalStorageManager.contentTertiaryLightColor ?? Theme.Content.tertiaryLight.swiftUIColor,
            inverse: LocalStorageManager.contentInverseLightColor ?? Theme.Content.inverseLight.swiftUIColor
        )
    }
    
    static var darkColors: ContentStyleColorsImpl {
        ContentStyleColorsImpl(
            primary: LocalStorageManager.contentPrimaryDarkColor ?? Theme.Content.primaryDark.swiftUIColor,
            secondary: LocalStorageManager.contentSecondaryDarkColor ?? Theme.Content.secondaryDark.swiftUIColor,
            tertiary: LocalStorageManager.contentTertiaryDarkColor ?? Theme.Content.tertiaryDark.swiftUIColor,
            inverse: LocalStorageManager.contentInverseDarkColor ?? Theme.Content.inverseDark.swiftUIColor
        )
    }
}
