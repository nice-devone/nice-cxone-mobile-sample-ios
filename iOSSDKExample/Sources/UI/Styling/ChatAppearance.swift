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
    
    enum Background {
        static var `default`: Color {
            .themedColor(
                light: LocalStorageManager.backgroundDefaultLightColor ?? Theme.Background.defaultLight.swiftUIColor,
                dark: LocalStorageManager.backgroundDefaultDarkColor ?? Theme.Background.defaultDark.swiftUIColor
            )
        }
        
        static var inverse: Color {
            .themedColor(
                light: LocalStorageManager.backgroundInverseLightColor ?? Theme.Background.inverseLight.swiftUIColor,
                dark: LocalStorageManager.backgroundInverseDarkColor ?? Theme.Background.inverseDark.swiftUIColor
            )
        }
        
        enum Surface {
            static var `default`: Color {
                .themedColor(
                    light: LocalStorageManager.backgroundSurfaceDefaultLightColor ?? Theme.Background.Surface.defaultLight.swiftUIColor,
                    dark: LocalStorageManager.backgroundSurfaceDefaultDarkColor ?? Theme.Background.Surface.defaultDark.swiftUIColor
                )
            }
            static var variant: Color {
                .themedColor(
                    light: LocalStorageManager.backgroundSurfaceVariantLightColor ?? Theme.Background.Surface.variantLight.swiftUIColor,
                    dark: LocalStorageManager.backgroundSurfaceVariantDarkColor ?? Theme.Background.Surface.variantDark.swiftUIColor
                )
            }
            static var container: Color {
                .themedColor(
                    light: LocalStorageManager.backgroundSurfaceContainerLightColor ?? Theme.Background.Surface.containerLight.swiftUIColor,
                    dark: LocalStorageManager.backgroundSurfaceContainerDarkColor ?? Theme.Background.Surface.containerDark.swiftUIColor
                )
            }
            static var subtle: Color {
                .themedColor(
                    light: LocalStorageManager.backgroundSurfaceSubtleLightColor ?? Theme.Background.Surface.subtleLight.swiftUIColor,
                    dark: LocalStorageManager.backgroundSurfaceSubtleDarkColor ?? Theme.Background.Surface.subtleDark.swiftUIColor
                )
            }
            static var emphasis: Color {
                .themedColor(
                    light: LocalStorageManager.backgroundSurfaceEmphasisLightColor ?? Theme.Background.Surface.emphasisLight.swiftUIColor,
                    dark: LocalStorageManager.backgroundSurfaceEmphasisDarkColor ?? Theme.Background.Surface.emphasisDark.swiftUIColor
                )
            }
        }
    }
    
    enum Content {
        static var primary: Color {
            .themedColor(
                light: LocalStorageManager.contentPrimaryLightColor ?? Theme.Content.primaryLight.swiftUIColor,
                dark: LocalStorageManager.contentPrimaryDarkColor ?? Theme.Content.primaryDark.swiftUIColor
            )
        }
        static var secondary: Color {
            .themedColor(
                light: LocalStorageManager.contentSecondaryLightColor ?? Theme.Content.secondaryLight.swiftUIColor,
                dark: LocalStorageManager.contentSecondaryDarkColor ?? Theme.Content.secondaryDark.swiftUIColor
            )
        }
        static var tertiary: Color {
            .themedColor(
                light: LocalStorageManager.contentTertiaryLightColor ?? Theme.Content.tertiaryLight.swiftUIColor,
                dark: LocalStorageManager.contentTertiaryDarkColor ?? Theme.Content.tertiaryDark.swiftUIColor
            )
        }
        static var inverse: Color {
            .themedColor(
                light: LocalStorageManager.contentInverseLightColor ?? Theme.Content.inverseLight.swiftUIColor,
                dark: LocalStorageManager.contentInverseDarkColor ?? Theme.Content.inverseDark.swiftUIColor
            )
        }
    }
    
    enum Brand {
        static var primary: Color {
            .themedColor(
                light: LocalStorageManager.brandPrimaryLightColor ?? Theme.Brand.primaryLight.swiftUIColor,
                dark: LocalStorageManager.brandPrimaryDarkColor ?? Theme.Brand.primaryDark.swiftUIColor
            )
        }
        static var onPrimary: Color {
            .themedColor(
                light: LocalStorageManager.brandOnPrimaryLightColor ?? Theme.Brand.onPrimaryLight.swiftUIColor,
                dark: LocalStorageManager.brandOnPrimaryDarkColor ?? Theme.Brand.onPrimaryDark.swiftUIColor
            )
        }
        static var primaryContainer: Color {
            .themedColor(
                light: LocalStorageManager.brandPrimaryContainerLightColor ?? Theme.Brand.primaryContainerLight.swiftUIColor,
                dark: LocalStorageManager.brandPrimaryContainerDarkColor ?? Theme.Brand.primaryContainerDark.swiftUIColor
            )
        }
        static var onPrimaryContainer: Color {
            .themedColor(
                light: LocalStorageManager.brandOnPrimaryContainerLightColor ?? Theme.Brand.onPrimaryContainerLight.swiftUIColor,
                dark: LocalStorageManager.brandOnPrimaryContainerDarkColor ?? Theme.Brand.onPrimaryContainerDark.swiftUIColor
            )
        }
        static var secondary: Color {
            .themedColor(
                light: LocalStorageManager.brandSecondaryLightColor ?? Theme.Brand.secondaryLight.swiftUIColor,
                dark: LocalStorageManager.brandSecondaryDarkColor ?? Theme.Brand.secondaryDark.swiftUIColor
            )
        }
        static var onSecondary: Color {
            .themedColor(
                light: LocalStorageManager.brandOnSecondaryLightColor ?? Theme.Brand.onSecondaryLight.swiftUIColor,
                dark: LocalStorageManager.brandOnSecondaryDarkColor ?? Theme.Brand.onSecondaryDark.swiftUIColor
            )
        }
        static var secondaryContainer: Color {
            .themedColor(
                light: LocalStorageManager.brandSecondaryContainerLightColor ?? Theme.Brand.secondaryContainerLight.swiftUIColor,
                dark: LocalStorageManager.brandSecondaryContainerDarkColor ?? Theme.Brand.secondaryContainerDark.swiftUIColor
            )
        }
        static var onSecondaryContainer: Color {
            .themedColor(
                light: LocalStorageManager.brandOnSecondaryContainerLightColor ?? Theme.Brand.onSecondaryContainerLight.swiftUIColor,
                dark: LocalStorageManager.brandOnSecondaryContainerDarkColor ?? Theme.Brand.onSecondaryContainerDark.swiftUIColor
            )
        }
    }
    
    enum Border {
        static var `default`: Color {
            .themedColor(
                light: LocalStorageManager.borderDefaultLightColor ?? Theme.Border.defaultLight.swiftUIColor,
                dark: LocalStorageManager.borderDefaultDarkColor ?? Theme.Border.defaultDark.swiftUIColor
            )
        }
        static var subtle: Color {
            .themedColor(
                light: LocalStorageManager.borderSubtleLightColor ?? Theme.Border.subtleLight.swiftUIColor,
                dark: LocalStorageManager.borderSubtleDarkColor ?? Theme.Border.subtleDark.swiftUIColor
            )
        }
    }
    
    enum Status {
        static var success: Color {
            .themedColor(
                light: LocalStorageManager.statusSuccessLightColor ?? Theme.Status.successLight.swiftUIColor,
                dark: LocalStorageManager.statusSuccessDarkColor ?? Theme.Status.successDark.swiftUIColor
            )
        }
        static var onSuccess: Color {
            .themedColor(
                light: LocalStorageManager.statusOnSuccessLightColor ?? Theme.Status.onSuccessLight.swiftUIColor,
                dark: LocalStorageManager.statusOnSuccessDarkColor ?? Theme.Status.onSuccessDark.swiftUIColor
            )
        }
        static var successContainer: Color {
            .themedColor(
                light: LocalStorageManager.statusSuccessContainerLightColor ?? Theme.Status.successContainerLight.swiftUIColor,
                dark: LocalStorageManager.statusSuccessContainerDarkColor ?? Theme.Status.successContainerDark.swiftUIColor
            )
        }
        static var onSuccessContainer: Color {
            .themedColor(
                light: LocalStorageManager.statusOnSuccessContainerLightColor ?? Theme.Status.onSuccessContainerLight.swiftUIColor,
                dark: LocalStorageManager.statusOnSuccessContainerDarkColor ?? Theme.Status.onSuccessContainerDark.swiftUIColor
            )
        }
        static var warning: Color {
            .themedColor(
                light: LocalStorageManager.statusWarningLightColor ?? Theme.Status.warningLight.swiftUIColor,
                dark: LocalStorageManager.statusWarningDarkColor ?? Theme.Status.warningDark.swiftUIColor
            )
        }
        static var onWarning: Color {
            .themedColor(
                light: LocalStorageManager.statusOnWarningLightColor ?? Theme.Status.onWarningLight.swiftUIColor,
                dark: LocalStorageManager.statusOnWarningDarkColor ?? Theme.Status.onWarningDark.swiftUIColor
            )
        }
        static var warningContainer: Color {
            .themedColor(
                light: LocalStorageManager.statusWarningContainerLightColor ?? Theme.Status.warningContainerLight.swiftUIColor,
                dark: LocalStorageManager.statusWarningContainerDarkColor ?? Theme.Status.warningContainerDark.swiftUIColor
            )
        }
        static var onWarningContainer: Color {
            .themedColor(
                light: LocalStorageManager.statusOnWarningContainerLightColor ?? Theme.Status.onWarningContainerLight.swiftUIColor,
                dark: LocalStorageManager.statusOnWarningContainerDarkColor ?? Theme.Status.onWarningContainerDark.swiftUIColor
            )
        }
        static var error: Color {
            .themedColor(
                light: LocalStorageManager.statusErrorLightColor ?? Theme.Status.errorLight.swiftUIColor,
                dark: LocalStorageManager.statusErrorDarkColor ?? Theme.Status.errorDark.swiftUIColor
            )
        }
        static var onError: Color {
            .themedColor(
                light: LocalStorageManager.statusOnErrorLightColor ?? Theme.Status.onErrorLight.swiftUIColor,
                dark: LocalStorageManager.statusOnErrorDarkColor ?? Theme.Status.onErrorDark.swiftUIColor
            )
        }
        static var errorContainer: Color {
            .themedColor(
                light: LocalStorageManager.statusErrorContainerLightColor ?? Theme.Status.errorContainerLight.swiftUIColor,
                dark: LocalStorageManager.statusErrorContainerDarkColor ?? Theme.Status.errorContainerDark.swiftUIColor
            )
        }
        static var onErrorContainer: Color {
            .themedColor(
                light: LocalStorageManager.statusOnErrorContainerLightColor ?? Theme.Status.onErrorContainerLight.swiftUIColor,
                dark: LocalStorageManager.statusOnErrorContainerDarkColor ?? Theme.Status.onErrorContainerDark.swiftUIColor
            )
        }
    }
}

// MARK: - Methods

extension ChatAppearance {
    
    static func getChatStyle() -> ChatStyle {
        let lightModeColors = StyleColorsImpl(
            background: BackgroundStyleColorsImpl.lightColors,
            content: ContentStyleColorsImpl.lightColors,
            brand: BrandStyleColorsImpl.lightColors,
            border: BorderStyleColorsImpl.lightColors,
            status: StatusStyleColorsImpl.lightColors
        )
        let darkModeColors = StyleColorsImpl(
            background: BackgroundStyleColorsImpl.darkColors,
            content: ContentStyleColorsImpl.darkColors,
            brand: BrandStyleColorsImpl.darkColors,
            border: BorderStyleColorsImpl.darkColors,
            status: StatusStyleColorsImpl.darkColors
        )
        
        return ChatStyle(colorsManager: StyleColorsManager(light: lightModeColors, dark: darkModeColors))
    }
}
