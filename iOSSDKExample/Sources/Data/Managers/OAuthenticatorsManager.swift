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

import CXoneGuideUtility
import Foundation

enum OAuthenticatorsManager {

    // MARK: - Properties

    private static let _authenticators = SafeAccessContainer<[OAuthenticator]>([])

    static var authenticator: OAuthenticator? {
        _authenticators.content.first
    }

    // MARK: - Methods

    static func register(authenticator: OAuthenticator) {
        _authenticators.mutate {
            $0.append(authenticator)
        }
    }
}
