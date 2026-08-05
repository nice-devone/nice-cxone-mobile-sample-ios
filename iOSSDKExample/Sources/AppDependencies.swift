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

import Combine
import CXoneChatSDK
import SwiftUI

@MainActor
class AppDependencies: ObservableObject {

    // MARK: - Properties

    private let router: AppRouter
    private let chatPresenter: ChatPresenter
    private let chatProvider: ChatProvider
    private let productsRepository: ProductsRepository
    private let cartRepository: CartRepository
    private let getProducts: GetProductsUseCase
    private let getCart: GetCartUseCase
    private let addProductToCart: AddProductToCartUseCase
    private let removeProductFromCart: RemoveProductFromCartUseCase
    private let checkoutCart: CheckoutCartUseCase
    private let getChannelConfiguration: GetChannelConfigurationUseCase
    private let googleSignIn: GoogleSignInUseCase

    private var configurationViewModel: ConfigurationViewModel?
    private var loginViewModel: LoginViewModel?
    private var storeViewModel: StoreViewModel?
    private var settingsViewModel: SettingsViewModel?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(router: AppRouter, chatPresenter: ChatPresenter) {
        guard let productsRepository = ProductsRepositoryImpl(session: .shared) else {
            fatalError("Embedded products.json catalogue is missing from the bundle — check the Resources phase in sample/xcodegen and rerun xcodegen.")
        }

        self.productsRepository = productsRepository
        self.cartRepository = CartRepositoryImpl()
        self.router = router
        self.chatPresenter = chatPresenter
        self.chatProvider = chatPresenter.chatProvider

        self.getProducts = GetProductsUseCase(repository: productsRepository)
        self.getCart = GetCartUseCase(repository: cartRepository)
        self.addProductToCart = AddProductToCartUseCase(repository: cartRepository)
        self.removeProductFromCart = RemoveProductFromCartUseCase(repository: cartRepository)
        self.checkoutCart = CheckoutCartUseCase(repository: cartRepository)
        self.getChannelConfiguration = GetChannelConfigurationUseCase(chatProvider: chatProvider)
        self.googleSignIn = GoogleSignInUseCase(chatProvider: chatProvider)

        // Invalidate cached view models on root transitions so a fresh instance is built
        // on next entry. Each VM is rebuilt on any transition *out of* its own root and
        // reused while it is the current root, so `RootView.body` re-evaluations
        // (triggered for example by pushing `.settings` onto `router.path`) do not hand
        // the view a fresh VM with default `@Published` state. For `ConfigurationView`
        // this prevented the `customConfiguration.title` dropdown from reverting to a
        // zero-width empty-label button on iOS 16; for `LoginView` it prevents
        // `isLoading=true` from resetting and re-firing `prepareAndFetchConfiguration`
        // (which would re-run `registerIfNeeded`, `connection.prepare`, and
        // `getChannelConfiguration`) every time the user returns from `.settings`.
        router.$root
            .sink { [weak self] root in
                switch root {
                case .configuration:
                    self?.loginViewModel = nil
                    self?.storeViewModel = nil
                    self?.settingsViewModel = nil
                case .login:
                    self?.configurationViewModel = nil
                    self?.storeViewModel = nil
                    self?.settingsViewModel = nil
                case .store:
                    self?.configurationViewModel = nil
                    self?.loginViewModel = nil
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Methods

    @MainActor
    func getConfigurationViewModel() -> ConfigurationViewModel {
        if let configurationViewModel {
            return configurationViewModel
        }

        let viewModel = ConfigurationViewModel(router: router, chatProvider: chatProvider)
        self.configurationViewModel = viewModel

        return viewModel
    }

    @MainActor
    func getLoginViewModel(configuration: Configuration) -> LoginViewModel {
        // The cached instance is keyed on `configuration` so that switching configurations
        // (e.g. user returns to `.configuration`, edits brand/channel, then re-enters
        // `.login`) still produces a fresh VM. In normal flow the sink above already nils
        // the cache on the `.configuration` round-trip, but the equality check is the
        // authoritative guard.
        if let loginViewModel, loginViewModel.configuration == configuration {
            return loginViewModel
        }

        let viewModel = LoginViewModel(
            router: router,
            chatProvider: chatProvider,
            configuration: configuration,
            getChannelConfiguration: getChannelConfiguration,
            googleSignIn: googleSignIn
        )
        self.loginViewModel = viewModel

        return viewModel
    }

    @MainActor
    func getStoreViewModel() -> StoreViewModel {
        if let storeViewModel {
            return storeViewModel
        }

        let viewModel = StoreViewModel(
            router: router,
            chatPresenter: chatPresenter,
            chatProvider: chatProvider,
            deeplinkOption: router.pendingDeeplink,
            getProducts: getProducts,
            getCart: getCart
        )
        self.storeViewModel = viewModel

        return viewModel
    }

    @MainActor
    func getSettingsViewModel() -> SettingsViewModel {
        // Cached for the same reason as the root VMs above: `RootView` re-evaluates
        // `destination(for: .settings)` on body updates, and a fresh instance would reset the
        // transient `colorDidChange` flag to `false`. On iOS 16 that caused the chat theme not to
        // be rebuilt after a Reset (the `onDisappear` -> `onColorChanged` hand-off was gated behind
        // `colorDidChange`, which the recreated instance had lost).
        if let settingsViewModel {
            return settingsViewModel
        }

        let viewModel = SettingsViewModel(onColorChanged: chatPresenter.onChatStyleChanged)
        self.settingsViewModel = viewModel

        return viewModel
    }

    @MainActor
    func getProductDetailViewModel(product: ProductEntity) -> ProductDetailViewModel {
        ProductDetailViewModel(
            router: router,
            chatProvider: chatProvider,
            product: product,
            getCart: getCart,
            addProductToCart: addProductToCart
        )
    }

    @MainActor
    func getCartViewModel() -> CartViewModel {
        CartViewModel(
            router: router,
            getCart: getCart,
            addProductToCart: addProductToCart,
            removeProductFromCart: removeProductFromCart,
            chatProvider: chatProvider
        )
    }

    @MainActor
    func getPaymentViewModel() -> PaymentViewModel {
        PaymentViewModel(router: router, chatProvider: chatProvider, getCart: getCart, checkoutCart: checkoutCart)
    }

    @MainActor
    func getPaymentDoneViewModel() -> PaymentDoneViewModel {
        PaymentDoneViewModel(router: router, chatProvider: chatProvider)
    }
}
