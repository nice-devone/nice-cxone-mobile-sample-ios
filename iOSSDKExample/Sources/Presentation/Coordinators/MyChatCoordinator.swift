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

import CXoneChatUI
import SwiftUI
import Swinject
import UIKit

class MyChatCoordinator: ChatCoordinator {

    // MARK: - Init
    
    init(navigationController: UINavigationController) {
        super.init(chatStyle: ChatStyle.initFromChatAppearance(), chatLocalization: ChatLocalization())

        LogManager.configure(level: .trace, verbosity: .full)
        LogManager.delegate = self
    }
    
    // MARK: - Methods
    
    func start(with deepLinkOption: DeeplinkOption? = nil, in parentViewController: UIViewController) {
        Log.trace("Starting chat")
        
        let threadToOpen: String?

        if case .thread(let uuid) = deepLinkOption {
            threadToOpen = uuid
        } else {
            threadToOpen = nil
        }

        start(threadId: threadToOpen, in: parentViewController)
    }
}

// MARK: - LogDelegate

extension MyChatCoordinator: LogDelegate {
    
    func logError(_ message: String) {
        Log.message("[UI] \(message)")
    }

    func logWarning(_ message: String) {
        Log.message("[UI] \(message)")
    }

    func logInfo(_ message: String) {
        Log.message("[UI] \(message)")
    }

    func logTrace(_ message: String) {
        Log.message("[UI] \(message)")
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
            buttonBackgroundColor: ChatAppearance.buttonBackgroundColor
        )
    }
}
