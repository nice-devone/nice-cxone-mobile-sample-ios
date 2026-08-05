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

import SwiftUI

struct RootView: View {

    // MARK: - Properties

    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var dependencies: AppDependencies

    // MARK: - Builder

    var body: some View {
        NavigationStack(path: $router.path) {
            rootContent
                .navigationDestination(for: AppRoute.self) { route in
                    destination(for: route)
                }
        }
    }
}

// MARK: - Subviews

private extension RootView {

    @ViewBuilder
    var rootContent: some View {
        switch router.root {
        case .configuration:
            ConfigurationView(viewModel: dependencies.getConfigurationViewModel())

        case .login(let configuration):
            LoginView(viewModel: dependencies.getLoginViewModel(configuration: configuration))

        case .store:
            StoreView(viewModel: dependencies.getStoreViewModel())
                .onAppear {
                    // `getStoreViewModel()` already snapshotted `pendingDeeplink` into the
                    // returned `StoreViewModel`; clear it here so a later notification arriving
                    // while at `.store` triggers `chatPresenter.open(...)` instead of being
                    // queued again.
                    router.pendingDeeplink = nil
                }
        }
    }

    @ViewBuilder
    func destination(for route: AppRoute) -> some View {
        switch route {
        case .login(let configuration):
            LoginView(viewModel: dependencies.getLoginViewModel(configuration: configuration))

        case .settings:
            SettingsView(viewModel: dependencies.getSettingsViewModel())

        case .productDetail(let product):
            ProductDetailView(viewModel: dependencies.getProductDetailViewModel(product: product))

        case .cart:
            CartView(viewModel: dependencies.getCartViewModel())

        case .payment:
            PaymentView(viewModel: dependencies.getPaymentViewModel())

        case .paymentDone:
            PaymentDoneView(viewModel: dependencies.getPaymentDoneViewModel())
        }
    }
}
