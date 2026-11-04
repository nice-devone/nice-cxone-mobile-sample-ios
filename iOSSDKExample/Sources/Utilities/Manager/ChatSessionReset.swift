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

/// Drops everything tied to the brand/channel the app is currently configured for.
///
/// Shared by the places that abandon a session: the user signing out via
/// ``LoginViewModel/popToConfiguration()`` or ``StoreViewModel/signOut()``, and a predefined launch
/// configuration that switches the app to a *different* channel. All must clear provider auth state, persisted identity and downloaded
/// attachments — otherwise credentials and thread state from one brand leak into the next.
///
/// - Note: The launch-configuration call site reads from the process launch environment in `SDKDemoApp.init()`. It is
///     unrelated to the URL deep links handled by `ThreadsDeeplinkHandler` and `AppRouter.handleDeepLink`,
///     and takes no part in their `pendingDeeplink` semantics.
@MainActor
enum ChatSessionReset {

    // MARK: - Methods

    /// Clears provider auth state, persisted identity and downloaded attachments in the order they
    /// depend on each other.
    ///
    /// - Important: This calls ``LocalStorageManager/reset()``, which removes **every**
    ///     `LocalStorageKey` — the configuration and the chat theme included. Callers that go on to
    ///     write new values (a predefined configuration, a guest identity) must do so *after* this
    ///     returns, or the write is wiped.
    ///
    /// - Parameter shouldUnregisterFromNotifications: Pass `false` from `SDKDemoApp.init()`. APNs
    ///     registration is a process-wide UIKit concern rather than session state, and at that point
    ///     `UIApplicationMain` has not finished installing the app delegate — see the note in
    ///     `SDKDemoApp.init()`. `LoginView.onAppear` calls `registerIfNeeded()` moments later either
    ///     way, so unregistering there would only churn the token.
    static func perform(chatProvider: ChatProvider, shouldUnregisterFromNotifications: Bool = true) {
        Log.trace("Resetting the chat session")

        Task {
            // Best-effort Keychain cleanup, deliberately *not* ordered against the synchronous work below:
            // `signOut()` is async and nothing here awaits it. Nothing depends on that ordering either —
            // what stops a stale session being restored is `LocalStorageManager.reset()` clearing
            // `oAuthFlow`, which makes `GoogleSignInUseCase.restoreSession()` bail at its first guard. This
            // call is about not leaving another brand's credentials sitting in the Keychain.
            //
            // Requires an authenticator to already be registered. `SDKDemoApp.init()` registers before it
            // can reach the launch-time reset, which is what makes this deterministic rather than a
            // coin-flip against whenever the app delegate happens to be installed.
            try? await OAuthenticatorsManager.authenticator?.signOut()
        }

        chatProvider.customer.setTokenDelegateListener(nil)
        chatProvider.signOut()
        LocalStorageManager.reset()
        FileManager.default.eraseDocumentsFolder()
        // Logs live outside Documents, so clear them explicitly to keep the previous session's data from surviving the reset.
        Log.removeLogs()

        if shouldUnregisterFromNotifications {
            RemoteNotificationsManager.shared.unregister()
        }

        // Reconfigure Logger
        Log.configure(isWriteToFileEnabled: true)
    }
}
