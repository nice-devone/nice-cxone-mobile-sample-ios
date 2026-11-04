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

@main
struct SDKDemoApp: App {

    // MARK: - Properties

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var chatPresenter: ChatPresenter
    @StateObject private var router: AppRouter
    @StateObject private var dependencies: AppDependencies

    // MARK: - Init

    init() {
        let chatProvider = CXoneChat()
        let chatPresenter = ChatPresenter(chatProvider: chatProvider)
        let router = AppRouter(chatPresenter: chatPresenter)
        let dependencies = AppDependencies(router: router, chatPresenter: chatPresenter)
        self._chatPresenter = StateObject(wrappedValue: chatPresenter)
        self._router = StateObject(wrappedValue: router)
        self._dependencies = StateObject(wrappedValue: dependencies)
        // Wire the provider through the adaptor's wrapped value, not `UIApplication.shared.delegate`.
        // `App.init()` runs before UIApplicationMain installs the app delegate, so the shared
        // delegate is still nil at this point and a cast-and-assign would silently no-op — the
        // device token would then never reach setDeviceToken(_:). The adaptor has already created
        // the exact instance that later receives didRegisterForRemoteNotificationsWithDeviceToken,
        // so assigning through the wrapper is safe this early.
        appDelegate.chatProvider = chatProvider

        // Registered here rather than in `didFinishLaunching`, which runs *after* this initialiser: a
        // predefined configuration for a different brand tears the session down below, and that teardown
        // signs out through `OAuthenticatorsManager.authenticator`. With the registration left in the app
        // delegate, whether the authenticator exists by the time that sign-out runs comes down to when the
        // app delegate happens to be installed — and when it does not, the previous brand's OAuth state is
        // left sitting in the Keychain. Reading `GoogleService-Info.plist` has no dependency on UIKit or
        // Firebase being set up, so it is safe this early.
        do {
            OAuthenticatorsManager.register(authenticator: try GoogleAuthenticator())
        } catch {
            error.logError("Failed to set up Google authenticator")
        }

        // Applied here, in `init`, rather than from a view lifecycle hook: `body` has not been
        // evaluated yet, so the root is already settled by the time the first frame is rendered and
        // `ConfigurationView` is never presented at all.
        switch LaunchConfigurationReader.read() {
        case .absent:
            // An ordinary launch. Whatever `AppRouter.init` chose from persisted state stands.
            break
        case .rejected:
            // Deliberately overrides the `.login(persistedConfiguration)` root `AppRouter.init` may have
            // just chosen. A launch that asked for a channel and got it wrong has to stop where the
            // mistake is visible; falling through to the previous run's channel would execute the whole
            // suite against the wrong backend on the strength of a single stdout warning.
            router.showConfiguration()
        case .supplied(let predefined):
            dependencies.applyPredefinedConfiguration(predefined)
        }
    }

    // MARK: - Builder

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(router)
                .environmentObject(chatPresenter)
                .environmentObject(dependencies)
                .onOpenURL { url in
                    if ThreadsDeeplinkHandler.canOpenUrl(url) {
                        chatPresenter.chatProvider.connection.disconnect()
                        router.handleDeepLink(url)
                    } else {
                        // `sourceApplication: nil` — SwiftUI's `onOpenURL` does not expose
                        // `UIApplicationOpenURLOptionsKey.sourceApplication`. The OAuth authenticator
                        // accepts `nil` and its `ASWebAuthenticationSession`-based flow does not require it.
                        _ = OAuthenticatorsManager.authenticator?.handleOpen(url: url, sourceApplication: nil)
                    }
                }
        }
    }
}
