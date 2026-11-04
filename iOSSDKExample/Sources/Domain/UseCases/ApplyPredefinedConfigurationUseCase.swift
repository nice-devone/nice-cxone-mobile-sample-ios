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
import Foundation

/// Applies a channel configuration supplied through the launch environment, then routes to login.
///
/// Persistence goes through `LocalStorageManager.configuration` — the same property
/// `ConfigurationViewModel` writes — so preparation, caching and SDK behaviour downstream are
/// identical to a configuration entered by hand.
///
/// Single owner of the *ordering* of these steps, which is easy to get wrong: the session reset wipes
/// all local storage, so the new configuration and guest identity have to be written afterwards.
///
/// - Note: Called from `SDKDemoApp.init()` only. The provider has therefore never been prepared and
///     chat cannot be presented yet, so there is nothing to disconnect or dismiss here — but a
///     configuration *persisted by a previous launch* may well need tearing down.
@MainActor
final class ApplyPredefinedConfigurationUseCase {

    // MARK: - Properties

    private let chatProvider: ChatProvider
    private let router: AppRouter
    private let onSessionReset: () -> Void

    // MARK: - Init

    /// Creates the use case.
    ///
    /// - Parameter onSessionReset: Called after a channel switch has torn the session down, so the chat
    ///     theme can be rebuilt. `ChatPresenter` — and the `ChatCoordinator` it owns — is constructed
    ///     before this use case runs and snapshots its `ChatStyle` in `init`, so without this hand-off
    ///     the previous brand's colours would keep styling chat for the rest of the session even though
    ///     their storage keys are gone. Mirrors `SettingsViewModel(onColorChanged:)`.
    init(chatProvider: ChatProvider, router: AppRouter, onSessionReset: @escaping () -> Void) {
        self.chatProvider = chatProvider
        self.router = router
        self.onSessionReset = onSessionReset
    }

    // MARK: - Methods

    func callAsFunction(_ predefined: PredefinedConfiguration) {
        let configuration = predefined.configuration

        Log.trace("Applying predefined configuration for brand \(configuration.brandId), channel \(configuration.channelId)")

        // Only a *different* channel needs the teardown. Re-applying the configuration the app is
        // already on — a repeated launch of the same automated test — would otherwise pointlessly
        // discard a valid session and the chat theme.
        if let current = LocalStorageManager.configuration, !current.identifiesSameChannel(as: configuration) {
            Log.trace("Predefined configuration targets a different channel — resetting the session")

            // `shouldUnregisterFromNotifications: false` — this runs from `SDKDemoApp.init()`, before the
            // app delegate is installed, and `LoginView.onAppear` registers again immediately anyway.
            ChatSessionReset.perform(chatProvider: chatProvider, shouldUnregisterFromNotifications: false)

            // After `LocalStorageManager.reset()` has dropped the theme keys, so the rebuilt style picks
            // up the defaults rather than the previous brand's colours.
            onSessionReset()
        }

        // After the reset, never before: `ChatSessionReset` clears every LocalStorageKey.
        LocalStorageManager.configuration = configuration

        if let guestIdentity = predefined.guestIdentity {
            // Persisting both names is what makes `LoginViewModel.prepareAndFetchConfiguration()`
            // treat the guest identity as restored and advance to the store by itself — on channels
            // where authorization is disabled. OAuth-enabled channels intentionally still show the
            // login screen, because a name is not a credential there.
            LocalStorageManager.firstName = guestIdentity.firstName
            LocalStorageManager.lastName = guestIdentity.lastName

            // `CustomerService.setName` only caches in memory, so a restored identity never reaches
            // the SDK on its own. Set it explicitly, exactly as `onGuestLoginTapped` does.
            chatProvider.customer.setName(firstName: guestIdentity.firstName, lastName: guestIdentity.lastName)
        }

        router.applyPredefinedConfiguration(configuration)
    }
}
