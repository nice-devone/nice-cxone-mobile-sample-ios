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

/// The OAuth flow the user selects before signing in.
///
/// The sample app demonstrates both SDK token-delegation models; the choice is made in the
/// flow-selection BottomSheet and threaded into `OAuthenticator.authorize(flow:)`. It is also
/// persisted (`LocalStorageManager.oAuthFlow`) so the mid-session re-authentication path knows
/// which flow to re-run.
enum OAuthFlow: String, CaseIterable, Identifiable, Codable {

    // MARK: - Cases

    /// The app performs the full OAuth exchange itself and hands the SDK a finished JWT
    /// via `setConnectionToken(_:expiresAt:)`.
    case implicit

    /// The app obtains an authorization code + code verifier (PKCE) and hands both to the SDK;
    /// the CXone backend finishes the exchange.
    case explicit

    // MARK: - Properties

    var id: Self { self }
}
