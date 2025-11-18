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

import CXoneChatSDK
import CXoneChatUI
import SwiftUI
import UIKit

class SettingsViewModel: ObservableObject {
    private typealias Theme = Asset.Colors.ChatDefaultTheme
    
    // MARK: - Properties
    
    @Published var firstName = LocalStorageManager.firstName
    @Published var lastName = LocalStorageManager.lastName
    @Published var shouldShareLogs = false
    @Published var showRemoveLogsAlert = false
    @Published var showInvalidColorError = false
    @Published var chatPresentationStyle = LocalStorageManager.chatPresentationStyle ?? .modal
    @Published var isAdditionalContactFieldVisible = false
    @Published var isAdditionalCustomerFieldVisible = false
    @Published var additionalContactCustomFields = LocalStorageManager.additionalContactCustomFields ?? [:]
    @Published var additionalCustomerCustomFields = LocalStorageManager.additionalCustomerCustomFields ?? [:]
    
    var invalidColorTitle: String?
    
    let appBuildNumber = Bundle.main.buildVersion
    let appBranchName = Bundle.main.branchName
    let appCommitHash = Bundle.main.commitHash
    let appBranchTag = Bundle.main.branchTag
    let sdkVersion = CXoneChatSDKModule.version
    let uiVersion = CXoneChatUIModule.version
    let onColorChanged: () -> Void
    
    private var colorDidChange = false
    
    // MARK: - Init
    
    init(onColorChanged: @escaping () -> Void) {
        self.onColorChanged = onColorChanged
    }
    
    // MARK: - Functions
    
    func onDisappear() {
        Log.trace("Settings view is disappearing")
        
        if colorDidChange {
            onColorChanged()
        }
    }
    
    func removeLogs() -> String {
        Log.trace("Removing application logs")
        
        do {
            try Log.removeLogs()
            
            return L10n.Settings.Logs.Remove.Message.success
        } catch {
            error.logError()
            
            return L10n.Settings.Logs.Remove.Message.failure
        }
    }
    
    func chatPresentationStyleChanged(_ style: ChatPresentationStyle) {
        Log.trace("Chat presentation style changed to: \(style)")
        
        LocalStorageManager.chatPresentationStyle = style
    }
    
    func colorDidChange(_ color: Color?, for title: String) {
        if let color {
            Log.trace("Color for \(title) has been changed to \(color.toHexString)")
            
            invalidColorTitle = nil
        } else {
            Log.trace("Color for \(title) has been changed to nil -> fallback to its default value")
            
            invalidColorTitle = title
            showInvalidColorError = true
        }
        
        colorDidChange = true
        
        switch title {
        case L10n.Settings.Theme.Background.Default.placeholder: backgroundDefaultColorChanged(color)
        case L10n.Settings.Theme.Background.Inverse.placeholder: backgroundInverseColorChanged(color)
        case L10n.Settings.Theme.Background.Surface.Default.placeholder: backgroundSurfaceDefaultColorChanged(color)
        case L10n.Settings.Theme.Background.Surface.Variant.placeholder: backgroundSurfaceVariantColorChanged(color)
        case L10n.Settings.Theme.Background.Surface.Container.placeholder: backgroundSurfaceContainerColorChanged(color)
        case L10n.Settings.Theme.Background.Surface.Subtle.placeholder: backgroundSurfaceSubtleColorChanged(color)
        case L10n.Settings.Theme.Background.Surface.Emphasis.placeholder: backgroundSurfaceEmphasisColorChanged(color)
        case L10n.Settings.Theme.Content.Primary.placeholder: contentPrimaryColorChanged(color)
        case L10n.Settings.Theme.Content.Secondary.placeholder: contentSecondaryColorChanged(color)
        case L10n.Settings.Theme.Content.Tertiary.placeholder: contentTertiaryColorChanged(color)
        case L10n.Settings.Theme.Content.Inverse.placeholder: contentInverseColorChanged(color)
        case L10n.Settings.Theme.Brand.Primary.placeholder: brandPrimaryColorChanged(color)
        case L10n.Settings.Theme.Brand.OnPrimary.placeholder: brandOnPrimaryColorChanged(color)
        case L10n.Settings.Theme.Brand.PrimaryContainer.placeholder: brandPrimaryContainerColorChanged(color)
        case L10n.Settings.Theme.Brand.OnPrimaryContainer.placeholder: brandOnPrimaryContainerColorChanged(color)
        case L10n.Settings.Theme.Brand.Secondary.placeholder: brandSecondaryColorChanged(color)
        case L10n.Settings.Theme.Brand.OnSecondary.placeholder: brandOnSecondaryColorChanged(color)
        case L10n.Settings.Theme.Brand.SecondaryContainer.placeholder: brandSecondaryContainerColorChanged(color)
        case L10n.Settings.Theme.Brand.OnSecondaryContainer.placeholder: brandOnSecondaryContainerColorChanged(color)
        case L10n.Settings.Theme.Border.Default.placeholder: borderDefaultColorChanged(color)
        case L10n.Settings.Theme.Border.Subtle.placeholder: borderSubtleColorChanged(color)
        case L10n.Settings.Theme.Status.Success.placeholder: statusSuccessColorChanged(color)
        case L10n.Settings.Theme.Status.OnSuccess.placeholder: statusOnSuccessColorChanged(color)
        case L10n.Settings.Theme.Status.SuccessContainer.placeholder: statusSuccessContainerColorChanged(color)
        case L10n.Settings.Theme.Status.OnSuccessContainer.placeholder: statusOnSuccessContainerColorChanged(color)
        case L10n.Settings.Theme.Status.Warning.placeholder: statusWarningColorChanged(color)
        case L10n.Settings.Theme.Status.OnWarning.placeholder: statusOnWarningColorChanged(color)
        case L10n.Settings.Theme.Status.WarningContainer.placeholder: statusWarningContainerColorChanged(color)
        case L10n.Settings.Theme.Status.OnWarningContainer.placeholder: statusOnWarningContainerColorChanged(color)
        case L10n.Settings.Theme.Status.Error.placeholder: statusErrorColorChanged(color)
        case L10n.Settings.Theme.Status.OnError.placeholder: statusOnErrorColorChanged(color)
        case L10n.Settings.Theme.Status.ErrorContainer.placeholder: statusErrorContainerColorChanged(color)
        case L10n.Settings.Theme.Status.OnErrorContainer.placeholder: statusOnErrorContainerColorChanged(color)
        default:
            LogManager.error("Unknown color with title \(title) did change.")
        }
    }
    
