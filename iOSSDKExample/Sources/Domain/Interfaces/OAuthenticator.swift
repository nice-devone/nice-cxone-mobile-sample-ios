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

import Foundation

/// An object capable of performing OAuth authentication for the sample app.
///
/// The provider library (e.g. AppAuth) generates the PKCE parameters internally, so callers no
/// longer pass a challenge in. The selected `OAuthFlow` determines which credentials the returned
/// `OAResult` carries.
protocol OAuthenticator: Sendable {

    // MARK: - Properties

    /// User-presentable name of the authenticator.
    var authenticatorName: String { get }

    // MARK: - Methods

    /// Attempt OAuth authentication for the given flow.
    ///
    /// - Parameter flow: The flow the user selected — determines which credentials are returned.
    /// - Returns: The credentials for the selected flow.
    /// - Throws: `OAError.cancelled` if the user cancelled, or any underlying provider error.
    func authorize(flow: OAuthFlow) async throws -> OAResult

    /// Silently obtain a fresh implicit-flow access token, refreshing it via the stored refresh token
    /// without presenting UI. Used by the SDK's token delegate to renew an expiring connection token.
    ///
    /// - Returns: The refreshed access token and its expiry.
    /// - Throws: An error if no prior implicit sign-in exists or the refresh fails.
    func refreshImplicitToken() async throws -> (token: String, expiresAt: Date)

    /// Restore a previously persisted implicit-flow session (if any) so that
    /// `refreshImplicitToken()` can renew its token without interactive sign-in.
    ///
    /// - Returns: `true` when a persisted session was restored or one is already active.
    func restoreImplicitSession() async -> Bool

    /// Attempt to log out any cached user results.
    func signOut() async throws

    /// Handle an open-url request from the application; required to complete some OAuth redirects.
    ///
    /// - Parameters:
    ///   - url: The URL being opened.
    ///   - sourceApplication: Name of the application originating the request.
    /// - Returns: `true` if the URL was consumed by an in-flight authorization flow.
    func handleOpen(url: URL, sourceApplication: String?) -> Bool
}
