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

import SwiftUI
import Swinject
import UIKit

class StoreCoordinator: Coordinator {
    
    // MARK: - Properties
    
    let chatCoordinator: MyChatCoordinator

    var popToConfiguration: (() -> Void)?
    
    // MARK: - Init
    
    override init(navigationController: UINavigationController) {
        chatCoordinator = MyChatCoordinator(navigationController: navigationController)

        super.init(navigationController: navigationController)

        navigationController.setNormalAppearance()
    }
    
    // MARK: - Methods
    
    func start(with deeplinkOption: DeeplinkOption?) {
        // swiftlint:disable:next force_unwrapping
        let controller = UIHostingController(rootView: resolver.resolve(StoreView.self, argument: deeplinkOption)!)
        
        navigationController.setViewControllers([controller], animated: true)
    }
}

// MARK: - Navigation

// swiftlint:disable force_unwrapping
extension StoreCoordinator {
    
    func showSettings() {
        let controller = UIHostingController(rootView: resolver.resolve(SettingsView.self)!)

        navigationController.show(controller, sender: self)
    }
    
    func showProductDetail(_ product: ProductEntity) {
        let controller = UIHostingController(rootView: resolver.resolve(ProductDetailView.self, argument: product)!)
        
        navigationController.show(controller, sender: self)
    }
    
    func showCart() {
        let controller = UIHostingController(rootView: resolver.resolve(CartView.self)!)
        
        navigationController.show(controller, sender: self)
    }
    
    func showPayment() {
        let controller = UIHostingController(rootView: resolver.resolve(PaymentView.self)!)
        
        navigationController.show(controller, sender: self)
    }
    
    func showPaymentDone() {
        let controller = UIHostingController(rootView: resolver.resolve(PaymentDoneView.self)!)
        
        navigationController.show(controller, sender: self)
    }
    
    func showConfiguration() {
        let controller = UIHostingController(rootView: resolver.resolve(ConfigurationView.self)!)
        
        navigationController.setViewControllers([controller], animated: true)
    }
    
    func openChat(deeplinkOption: DeeplinkOption?) {
        chatCoordinator.start(with: deeplinkOption, in: navigationController)
    }
}
// swiftlint:enable force_unwrapping