    func setAdditionalContactCustomField(_ field: String, value: String) {
        Log.trace("Additional contact custom field `\(field)` has been set to `\(value)`")
        
        additionalContactCustomFields[field] = value
        LocalStorageManager.additionalContactCustomFields = additionalContactCustomFields
    }
    
    func removeAdditionalContactCustomField(_ field: String) {
        Log.trace("Additional contact custom field `\(field)` has been removed")
        
        additionalContactCustomFields.removeValue(forKey: field)
        LocalStorageManager.additionalContactCustomFields = additionalContactCustomFields
    }
    
    func setAdditionalCustomerCustomField(_ field: String, value: String) {
        Log.trace("Additional customer custom field `\(field)` has been set to `\(value)`")
        
        additionalCustomerCustomFields[field] = value
        LocalStorageManager.additionalCustomerCustomFields = additionalCustomerCustomFields
    }
    
    func removeAdditionalCustomerCustomField(_ field: String) {
        Log.trace("Additional customer custom field `\(field)` has been removed")
        
        additionalCustomerCustomFields.removeValue(forKey: field)
        LocalStorageManager.additionalCustomerCustomFields = additionalCustomerCustomFields
    }
}

// MARK: - Private methods

private extension SettingsViewModel {
    
    func backgroundDefaultColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.backgroundDefaultDarkColor = color ?? Theme.Background.defaultDark.swiftUIColor
        } else {
            LocalStorageManager.backgroundDefaultLightColor = color ?? Theme.Background.defaultLight.swiftUIColor
        }
    }
    
    func backgroundInverseColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.backgroundInverseDarkColor = color ?? Theme.Background.inverseDark.swiftUIColor
        } else {
            LocalStorageManager.backgroundInverseLightColor = color ?? Theme.Background.inverseLight.swiftUIColor
        }
    }
    
    func backgroundSurfaceDefaultColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.backgroundSurfaceDefaultDarkColor = color ?? Theme.Background.Surface.defaultDark.swiftUIColor
        } else {
            LocalStorageManager.backgroundSurfaceDefaultLightColor = color ?? Theme.Background.Surface.defaultLight.swiftUIColor
        }
    }
    
    func backgroundSurfaceVariantColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.backgroundSurfaceVariantDarkColor = color ?? Theme.Background.Surface.variantDark.swiftUIColor
        } else {
            LocalStorageManager.backgroundSurfaceVariantLightColor = color ?? Theme.Background.Surface.variantLight.swiftUIColor
        }
    }
    
    func backgroundSurfaceContainerColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.backgroundSurfaceContainerDarkColor = color ?? Theme.Background.Surface.containerDark.swiftUIColor
        } else {
            LocalStorageManager.backgroundSurfaceContainerLightColor = color ?? Theme.Background.Surface.containerLight.swiftUIColor
        }
    }
    
    func backgroundSurfaceSubtleColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.backgroundSurfaceSubtleDarkColor = color ?? Theme.Background.Surface.subtleDark.swiftUIColor
        } else {
            LocalStorageManager.backgroundSurfaceSubtleLightColor = color ?? Theme.Background.Surface.subtleLight.swiftUIColor
        }
    }
    
    func backgroundSurfaceEmphasisColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.backgroundSurfaceEmphasisDarkColor = color ?? Theme.Background.Surface.emphasisDark.swiftUIColor
        } else {
            LocalStorageManager.backgroundSurfaceEmphasisLightColor = color ?? Theme.Background.Surface.emphasisLight.swiftUIColor
        }
    }
    
    func contentPrimaryColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.contentPrimaryDarkColor = color ?? Theme.Content.primaryDark.swiftUIColor
        } else {
            LocalStorageManager.contentPrimaryLightColor = color ?? Theme.Content.primaryLight.swiftUIColor
        }
    }
    
    func contentSecondaryColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.contentSecondaryDarkColor = color ?? Theme.Content.secondaryDark.swiftUIColor
        } else {
            LocalStorageManager.contentSecondaryLightColor = color ?? Theme.Content.secondaryLight.swiftUIColor
        }
    }
    
    func contentTertiaryColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.contentTertiaryDarkColor = color ?? Theme.Content.tertiaryDark.swiftUIColor
        } else {
            LocalStorageManager.contentTertiaryLightColor = color ?? Theme.Content.tertiaryLight.swiftUIColor
        }
    }
    
    func contentInverseColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.contentInverseDarkColor = color ?? Theme.Content.inverseDark.swiftUIColor
        } else {
            LocalStorageManager.contentInverseLightColor = color ?? Theme.Content.inverseLight.swiftUIColor
        }
    }
    
    func brandPrimaryColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.brandPrimaryDarkColor = color ?? Theme.Brand.primaryDark.swiftUIColor
        } else {
            LocalStorageManager.brandPrimaryLightColor = color ?? Theme.Brand.primaryLight.swiftUIColor
        }
    }
    
    func brandOnPrimaryColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.brandOnPrimaryDarkColor = color ?? Theme.Brand.onPrimaryDark.swiftUIColor
        } else {
            LocalStorageManager.brandOnPrimaryLightColor = color ?? Theme.Brand.onPrimaryLight.swiftUIColor
        }
    }
    
    func brandPrimaryContainerColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.brandPrimaryContainerDarkColor = color ?? Theme.Brand.primaryContainerDark.swiftUIColor
        } else {
            LocalStorageManager.brandPrimaryContainerLightColor = color ?? Theme.Brand.primaryContainerLight.swiftUIColor
        }
    }
    
    func brandOnPrimaryContainerColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.brandOnPrimaryContainerDarkColor = color ?? Theme.Brand.onPrimaryContainerDark.swiftUIColor
        } else {
            LocalStorageManager.brandOnPrimaryContainerLightColor = color ?? Theme.Brand.onPrimaryContainerLight.swiftUIColor
        }
    }
    
    func brandSecondaryColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.brandSecondaryDarkColor = color ?? Theme.Brand.secondaryDark.swiftUIColor
        } else {
            LocalStorageManager.brandSecondaryLightColor = color ?? Theme.Brand.secondaryLight.swiftUIColor
        }
    }
    
    func brandOnSecondaryColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.brandOnSecondaryDarkColor = color ?? Theme.Brand.onSecondaryDark.swiftUIColor
        } else {
            LocalStorageManager.brandOnSecondaryLightColor = color ?? Theme.Brand.onSecondaryLight.swiftUIColor
        }
    }
    
    func brandSecondaryContainerColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.brandSecondaryContainerDarkColor = color ?? Theme.Brand.secondaryContainerDark.swiftUIColor
        } else {
            LocalStorageManager.brandSecondaryContainerLightColor = color ?? Theme.Brand.secondaryContainerLight.swiftUIColor
        }
    }
    
    func brandOnSecondaryContainerColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.brandOnSecondaryContainerDarkColor = color ?? Theme.Brand.onSecondaryContainerDark.swiftUIColor
        } else {
            LocalStorageManager.brandOnSecondaryContainerLightColor = color ?? Theme.Brand.onSecondaryContainerLight.swiftUIColor
        }
    }
    
    func borderDefaultColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.borderDefaultDarkColor = color ?? Theme.Border.defaultDark.swiftUIColor
        } else {
            LocalStorageManager.borderDefaultLightColor = color ?? Theme.Border.defaultLight.swiftUIColor
        }
    }
    
    func borderSubtleColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.borderSubtleDarkColor = color ?? Theme.Border.subtleDark.swiftUIColor
        } else {
            LocalStorageManager.borderSubtleLightColor = color ?? Theme.Border.subtleLight.swiftUIColor
        }
    }
    
    func statusSuccessColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.statusSuccessDarkColor = color ?? Theme.Status.successDark.swiftUIColor
        } else {
            LocalStorageManager.statusSuccessLightColor = color ?? Theme.Status.successLight.swiftUIColor
        }
    }
    
    func statusOnSuccessColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.statusOnSuccessDarkColor = color ?? Theme.Status.onSuccessDark.swiftUIColor
        } else {
            LocalStorageManager.statusOnSuccessLightColor = color ?? Theme.Status.onSuccessLight.swiftUIColor
        }
    }
    
    func statusSuccessContainerColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.statusSuccessContainerDarkColor = color ?? Theme.Status.successContainerDark.swiftUIColor
        } else {
            LocalStorageManager.statusSuccessContainerLightColor = color ?? Theme.Status.successContainerLight.swiftUIColor
        }
    }
    
    func statusOnSuccessContainerColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.statusOnSuccessContainerDarkColor = color ?? Theme.Status.onSuccessContainerDark.swiftUIColor
        } else {
            LocalStorageManager.statusOnSuccessContainerLightColor = color ?? Theme.Status.onSuccessContainerLight.swiftUIColor
        }
    }
    
    func statusWarningColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.statusWarningDarkColor = color ?? Theme.Status.warningDark.swiftUIColor
        } else {
            LocalStorageManager.statusWarningLightColor = color ?? Theme.Status.warningLight.swiftUIColor
        }
    }
    
    func statusOnWarningColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.statusOnWarningDarkColor = color ?? Theme.Status.onWarningDark.swiftUIColor
        } else {
            LocalStorageManager.statusOnWarningLightColor = color ?? Theme.Status.onWarningLight.swiftUIColor
        }
    }
    
    func statusWarningContainerColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.statusWarningContainerDarkColor = color ?? Theme.Status.warningContainerDark.swiftUIColor
        } else {
            LocalStorageManager.statusWarningContainerLightColor = color ?? Theme.Status.warningContainerLight.swiftUIColor
        }
    }
    
    func statusOnWarningContainerColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.statusOnWarningContainerDarkColor = color ?? Theme.Status.onWarningContainerDark.swiftUIColor
        } else {
            LocalStorageManager.statusOnWarningContainerLightColor = color ?? Theme.Status.onWarningContainerLight.swiftUIColor
        }
    }
    
    func statusErrorColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.statusErrorDarkColor = color ?? Theme.Status.errorDark.swiftUIColor
        } else {
            LocalStorageManager.statusErrorLightColor = color ?? Theme.Status.errorLight.swiftUIColor
        }
    }
    
    func statusOnErrorColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.statusOnErrorDarkColor = color ?? Theme.Status.onErrorDark.swiftUIColor
        } else {
            LocalStorageManager.statusOnErrorLightColor = color ?? Theme.Status.onErrorLight.swiftUIColor
        }
    }
    
    func statusErrorContainerColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.statusErrorContainerDarkColor = color ?? Theme.Status.errorContainerDark.swiftUIColor
        } else {
            LocalStorageManager.statusErrorContainerLightColor = color ?? Theme.Status.errorContainerLight.swiftUIColor
        }
    }
    
    func statusOnErrorContainerColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.statusOnErrorContainerDarkColor = color ?? Theme.Status.onErrorContainerDark.swiftUIColor
        } else {
            LocalStorageManager.statusOnErrorContainerLightColor = color ?? Theme.Status.onErrorContainerLight.swiftUIColor
        }
    }
}
