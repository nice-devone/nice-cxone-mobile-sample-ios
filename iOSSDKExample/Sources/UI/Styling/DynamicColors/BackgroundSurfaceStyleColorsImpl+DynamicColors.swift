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

extension BackgroundSurfaceStyleColorsImpl {
    private typealias Theme = Asset.Colors.ChatDefaultTheme
    
    static var lightColors: BackgroundSurfaceStyleColorsImpl {
        BackgroundSurfaceStyleColorsImpl(
            default: LocalStorageManager.backgroundSurfaceDefaultLightColor ?? Theme.Background.Surface.defaultLight.swiftUIColor,
            variant: LocalStorageManager.backgroundSurfaceVariantLightColor ?? Theme.Background.Surface.variantLight.swiftUIColor,
            container: LocalStorageManager.backgroundSurfaceContainerLightColor ?? Theme.Background.Surface.containerLight.swiftUIColor,
            subtle: LocalStorageManager.backgroundSurfaceSubtleLightColor ?? Theme.Background.Surface.subtleLight.swiftUIColor,
            emphasis: LocalStorageManager.backgroundSurfaceEmphasisLightColor ?? Theme.Background.Surface.emphasisLight.swiftUIColor
        )
    }
    
    static var darkColors: BackgroundSurfaceStyleColorsImpl {
        BackgroundSurfaceStyleColorsImpl(
            default: LocalStorageManager.backgroundSurfaceDefaultDarkColor ?? Theme.Background.Surface.defaultDark.swiftUIColor,
            variant: LocalStorageManager.backgroundSurfaceVariantDarkColor ?? Theme.Background.Surface.variantDark.swiftUIColor,
            container: LocalStorageManager.backgroundSurfaceContainerDarkColor ?? Theme.Background.Surface.containerDark.swiftUIColor,
            subtle: LocalStorageManager.backgroundSurfaceSubtleDarkColor ?? Theme.Background.Surface.subtleDark.swiftUIColor,
            emphasis: LocalStorageManager.backgroundSurfaceEmphasisDarkColor ?? Theme.Background.Surface.emphasisDark.swiftUIColor
        )
    }
}
