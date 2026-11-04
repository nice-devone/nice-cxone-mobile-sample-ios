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

extension BackgroundSurfaceStyleColorsImpl {
    
    @MainActor
    static var lightColors: BackgroundSurfaceStyleColorsImpl {
        BackgroundSurfaceStyleColorsImpl(
            default: ChatThemeColors.color(for: .background(.surface(.default)), isDark: false),
            variant: ChatThemeColors.color(for: .background(.surface(.variant)), isDark: false),
            container: ChatThemeColors.color(for: .background(.surface(.container)), isDark: false),
            subtle: ChatThemeColors.color(for: .background(.surface(.subtle)), isDark: false),
            emphasis: ChatThemeColors.color(for: .background(.surface(.emphasis)), isDark: false)
        )
    }
    
    @MainActor
    static var darkColors: BackgroundSurfaceStyleColorsImpl {
        BackgroundSurfaceStyleColorsImpl(
            default: ChatThemeColors.color(for: .background(.surface(.default)), isDark: true),
            variant: ChatThemeColors.color(for: .background(.surface(.variant)), isDark: true),
            container: ChatThemeColors.color(for: .background(.surface(.container)), isDark: true),
            subtle: ChatThemeColors.color(for: .background(.surface(.subtle)), isDark: true),
            emphasis: ChatThemeColors.color(for: .background(.surface(.emphasis)), isDark: true)
        )
    }
}
