//
// Copyright (c) 2021-2026. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-sample-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN "AS IS" BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

import CXoneChatSDK
import CXoneChatUI
import SwiftUI

@MainActor
class StoreViewModel: AnalyticsReporter, ObservableObject {
    
    // MARK: - Properties
    
    @Published var products = [ProductEntity]()
    @Published var itemsInCart = 0
    @Published var isLoading = true
    @Published var error: Error?

    private let getProducts: GetProductsUseCase
    private let getCart: GetCartUseCase

    private let router: AppRouter
    private let chatPresenter: ChatPresenter

    private var deeplinkOption: DeeplinkOption?

    // MARK: - Init

    init(
        router: AppRouter,
        chatPresenter: ChatPresenter,
        chatProvider: ChatProvider,
        deeplinkOption: DeeplinkOption?,
        getProducts: GetProductsUseCase,
        getCart: GetCartUseCase
    ) {
        self.router = router
        self.chatPresenter = chatPresenter
        self.deeplinkOption = deeplinkOption
        self.getProducts = getProducts
        self.getCart = getCart
        super.init(chatProvider: chatProvider, analyticsTitle: "products?smartphones", analyticsUrl: "/products/smartphones")
    }

    // MARK: - Methods

    override func onAppear() {
        super.onAppear()

        loadCart()
        loadProducts()

        if let deeplinkOption {
            Log.trace("Opening chat from deeplink option: \(deeplinkOption)")

            self.deeplinkOption = nil

            openChat(with: deeplinkOption)
        }
    }
}

// MARK: - Actions

extension StoreViewModel {
    
    func signOut() {
        Log.trace("Signing out")

        ChatSessionReset.perform(chatProvider: chatProvider)

        router.showConfiguration()
    }

    func showSettings() {
        Log.trace("Navigating to the settings view")

        router.showSettings()
    }

    func openChat(with deeplinkOption: DeeplinkOption? = nil) {
        Log.trace("Opening chat")

        chatPresenter.open(deeplinkOption: deeplinkOption)
    }

    func navigateToCart() {
        Log.trace("Navigating to the cart view")

        router.showCart()
    }

    func navigateToProduct(_ product: ProductEntity) {
        Log.trace("Navigating to the product view")

        router.showProductDetail(product)
    }

    /// Called when the explicit-PKCE session's refresh-grant recovery fails and no further
    /// automatic recovery is possible - the persisted flow is no longer usable, so clear it and
    /// send the customer back to interactive login rather than letting `restoreSession()` retry
    /// the same rejected credential on next launch.
    func handleSessionExpired() {
        Log.trace("Explicit OAuth session expired - returning to login")

        LocalStorageManager.oAuthFlow = nil

        router.showLoginOrConfiguration()
    }
}

// MARK: - Private methods

private extension StoreViewModel {
    
    func loadCart() {
        Log.trace("Loading cart")
        
        itemsInCart = getCart().itemCount
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
