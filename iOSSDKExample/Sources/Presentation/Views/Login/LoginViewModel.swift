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
import SwiftUI

@MainActor
class LoginViewModel: AnalyticsReporter, AlertableViewModel {
    
    // MARK: - Properties
    
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var isOAuthEnabled = false
    @Published var isFlowSelectionPresented = false
    @Published var isLoading = true
    @Published var alertType: AlertType?

    let configuration: Configuration

    private let getChannelConfiguration: GetChannelConfigurationUseCase
    private let googleSignIn: GoogleSignInUseCase
    private let router: AppRouter

    // MARK: - Init

    init(
        router: AppRouter,
        chatProvider: ChatProvider,
        configuration: Configuration,
        getChannelConfiguration: GetChannelConfigurationUseCase,
        googleSignIn: GoogleSignInUseCase
    ) {
        self.router = router
        self.configuration = configuration
        self.getChannelConfiguration = getChannelConfiguration
        self.googleSignIn = googleSignIn
        super.init(chatProvider: chatProvider, analyticsTitle: "login", analyticsUrl: "/login")
    }
    
    // MARK: - Methods

    override func onAppear() {
        Log.trace("Login view appeared")

        Task { @MainActor [weak self] in
            do {
                try await RemoteNotificationsManager.shared.registerIfNeeded()
            } catch {
                error.logError()
            }

            self?.prepareAndFetchConfiguration()
        }
    }
    
    func signOut() {
        Log.trace("Signing out")
        
        popToConfiguration()
    }
    
    func onRepeatButtonTapped() {
        isLoading = true
        
        prepareAndFetchConfiguration()
    }
    
    func navigateToSettings() {
        Log.trace("Navigating to the settings")
        
        router.showSettings()
    }
    
    func popToConfiguration() {
        Log.trace("Navigating to the configuration")

        Task {
            // Drop the provider session, including the auth state persisted in the Keychain.
            try? await OAuthenticatorsManager.authenticator?.signOut()
        }

        chatProvider.customer.setTokenDelegateListener(nil)
        chatProvider.signOut()
        LocalStorageManager.reset()
        FileManager.default.eraseDocumentsFolder()
        RemoteNotificationsManager.shared.unregister()
        
        // Reconfigure Logger
        Log.configure(isWriteToFileEnabled: true)
        
        router.showConfiguration()
    }
    
    func onGuestLoginTapped() {
        // Fallback to placeholder if the user didn't provide the name
        if firstName.isEmpty {
            self.firstName = L10n.Login.Guest.UserDetails.firstNamePlaceholder
        }
        if lastName.isEmpty {
            self.lastName = L10n.Login.Guest.UserDetails.lastNamePlaceholder
        }

        Log.trace("Set customer identity to \(firstName) \(lastName)")

        LocalStorageManager.firstName = firstName
        LocalStorageManager.lastName = lastName
        chatProvider.customer.setName(firstName: firstName, lastName: lastName)

        navigateToStore()
    }

    func onGoogleLoginTapped() {
        Log.trace("Presenting OAuth flow selection")

        isFlowSelectionPresented = true
    }

    func signInWithGoogle(flow: OAuthFlow) {
        Log.trace("Signing in with Google using \(flow.rawValue) flow")

        isLoading = true

        Task { @MainActor [weak self] in
            guard let self else {
                return
            }

            do {
                try await self.googleSignIn(flow: flow)

                self.navigateToStore()
            } catch OAError.cancelled {
                Log.trace("Google sign-in cancelled by user")

                self.isLoading = false
            } catch {
                error.logError()

                self.isLoading = false
                self.alertType = .genericError
            }
        }
    }
}

// MARK: - Private methods

private extension LoginViewModel {
    
    func navigateToStore() {
        Log.trace("Navigate to the store")

        router.showStore()
    }
    
    func prepareAndFetchConfiguration() {
        Log.trace("Checking OAuth login options")
        
        Task { @MainActor [weak self] in
            guard let self else {
                return
            }
            
            do {
                if let env = self.configuration.environment {
                    try await self.chatProvider.connection.prepare(
                        environment: env,
                        brandId: self.configuration.brandId,
                        channelId: self.configuration.channelId
                    )
                } else {
                    try await self.chatProvider.connection.prepare(
                        chatURL: self.configuration.chatUrl,
                        socketURL: self.configuration.socketUrl,
                        loggerURL: self.configuration.loggerUrl,
                        brandId: self.configuration.brandId,
                        channelId: self.configuration.channelId,
                        tokenURL: self.configuration.tokenUrl
                    )
                }

                // Analytics need prepared CXone SDK, then it can report page view
                self.reportViewPage()

                let channelConfig = try await getChannelConfiguration(configuration: self.configuration)
                self.isOAuthEnabled = channelConfig.isAuthorizationEnabled

                let isNotPreview = !UIDevice.current.isPreview
                // A persisted guest identity is only meaningful on channels where guest login is
                // available; on OAuth-enabled channels the guest form is hidden and stale
                // first/last-name entries in LocalStorage must not bypass the OAuth login flow.
                let isGuestIdentitySet = !self.isOAuthEnabled
                    && LocalStorageManager.firstName?.isEmpty == false
                    && LocalStorageManager.lastName?.isEmpty == false

                // A persisted OAuth flow alone is not a usable credential — the connection token,
                // token-delegate listener, and provider auth state live only in memory. Restore them
                // (with a silent token refresh) before treating the user as signed in; when that
                // fails, fall through to the login screen for interactive re-auth. Skipped when the
                // channel has authorization disabled so the login flow matches the channel config.
                var isOAuthIdentitySet = false
                if isNotPreview, self.isOAuthEnabled {
                    isOAuthIdentitySet = await self.googleSignIn.restoreSession()
                }

                if isNotPreview, isGuestIdentitySet || isOAuthIdentitySet {
                    self.navigateToStore()
                } else {
                    self.isLoading = false
                }
            } catch CXoneChatError.sdkVersionNotSupported {
                isLoading = false
                
                alertType = .sdkVersionNotSupportedError(popToConfiguration)
            } catch {
                error.logError()
                
                self.isLoading = false
                self.alertType = .loginError(
                    brandId: self.configuration.brandId,
                    channelId: self.configuration.channelId,
                    primaryAction: self.onRepeatButtonTapped,
                    secondaryAction: self.popToConfiguration
                )
            }
        }
    }
}
