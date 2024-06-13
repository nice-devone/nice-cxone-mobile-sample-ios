//
// Copyright (c) 2021-2024. NICE Ltd. All rights reserved.
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
import Swinject
import UIKit

class ChatCoordinator: Coordinator {

    // MARK: - Properties

    private let defaultChatCoordinator: DefaultChatCoordinator
    
    var popToConfiguration: (() -> Void)?
    
    // MARK: - Init
    
    override init(navigationController: UINavigationController) {
        self.defaultChatCoordinator = DefaultChatCoordinator(navigationController: navigationController)
        super.init(navigationController: navigationController)
        
        CXoneChatUI.LogManager.configure(level: .trace, verbosity: .full)
    }
    
    // MARK: - Methods
    
    func start(with deeplinkOption: DeeplinkOption?) {
        navigationController.setCustomAppearance()
        defaultChatCoordinator.chatLocalization = ChatLocalization()
        defaultChatCoordinator.style = ChatStyle.initFromChatAppearance()

        if let customerIdentity = CXoneChat.shared.customer.get(), customerIdentity.fullName?.isEmpty == false {
            LocalStorageManager.firstName = customerIdentity.firstName
            LocalStorageManager.lastName = customerIdentity.lastName
            
            startChat(deeplinkOption: deeplinkOption)
        } else if LocalStorageManager.firstName?.isEmpty == false || LocalStorageManager.lastName?.isEmpty == false {
            CXoneChat.shared.customer.setName(firstName: LocalStorageManager.firstName ?? "", lastName: LocalStorageManager.lastName ?? "")
            
            startChat(deeplinkOption: deeplinkOption)
        } else {
            let entities: [FormCustomFieldType] = [
                TextFieldEntity(label: L10n.ThreadList.NewThread.UserDetails.firstName, isRequired: true, ident: "firstName", isEmail: false),
                TextFieldEntity(label: L10n.ThreadList.NewThread.UserDetails.lastName, isRequired: true, ident: "lastName", isEmail: false)
            ]

            defaultChatCoordinator.presentForm(title: L10n.ThreadList.NewThread.UserDetails.title, customFields: entities) { [weak self] customFields in
                self?.setCustomerName(from: customFields)
                
                self?.startChat(deeplinkOption: deeplinkOption)
            }
        }
    }
}

// MARK: - Private methods

private extension ChatCoordinator {

    func setCustomerName(from customFields: [String: String]) {
        let firstName = customFields.first { $0.key == "firstName" }.map(\.value) ?? ""
        let lastName = customFields.first { $0.key == "lastName" }.map(\.value) ?? ""
        
        if !firstName.isEmpty {
            LocalStorageManager.firstName = firstName
        }
        if !lastName.isEmpty {
            LocalStorageManager.lastName = lastName
        }
        
        CXoneChat.shared.customer.setName(firstName: firstName, lastName: lastName)
    }
    
    func startChat(deeplinkOption: DeeplinkOption?) {
        let threadIdToOpen = deeplinkOption.map { option -> UUID? in
            guard case .thread(let threadId) = option else {
                return nil
            }
            
            return threadId
        } ?? nil
        
        defaultChatCoordinator.start(threadIdToOpen: threadIdToOpen) { [weak navigationController] in
            navigationController?.setNormalAppearance()
        }
    }
}

// MARK: - LogDelegate

extension ChatCoordinator: CXoneChatUI.LogDelegate {
    
    func logError(_ message: String) {
        Log.message("[CXoneChatUI] \(message)")
    }

    func logWarning(_ message: String) {
        Log.message("[CXoneChatUI] \(message)")
    }

    func logInfo(_ message: String) {
        Log.message("[CXoneChatUI] \(message)")
    }

    func logTrace(_ message: String) {
        Log.message("[CXoneChatUI] \(message)")
    }
}

// MARK: - Helpers

private extension ChatStyle {
    
    static func initFromChatAppearance() -> ChatStyle {
        ChatStyle(
            navigationBarColor: ChatAppearance.navigationBarColor,
            navigationBarElementsColor: ChatAppearance.navigationBarElementsColor,
            backgroundColor: ChatAppearance.backgroundColor,
            agentCellColor: ChatAppearance.agentCellColor,
            agentFontColor: ChatAppearance.agentFontColor,
            customerCellColor: ChatAppearance.customerCellColor,
            customerFontColor: ChatAppearance.customerFontColor,
            formTextColor: ChatAppearance.formTextColor,
            formErrorColor: ChatAppearance.formErrorColor,
            buttonTextColor: ChatAppearance.buttonTextColor,
            buttonBackgroundColor: ChatAppearance.buttonBackgroundColor,
            navigationBarLogo: try? Image(uiImage: UIImage.load(SettingsViewModel.brandLogoFileName, from: .documentDirectory))
        )
    }
}
