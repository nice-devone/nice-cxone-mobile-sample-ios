//
// Copyright (c) 2021-2023. NICE Ltd. All rights reserved.
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
import SwiftUI
import UIKit

class SettingsViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var firstName = LocalStorageManager.firstName
    @Published var lastName = LocalStorageManager.lastName
    @Published var presentingBrandLogoActionSheet = false
    @Published var shouldShareLogs = false
    @Published var showingFileManager = false
    @Published var showingImagePicker = false
    @Published var showRemoveLogsAlert = false
    @Published var showInvalidColorError = false
    
    static let brandLogoFileName = "brandLogo.png"
    
    var brandLogo: UIImage?
    var invalidColorTitle: String?
    
    let sdkVersion = CXoneChat.version
    
    var navigationBarColor: Color { ChatAppearance.navigationBarColor }
    var navigationBarElementsColor: Color { ChatAppearance.navigationBarElementsColor }
    var backgroundColor: Color { ChatAppearance.backgroundColor }
    var agentCellColor: Color { ChatAppearance.agentCellColor }
    var customerCellColor: Color { ChatAppearance.customerCellColor }
    var agentFontColor: Color { ChatAppearance.agentFontColor }
    var customerFontColor: Color { ChatAppearance.customerFontColor }
    var formTextColor: Color { ChatAppearance.formTextColor }
    var formErrorColor: Color { ChatAppearance.formErrorColor }
    var buttonTextColor: Color { ChatAppearance.buttonTextColor }
    var buttonBackgroundColor: Color { ChatAppearance.buttonBackgroundColor }
    
    // MARK: - Functions
    
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
    
    func getBrandLogoImage() -> Image {
        Log.trace("Loading brand logo from documents directory")
        
        if let image = try? UIImage.load(Self.brandLogoFileName, from: .documentDirectory) {
            self.brandLogo = image
            
            return Image(uiImage: image)
        } else {
            return Asset.Settings.brandLogoPlaceholder
        }
    }
    
    func removeBrandLogo() {
        Log.trace("Removing brand logo from documents directory")
        
        do {
            try FileManager.default.removeFileInDocuments(named: Self.brandLogoFileName)
            
            self.brandLogo = nil
        } catch {
            error.logError()
        }
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
        
        switch title {
        case L10n.Settings.Theme.ChatNavigationBarColorField.placeholder:
            onNavigationBarColorChanged(color)
        case L10n.Settings.Theme.ChatNavigationElementsColorField.placeholder:
            onNavigationElementsColorChanged(color)
        case L10n.Settings.Theme.ChatBackgroundColorField.placeholder:
            onBackgroundColorChanged(color)
        case L10n.Settings.Theme.ChatAgentCellColorField.placeholder:
            onAgentCellColorChanged(color)
        case L10n.Settings.Theme.ChatCustomerCellColorField.placeholder:
            onCustomerCellColorChanged(color)
        case L10n.Settings.Theme.ChatAgentFontColorField.placeholder:
            onAgentFontColorChanged(color)
        case L10n.Settings.Theme.ChatCustomerFontColorField.placeholder:
            onCustomerFontColorChanged(color)
        case L10n.Settings.Theme.ChatFormTextColor.placeholder:
            onChatFormTextColorChanged(color)
        case L10n.Settings.Theme.ChatFormErrorColor.placeholder:
            onChatFormErrorColorChanged(color)
        case L10n.Settings.Theme.ChatButtonTextColor.placeholder:
            onButtonTextColorChanged(color)
        case L10n.Settings.Theme.ChatButtonBackgroundColor.placeholder:
            onButtonBackgroundColorChanged(color)
        default:
            return
        }
    }
    
    func restoreCustomerName() {
        firstName = nil
        lastName = nil
        LocalStorageManager.firstName = nil
        LocalStorageManager.lastName = nil
    }
}

// MARK: - Private methods

private extension SettingsViewModel {
    
    func onNavigationBarColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.chatNavigationBarDarkColor = color
        } else {
            LocalStorageManager.chatNavigationBarLightColor = color ?? Color(.systemBackground)
        }
    }

    func onNavigationElementsColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.chatNavigationElementsDarkColor = color ?? Color(.systemBlue)
        } else {
            LocalStorageManager.chatNavigationElementsLightColor = color ?? Color(.systemBlue)
        }
    }

    func onBackgroundColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.chatBackgroundDarkColor = color ?? Color(.systemBackground)
        } else {
            LocalStorageManager.chatBackgroundLightColor = color ?? Color(.systemBackground)
        }
    }

    func onAgentCellColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.chatAgentCellDarkColor = color ?? Color(.lightGray)
        } else {
            LocalStorageManager.chatAgentCellLightColor = color ?? Color(.lightGray)
        }
    }

    func onCustomerCellColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.chatCustomerCellDarkColor = color ?? Color(.systemBlue)
        } else {
            LocalStorageManager.chatCustomerCellLightColor = color ?? Color(.systemBlue)
        }
    }

    func onAgentFontColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.chatAgentFontDarkColor = color ?? .black
        } else {
            LocalStorageManager.chatAgentFontLightColor = color ?? .black
        }
    }

    func onCustomerFontColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.chatCustomerFontDarkColor = color ?? .white
        } else {
            LocalStorageManager.chatCustomerFontLightColor = color ?? .white
        }
    }
    
    func onChatFormTextColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.chatFormTextDarkColor = color ?? .black
        } else {
            LocalStorageManager.chatFormTextLightColor = color ?? .black
        }
    }
    
    func onChatFormErrorColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.chatFormErrorDarkColor = color ?? .red
        } else {
            LocalStorageManager.chatFormErrorLightColor = color ?? .red
        }
    }
    
    func onButtonTextColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.chatButtonTextDarkColor = color ?? .accentColor
        } else {
            LocalStorageManager.chatButtonTextLightColor = color ?? .accentColor
        }
    }
    
    func onButtonBackgroundColorChanged(_ color: Color?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.chatButtonBackgroundDarkColor = color ?? .white
        } else {
            LocalStorageManager.chatButtonBackgroundLightColor = color ?? .white
        }
    }
}
