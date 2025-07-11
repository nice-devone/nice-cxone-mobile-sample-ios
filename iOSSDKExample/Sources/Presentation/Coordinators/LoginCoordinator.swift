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
import Swinject
import UIKit

class LoginCoordinator: Coordinator {
    
    // MARK: - Properties
    
    var storeCoordinator: StoreCoordinator {
        subCoordinators
        // swiftlint:disable:next force_cast
            .first { $0 is StoreCoordinator } as! StoreCoordinator
    }
    // periphery:ignore - will be used after the release 3.0.0
    var chatCoordinator: ChatCoordinator {
        storeCoordinator.chatCoordinator
    }
    
    // MARK: - Init
    
    override init(navigationController: UINavigationController) {
        super.init(navigationController: navigationController)
        
        let storeCoordinator = StoreCoordinator(navigationController: navigationController)
        storeCoordinator.assembler = self.assembler
        subCoordinators.append(storeCoordinator)
        
        navigationController.navigationBar.prefersLargeTitles = true
        
        storeCoordinator.popToConfiguration = { [weak self] in
            self?.showConfiguration()
        }
    }
    
    // MARK: - Methods
    
    func start(with deeplinkOption: DeeplinkOption? = nil) {
        navigationController.viewControllers.removeAll()
        isActive = true
        
        if let configuration = LocalStorageManager.configuration {
            Log.trace("Configuration found in local storage, showing login screen with deeplink: \(String(describing: deeplinkOption))")
            
            showLogin(configuration: configuration, deeplinkOption: deeplinkOption)
        } else {
            Log.trace("No configuration found in local storage, showing configuration screen")
            
            showConfiguration()
        }
    }
}

// MARK: - Navigation

extension LoginCoordinator {
    
    func showSettings() {
        let onColorChanged: () -> Void = {
            #warning("Re-enable after 3.0.0 release")
            // chatCoordinator?.chatStyle = ChatAppearance.getChatStyle()
        }
        // swiftlint:disable:next force_unwrapping
        let controller = UIHostingController(rootView: resolver.resolve(SettingsView.self, argument: onColorChanged)!)

        navigationController.show(controller, sender: self)
    }
    
    func showConfiguration() {
        // swiftlint:disable:next force_unwrapping
        let controller = UIHostingController(rootView: resolver.resolve(ConfigurationView.self)!)
        
        navigationController.setViewControllers([controller], animated: true)
    }
    
    func showLogin(configuration: Configuration, deeplinkOption: DeeplinkOption? = nil) {
        // swiftlint:disable:next force_unwrapping
        let controller = UIHostingController(rootView: resolver.resolve(LoginView.self, arguments: configuration, deeplinkOption)!)
        
        navigationController.show(controller, sender: self)
    }
    
    func showDashboard(deeplinkOption: DeeplinkOption?) {
        isActive = false
        
        storeCoordinator.start(with: deeplinkOption)
    }
}
