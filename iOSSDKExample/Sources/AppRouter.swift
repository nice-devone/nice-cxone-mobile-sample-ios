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

@MainActor
class AppRouter: ObservableObject {
    
    // MARK: - Nested Types
    
    enum Root {
        
        // MARK: - Cases
        
        case configuration
        case login(Configuration)
        case store
    }
    
    // MARK: - Properties
    
    @Published var root: Root
    @Published var path = NavigationPath()
    
    /// Deeplink received before the user has reached the store screen. `StoreViewModel`
    /// reads it on construction and opens chat from `onAppear`. Deliberately a plain
    /// `var` (not `@Published`): the value is consumed once at the moment `StoreViewModel`
    /// is built — observers don't need to react to mid-session mutations.
    var pendingDeeplink: DeeplinkOption?
    
    // nonisolated(unsafe): AppRouter is @MainActor-isolated, but Swift 6 makes deinit
    // nonisolated, so the @MainActor property cannot be accessed there without this annotation.
    // Safe because the property is written once during init (on the main actor) and read once
    // in deinit (last reference — no concurrent access is possible at that point).
    nonisolated(unsafe) private var deeplinkObserver: NSObjectProtocol?
    
    private let chatPresenter: any ChatPresenting

    // MARK: - Init

    init(chatPresenter: any ChatPresenting) {
        self.chatPresenter = chatPresenter
        
        if let configuration = LocalStorageManager.configuration {
            root = .login(configuration)
        } else {
            root = .configuration
        }
        
        deeplinkObserver = NotificationCenter.default.addObserver(
            forName: .cxoneDeeplinkNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            // Extract value before the isolated hop so the non-Sendable `Notification`
            // is not captured across the isolation boundary.
            let option = notification.object as? DeeplinkOption
            // `queue: .main` above guarantees this block runs on the main thread, which is
            // the main actor's executor — `MainActor.assumeIsolated` is safe and synchronous.
            //
            // Do not replace with `Task { @MainActor in … }` or `await MainActor.run { … }`:
            // both defer to a later run-loop turn, between which `chatPresenter.isPresented`
            // / `self.root` can change, so the routing decision would read stale state and
            // dispatch incorrectly. The synchronous hop is load-bearing.
            MainActor.assumeIsolated {
                guard let self, let option else {
                    return
                }

                self.dispatch(option)
            }
        }
    }
    
    deinit {
        if let deeplinkObserver {
            NotificationCenter.default.removeObserver(deeplinkObserver)
        }
    }
    
    // MARK: - Navigation
    
    func showConfiguration() {
        root = .configuration
        path = NavigationPath()
    }
    
    func showLogin(_ configuration: Configuration) {
        if case .configuration = root {
            path.append(AppRoute.login(configuration))
        } else {
            root = .login(configuration)
            path = NavigationPath()
        }
    }
    
    /// Switch the root to `.store`. Chat (if any pending deeplink) is opened from
    /// `StoreViewModel.onAppear` once `StoreView` is in the view hierarchy.
    func showStore() {
        root = .store
        path = NavigationPath()
    }
    
    func showSettings() {
        path.append(AppRoute.settings)
    }
    
    func showProductDetail(_ product: ProductEntity) {
        path.append(AppRoute.productDetail(product))
    }
    
    func showCart() {
        path.append(AppRoute.cart)
    }
    
    func showPayment() {
        path.append(AppRoute.payment)
    }
    
    func showPaymentDone() {
        path.append(AppRoute.paymentDone)
    }
    
    func returnToStore() {
        path = NavigationPath()
    }
    
    // MARK: - Deep Link
    
    func handleDeepLink(_ url: URL) {
        guard let option = ThreadsDeeplinkHandler.handleUrl(url) else {
            return
        }
        
        dispatch(option)
        
        // External-URL taps imply explicit user intent — auto-advance to login if a saved
        // configuration exists and the user is still on the configuration screen. The
        // notification observer deliberately does *not* do this: a push notification fires
        // without user input and should respect whatever screen the user is currently on.
        if case .configuration = root, let config = LocalStorageManager.configuration {
            showLogin(config)
        }
    }
}

// MARK: - Private methods

private extension AppRouter {

    /// Shared three-way deeplink dispatch used by both the `cxoneDeeplinkNotification`
    /// observer and `handleDeepLink(_:)`.
    func dispatch(_ option: DeeplinkOption) {
        if chatPresenter.isPresented, case .thread(let id) = option {
            NotificationCenter.default.postThreadDeeplinkNotification(threadId: id)
        } else if case .store = root {
            chatPresenter.open(deeplinkOption: option)
        } else {
            pendingDeeplink = option
        }
    }
}
