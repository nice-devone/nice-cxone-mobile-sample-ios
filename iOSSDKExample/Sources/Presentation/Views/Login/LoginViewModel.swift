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
import SwiftUI

class LoginViewModel: AnalyticsReporter, ObservableObject {
    
    // MARK: - Properties
    
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var isOAuthEnabled = false
    @Published var isLoading = true
    @Published var alertType: AlertType?
    
    let configuration: Configuration
    
    private let loginWithAmazon: LoginWithAmazonUseCase
    private let getChannelConfiguration: GetChannelConfigurationUseCase
    private let coordinator: LoginCoordinator
    
    private var deeplinkOption: DeeplinkOption?
    
    // MARK: - Init
    
    init(
        coordinator: LoginCoordinator,
        configuration: Configuration,
        deeplinkOption: DeeplinkOption?,
        loginWithAmazon: LoginWithAmazonUseCase,
        getChannelConfiguration: GetChannelConfigurationUseCase
    ) {
        self.coordinator = coordinator
        self.configuration = configuration
        self.deeplinkOption = deeplinkOption
        self.loginWithAmazon = loginWithAmazon
        self.getChannelConfiguration = getChannelConfiguration
        super.init(analyticsTitle: "login", analyticsUrl: "/login")
    }
    
    // MARK: - Methods

    override func onAppear() {
        Log.trace("Login view appeared")
        
        coordinator.navigationController.navigationBar.defaultAppearance()
        UIAlertController.defaultAppearance()
        UISegmentedControl.defaultAppearance()
        
        #if !targetEnvironment(simulator)
        RemoteNotificationsManager.shared.onRegistrationFinished = { [weak self] in
            self?.prepareAndFetchConfiguration()
        }
        
        RemoteNotificationsManager.shared.registerIfNeeded()
        #else
        prepareAndFetchConfiguration()
        #endif
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
        
        coordinator.showSettings()
    }
    
    func popToConfiguration() {
        Log.trace("Navigating to the configuration")
        
        CXoneChat.signOut()
        LocalStorageManager.reset()
        FileManager.default.eraseDocumentsFolder()
        RemoteNotificationsManager.shared.unregister()
        
        // Reconfigure Logger
        Log.configure(isWriteToFileEnabled: true)
        
        coordinator.showConfiguration()
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
        CXoneChat.shared.customer.setName(firstName: firstName, lastName: lastName)
        
        navigateToStore()
    }
    
    func invokeLoginWithAmazon() {
        Log.trace("Logging with Amazon")
        
        isLoading = true
        
        Task { @MainActor [weak self] in
            guard let self else {
                return
            }
            
            do {
                try await self.loginWithAmazon()
                
                self.navigateToStore()
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

// MARK: - Private methods

private extension LoginViewModel {
    
    func navigateToStore() {
        Log.trace("Navigate to the store")
        
        coordinator.showDashboard(deeplinkOption: deeplinkOption)
        
        deeplinkOption = nil // Reset deeplink option after navigation
    }
    
    func prepareAndFetchConfiguration() {
        Log.trace("Checking OAuth login options")
        
        Task { @MainActor [weak self] in
            guard let self else {
                return
            }
            
            do {
                if let env = self.configuration.environment {
                    try await CXoneChat.shared.connection.prepare(
                        environment: env,
                        brandId: self.configuration.brandId,
                        channelId: self.configuration.channelId
                    )
                } else {
                    try await CXoneChat.shared.connection.prepare(
                        chatURL: self.configuration.chatUrl,
                        socketURL: self.configuration.socketUrl,
                        loggerURL: self.configuration.loggerUrl,
                        brandId: self.configuration.brandId,
                        channelId: self.configuration.channelId
                    )
                }

                // Analytics need prepared CXone SDK, then it can report page view
                self.reportViewPage()

                let channelConfig = try await getChannelConfiguration(configuration: self.configuration)
                
                let isOAuthEnabled = channelConfig.isAuthorizationEnabled
                let isRealDevice = !UIDevice.current.isPreview
                let isCustomerIdentitySet = LocalStorageManager.firstName?.isEmpty == false && LocalStorageManager.lastName?.isEmpty == false
                
                if !isOAuthEnabled, isCustomerIdentitySet, isRealDevice {
                    self.navigateToStore()
                } else {
                    self.isOAuthEnabled = isOAuthEnabled
                    
                    self.isLoading = false
                }
            } catch CXoneChatError.sdkVersionNotSupported {
                isLoading = false
                
                alertType = .sdkVersionNotSupportedError(primaryAction: popToConfiguration)
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
