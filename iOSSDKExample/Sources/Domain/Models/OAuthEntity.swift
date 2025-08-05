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

/// A data structure representing the components required for OAuth 2.0 PKCE (Proof Key for Code Exchange) flow.
///
/// This entity holds the `codeVerifier` and `codeChallenge` strings used during the authorization process.
struct OAuthEntity: Codable {
    /// A high-entropy cryptographic random string used to verify the identity of the client.
    let codeVerifier: String
    /// A hashed and encoded version of the `codeVerifier`, sent to the authorization server.
    let codeChallenge: String
}
