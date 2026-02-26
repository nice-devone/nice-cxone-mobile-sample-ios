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

class StoreViewModel: AnalyticsReporter, ObservableObject {
    
    // MARK: - Properties
    
    @Published var products = [ProductEntity]()
    @Published var itemsInCart = 0
    @Published var isLoading = true
    @Published var error: Error?
    
    private let getProducts: GetProductsUseCase
    private let getCart: GetCartUseCase
    private let loginWithAmazon: LoginWithAmazonUseCase
    private let signOutWithAmazon: SignOutWithAmazonUseCase
    
    private let coordinator: StoreCoordinator
    
    private var deeplinkOption: DeeplinkOption?
    
    // MARK: - Init
    
    init(
        coordinator: StoreCoordinator,
        deeplinkOption: DeeplinkOption?,
        getProducts: GetProductsUseCase,
        getCart: GetCartUseCase,
        loginWithAmazon: LoginWithAmazonUseCase,
        signOutWithAmazon: SignOutWithAmazonUseCase
    ) {
        self.coordinator = coordinator
        self.deeplinkOption = deeplinkOption
        self.getProducts = getProducts
        self.getCart = getCart
        self.loginWithAmazon = loginWithAmazon
        self.signOutWithAmazon = signOutWithAmazon
        super.init(analyticsTitle: "products?smartphones", analyticsUrl: "/products/smartphones")
    }
    
    // MARK: - Methods
    
    override func onAppear() {
        super.onAppear()
        
        loadCart()
        loadProducts()
        
        if let deeplinkOption = AppDelegate.instance.deeplinkOption {
            Log.trace("Opening chat from from cold start deeplink option: \(deeplinkOption)")
            
            AppDelegate.instance.deeplinkOption = nil
            
            openChat(with: deeplinkOption)
        } else if let deeplinkOption {
            Log.trace("Opening chat from from deeplink option: \(deeplinkOption)")
            
            self.deeplinkOption = nil
            
            openChat(with: deeplinkOption)
        }
    }
}

// MARK: - Actions

extension StoreViewModel {
    
    func signOut() {
        Log.trace("Signing out")
        
        Task { @MainActor [weak self] in
            do {
                try await self?.signOutWithAmazon()
            } catch {
                error.logError()
                
                self?.error = CommonError.failed(L10n.Error.Generic.message)
            }
            
            CXoneChat.signOut()
            LocalStorageManager.reset()
            FileManager.default.eraseDocumentsFolder()
            RemoteNotificationsManager.shared.unregister()
            
            // Reconfigure Logger
            Log.configure(isWriteToFileEnabled: true)
            
            self?.coordinator.popToConfiguration?()
        }
    }
    
    func showSettings() {
        Log.trace("Navigating to the settings view")
        
        coordinator.showSettings()
    }
    
    func openChat(with deeplinkOption: DeeplinkOption? = nil) {
        Log.trace("Opening chat")
        
        coordinator.openChat(modally: LocalStorageManager.chatPresentationStyle != .fullScreen, deeplinkOption: deeplinkOption)
    }
    
    func navigateToCart() {
        Log.trace("Navigating to the cart view")
        
        coordinator.showCart()
    }
    
    func navigateToProduct(_ product: ProductEntity) {
        Log.trace("Navigating to the product view")
        
        coordinator.showProductDetail(product)
    }
}

// MARK: - ChatDelegate

extension StoreViewModel: ChatDelegate {

    @MainActor
    func onConnectionTokenExpired() async {
        LogManager.trace("Connection token expired, retrigger OAuth flow")
        
        do {
            try await self.loginWithAmazon(force: true)
        } catch {
            error.logError()
            
            self.error = CommonError.failed(L10n.Error.Generic.message)
        }
    }
}

// MARK: - Private methods

private extension StoreViewModel {
    
    func loadCart() {
        Log.trace("Loading cart")
        
        itemsInCart = getCart().reduce(0) { $0 + $1.quantity }
    }
    
    func loadProducts() {
        Log.trace("Fetching products for store")
        
        isLoading = true
        
        Task { @MainActor [weak self] in
            guard let self else {
                return
            }
            
            do {
                self.products = try await self.getProducts()
            } catch {
                error.logError()
                
                self.error = CommonError.failed(L10n.Error.Generic.message)
            }
            
            self.isLoading = false
        }
    }
}
