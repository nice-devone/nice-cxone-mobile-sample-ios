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

/// Errors surfaced by an `OAuthenticator` during the sign-in flow.
enum OAError: LocalizedError {

    // MARK: - Cases

    /// The user dismissed the authentication prompt before completing sign-in.
    case cancelled

    /// The provider returned a response missing a value required for the selected flow.
    case missingValue(String)

    // MARK: - Properties

    var errorDescription: String? {
        switch self {
        case .cancelled:
            return "Authentication was cancelled."
        case .missingValue(let value):
            return "OAuth response was missing a required value: \(value)."
        }
    }
}
