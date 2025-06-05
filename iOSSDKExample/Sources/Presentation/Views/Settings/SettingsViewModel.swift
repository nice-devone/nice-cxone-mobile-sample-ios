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
    
    func colorDidChange(color: Color?, for title: String) {
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
        case L10n.Settings.Theme.Primary.placeholder:
            primaryColorChanged(color)
        case L10n.Settings.Theme.OnPrimary.placeholder:
            onPrimaryColorChanged(color)
        case L10n.Settings.Theme.Background.placeholder:
            backgroundColorChanged(color)
        case L10n.Settings.Theme.OnBackground.placeholder:
            onBackgroundColorChanged(color)
        case L10n.Settings.Theme.Accent.placeholder:
            accentColorChanged(color)
        case L10n.Settings.Theme.OnAccent.placeholder:
            onAccentColorChanged(color)
        case L10n.Settings.Theme.AgentBackground.placeholder:
            agentBackgroundColorChanged(color)
        case L10n.Settings.Theme.AgentText.placeholder:
            agentTextColorChanged(color)
        case L10n.Settings.Theme.CustomerBackground.placeholder:
            customerBackgroundColorChanged(color)
        case L10n.Settings.Theme.CustomerText.placeholder:
            customerTextColorChanged(color)
        default:
            return
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
    
    func primaryColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.primaryDarkColor = color ?? Theme.primary.swiftUIColor
        } else {
            LocalStorageManager.primaryLightColor = color ?? Theme.primaryDark.swiftUIColor
        }
    }

    func onPrimaryColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.onPrimaryDarkColor = color ?? Theme.onPrimary.swiftUIColor
        } else {
            LocalStorageManager.onPrimaryLightColor = color ?? Theme.onPrimaryDark.swiftUIColor
        }
    }

    func backgroundColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.backgroundDarkColor = color ?? Theme.background.swiftUIColor
        } else {
            LocalStorageManager.backgroundLightColor = color ?? Theme.backgroundDark.swiftUIColor
        }
    }

    func onBackgroundColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.onBackgroundDarkColor = color ?? Theme.onBackground.swiftUIColor
        } else {
            LocalStorageManager.onBackgroundLightColor = color ?? Theme.onBackgroundDark.swiftUIColor
        }
    }

    func accentColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.accentDarkColor = color ?? Theme.accent.swiftUIColor
        } else {
            LocalStorageManager.accentLightColor = color ?? Theme.accentDark.swiftUIColor
        }
    }

    func onAccentColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.onAccentDarkColor = color ?? Theme.onAccent.swiftUIColor
        } else {
            LocalStorageManager.onAccentLightColor = color ?? Theme.onAccentDark.swiftUIColor
        }
    }

    func agentBackgroundColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.agentBackgroundDarkColor = color ?? Theme.agentBackground.swiftUIColor
        } else {
            LocalStorageManager.agentBackgroundLightColor = color ?? Theme.agentBackgroundDark.swiftUIColor
        }
    }
    
    func agentTextColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.agentTextDarkColor = color ?? Theme.agentText.swiftUIColor
        } else {
            LocalStorageManager.agentTextLightColor = color ?? Theme.agentTextDark.swiftUIColor
        }
    }
    
    func customerBackgroundColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.customerBackgroundDarkColor = color ?? Theme.customerBackground.swiftUIColor
        } else {
            LocalStorageManager.customerBackgroundLightColor = color ?? Theme.customerBackgroundDark.swiftUIColor
        }
    }
    
    func customerTextColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.customerTextDarkColor = color ?? Theme.customerText.swiftUIColor
        } else {
            LocalStorageManager.customerTextLightColor = color ?? Theme.customerTextDark.swiftUIColor
        }
    }
}
