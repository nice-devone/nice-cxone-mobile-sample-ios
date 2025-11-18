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

extension BrandStyleColorsImpl {
    private typealias Theme = Asset.Colors.ChatDefaultTheme
    
    static var lightColors: BrandStyleColorsImpl {
        BrandStyleColorsImpl(
            primary: LocalStorageManager.brandPrimaryLightColor ?? Theme.Brand.primaryLight.swiftUIColor,
            onPrimary: LocalStorageManager.brandOnPrimaryLightColor ?? Theme.Brand.onPrimaryLight.swiftUIColor,
            primaryContainer: LocalStorageManager.brandPrimaryContainerLightColor ?? Theme.Brand.primaryContainerLight.swiftUIColor,
            onPrimaryContainer: LocalStorageManager.brandOnPrimaryContainerLightColor ?? Theme.Brand.onPrimaryContainerLight.swiftUIColor,
            secondary: LocalStorageManager.brandSecondaryLightColor ?? Theme.Brand.secondaryLight.swiftUIColor,
            onSecondary: LocalStorageManager.brandOnSecondaryLightColor ?? Theme.Brand.onSecondaryLight.swiftUIColor,
            secondaryContainer: LocalStorageManager.brandSecondaryContainerLightColor ?? Theme.Brand.secondaryContainerLight.swiftUIColor,
            onSecondaryContainer: LocalStorageManager.brandOnSecondaryContainerLightColor ?? Theme.Brand.onSecondaryContainerLight.swiftUIColor
        )
    }
    
    static var darkColors: BrandStyleColorsImpl {
        BrandStyleColorsImpl(
            primary: LocalStorageManager.brandPrimaryDarkColor ?? Theme.Brand.primaryDark.swiftUIColor,
            onPrimary: LocalStorageManager.brandOnPrimaryDarkColor ?? Theme.Brand.onPrimaryDark.swiftUIColor,
            primaryContainer: LocalStorageManager.brandPrimaryContainerDarkColor ?? Theme.Brand.primaryContainerDark.swiftUIColor,
            onPrimaryContainer: LocalStorageManager.brandOnPrimaryContainerDarkColor ?? Theme.Brand.onPrimaryContainerDark.swiftUIColor,
            secondary: LocalStorageManager.brandSecondaryDarkColor ?? Theme.Brand.secondaryDark.swiftUIColor,
            onSecondary: LocalStorageManager.brandOnSecondaryDarkColor ?? Theme.Brand.onSecondaryDark.swiftUIColor,
            secondaryContainer: LocalStorageManager.brandSecondaryContainerDarkColor ?? Theme.Brand.secondaryContainerDark.swiftUIColor,
            onSecondaryContainer: LocalStorageManager.brandOnSecondaryContainerDarkColor ?? Theme.Brand.onSecondaryContainerDark.swiftUIColor
        )
    }
}
