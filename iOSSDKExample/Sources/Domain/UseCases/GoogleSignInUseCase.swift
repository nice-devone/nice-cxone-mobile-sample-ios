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

/// Runs Google sign-in for a chosen `OAuthFlow` and applies the resulting credentials to the SDK.
///
/// Replaces the former `LoginWithAmazonUseCase`. For the implicit flow it also registers the SDK's
/// token delegate, so subsequent token refreshes happen silently without any further user interaction.
/// The chosen flow is persisted so a returning user's session can be restored on next launch.
@MainActor
class GoogleSignInUseCase {

    // MARK: - Properties

    let chatProvider: ChatProvider

    // MARK: - Init

    init(chatProvider: ChatProvider) {
        self.chatProvider = chatProvider
    }

    // MARK: - Methods

    /// Authenticates with Google using the selected flow and hands the credentials to the SDK.
    ///
    /// - Parameter flow: The OAuth flow to run.
    /// - Throws: `OAError.cancelled` if the user cancels, or any underlying provider error.
    func callAsFunction(flow: OAuthFlow) async throws {
        guard let authenticator = OAuthenticatorsManager.authenticator else {
            throw CommonError.failed("Unable to get OAuth authenticator.")
        }

        let result = try await authenticator.authorize(flow: flow)

        switch result {
        case .implicit(let connectionToken, let expiresAt):
            chatProvider.customer.setConnectionToken(connectionToken, expiresAt: expiresAt)

            registerTokenDelegateListener(with: authenticator)
        case .explicit(let authorizationCode, let codeVerifier):
            chatProvider.customer.setAuthorizationCode(authorizationCode)
            chatProvider.customer.setCodeVerifier(codeVerifier)
        }

        LocalStorageManager.oAuthFlow = flow
    }

    /// Re-establishes a returning user's OAuth session after an app relaunch.
    ///
    /// A persisted ``OAuthFlow`` alone is not a usable credential — the connection token, the
    /// token-delegate listener, and the provider's auth state all live only in memory. For the
    /// implicit flow this restores the persisted auth state, silently refreshes the token, hands
    /// it to the SDK, and re-registers the token delegate. Explicit-flow credentials (authorization
    /// code + verifier) are one-shot and cannot be restored, so the user has to sign in again.
    ///
    /// - Returns: `true` when the session was restored and the SDK can connect; `false` when
    ///   interactive sign-in is required (the persisted flow is cleared in that case).
    func restoreSession() async -> Bool {
        guard let flow = LocalStorageManager.oAuthFlow else {
            return false
        }
        guard flow == .implicit, let authenticator = OAuthenticatorsManager.authenticator else {
            LocalStorageManager.oAuthFlow = nil

            return false
        }
        guard await authenticator.restoreImplicitSession() else {
            LocalStorageManager.oAuthFlow = nil

            return false
        }

        do {
            let refreshed = try await authenticator.refreshImplicitToken()

            chatProvider.customer.setConnectionToken(refreshed.token, expiresAt: refreshed.expiresAt)

            registerTokenDelegateListener(with: authenticator)

            Log.trace("Restored the Google OAuth session for a returning user")

            return true
        } catch {
            error.logError()

            LocalStorageManager.oAuthFlow = nil

            return false
        }
    }
}

// MARK: - Private methods

private extension GoogleSignInUseCase {

    /// Lets the SDK refresh the token itself before it expires — no interactive re-auth needed.
    /// Logs tagged "[TokenDelegate]" trace the refresh round-trip end to end while testing.
    func registerTokenDelegateListener(with authenticator: OAuthenticator) {
        chatProvider.customer.setTokenDelegateListener { reason in
            Log.trace("[TokenDelegate] SDK requested a fresh Google token (reason: \(reason))")

            do {
                let refreshed = try await authenticator.refreshImplicitToken()

                Log.trace("[TokenDelegate] Returning refreshed Google token, expires at \(refreshed.expiresAt)")

                return OAuthToken(accessToken: refreshed.token, expiresAt: refreshed.expiresAt)
            } catch {
                Log.error("[TokenDelegate] Failed to refresh Google token: \(error.localizedDescription)")

                throw error
            }
        }
    }
}

// MARK: - Preview Mock

class PreviewGoogleSignInUseCase: GoogleSignInUseCase {

    override func callAsFunction(flow: OAuthFlow) async throws {
        await Task.sleep(seconds: 2)
    }

    override func restoreSession() async -> Bool {
        false
    }
}
