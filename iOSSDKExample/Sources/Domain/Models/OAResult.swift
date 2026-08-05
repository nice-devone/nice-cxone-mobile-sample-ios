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

/// The credentials produced by a successful OAuth authentication, keyed by the flow that was used.
///
/// Each case carries exactly the values the SDK needs for that flow, so the call site knows which
/// `CustomerProvider` setters to invoke without any optional unwrapping.
enum OAResult {

    // MARK: - Cases

    /// Implicit flow result — the app obtained a finished access token (JWT) and its expiry from the provider.
    ///
    /// Pass these to `customer.setConnectionToken(_:expiresAt:)` before `connection.connect()`.
    case implicit(connectionToken: String, expiresAt: Date)

    /// Explicit (PKCE) flow result — the app obtained an authorization code and the code verifier
    /// used to generate the challenge; the CXone backend finishes the token exchange.
    ///
    /// Pass these to `customer.setAuthorizationCode(_:)` and `customer.setCodeVerifier(_:)` before
    /// `connection.connect()`.
    case explicit(authorizationCode: String, codeVerifier: String)
}
