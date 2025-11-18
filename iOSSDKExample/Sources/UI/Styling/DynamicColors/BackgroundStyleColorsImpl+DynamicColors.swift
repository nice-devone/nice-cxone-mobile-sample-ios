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

extension BackgroundStyleColorsImpl {
    private typealias Theme = Asset.Colors.ChatDefaultTheme
    
    static var lightColors: BackgroundStyleColorsImpl {
        BackgroundStyleColorsImpl(
            default: LocalStorageManager.backgroundDefaultLightColor ?? Theme.Background.defaultLight.swiftUIColor,
            inverse: LocalStorageManager.backgroundInverseLightColor ?? Theme.Background.inverseLight.swiftUIColor,
            surface: BackgroundSurfaceStyleColorsImpl.lightColors
        )
    }
    
    static var darkColors: BackgroundStyleColorsImpl {
        BackgroundStyleColorsImpl(
            default: LocalStorageManager.backgroundDefaultDarkColor ?? Theme.Background.defaultDark.swiftUIColor,
            inverse: LocalStorageManager.backgroundInverseDarkColor ?? Theme.Background.inverseDark.swiftUIColor,
            surface: BackgroundSurfaceStyleColorsImpl.darkColors
        )
    }
}
