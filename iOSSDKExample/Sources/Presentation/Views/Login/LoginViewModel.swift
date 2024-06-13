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

import CXoneChatSDK
import SwiftUI

class LoginViewModel: AnalyticsReporter, ObservableObject {
    
    // MARK: - Properties
    
    @Published var isLoading = true
    @Published var isLoadingTransparent = false
    @Published var shouldShowError = false
    
    let configuration: Configuration
    
    private let loginWithAmazon: LoginWithAmazonUseCase
    private let getChannelConfiguration: GetChannelConfigurationUseCase
    private let coordinator: LoginCoordinator
    private let deeplinkOption: DeeplinkOption?
    
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
        
        RemoteNotificationsManager.shared.unregister()
        LocalStorageManager.reset()
        FileManager.default.eraseDocumentsFolder()
        
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
        
        isLoading = true
        
        RemoteNotificationsManager.shared.unregister()
        LocalStorageManager.reset()
        FileManager.default.eraseDocumentsFolder()
        
        coordinator.showConfiguration()
    }
    
    func navigateToStore() {
        Log.trace("Navigating to the store")
        
        coordinator.showDashboard(deeplinkOption: deeplinkOption)
    }
    
    func invokeLoginWithAmazon() {
        Log.trace("Logging with Amazon")
        
        isLoading = true
        isLoadingTransparent = true
        
        Task { @MainActor in
            do {
                try await loginWithAmazon()
                
                navigateToStore()
            } catch {
                error.logError()
                
                isLoading = false
                isLoadingTransparent = false
                shouldShowError = true
            }
        }
    }
}

// MARK: - Private methods

private extension LoginViewModel {
    
    func prepareAndFetchConfiguration() {
        Log.trace("Checking OAuth login options")
        
        Task { @MainActor in
            do {
                if let env = configuration.environment {
                    try await CXoneChat.shared.connection.prepare(environment: env, brandId: configuration.brandId, channelId: configuration.channelId)
                } else {
                    try await CXoneChat.shared.connection.prepare(
                        chatURL: configuration.chatUrl,
                        socketURL: configuration.socketUrl,
                        brandId: configuration.brandId,
                        channelId: configuration.channelId
                    )
                }

                // Analytics need prepared CXone SDK, then it can report page view
                reportViewPage()

                let channelConfig = try await getChannelConfiguration(configuration: configuration)
                
                if !channelConfig.isAuthorizationEnabled, !UIDevice.current.isPreview {
                    navigateToStore()
                } else {
                    isLoading = false
                }
            } catch {
                error.logError()
                
                isLoading = false
                shouldShowError = true
            }
        }
    }
}
