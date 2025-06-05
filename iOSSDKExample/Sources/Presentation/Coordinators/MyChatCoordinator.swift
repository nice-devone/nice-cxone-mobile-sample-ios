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
import Swinject
import UIKit

class MyChatCoordinator: ChatCoordinator {

    // MARK: - Init
    
    init() {
        #warning("Re-enable after 3.0.0 release")
        // super.init(chatStyle: ChatAppearance.getChatStyle())
        super.init()
    }
    
    // MARK: - Methods
    
    func start(with deepLinkOption: DeeplinkOption? = nil, modally: Bool, in parentViewController: UIViewController, onFinish: (() -> Void)? = nil) {
        Log.trace("Starting chat")
        
        provideAdditionalCustomFieldsIfNeeded()
        
        let threadToOpen: UUID?

        if case .thread(let uuid) = deepLinkOption {
            threadToOpen = uuid
        } else {
            threadToOpen = nil
        }

        start(
            threadId: threadToOpen,
            in: parentViewController,
            presentModally: modally,
            onFinish: onFinish
        )
    }
}

// MARK: - Helpers

private extension MyChatCoordinator {
 
    func provideAdditionalCustomFieldsIfNeeded() {
        // Reset custom fields
        chatConfiguration.additionalContactCustomFields = [:]
        chatConfiguration.additionalCustomerCustomFields = [:]
        
        if let customFields = LocalStorageManager.additionalContactCustomFields, !customFields.isEmpty {
            Log.trace("Providing additional contact custom fields")
            
            chatConfiguration.additionalContactCustomFields = customFields
        }
        if let customFields = LocalStorageManager.additionalCustomerCustomFields, !customFields.isEmpty {
            Log.trace("Providing additional customer custom fields")
            
            chatConfiguration.additionalCustomerCustomFields = customFields
        }
    }
}
