//
// Copyright (c) 2021-2025. NICE Ltd. All rights reserved.
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

class SignOutWithAmazonUseCase {
    
    func callAsFunction() async throws {
        guard let authenticator = OAuthenticatorsManager.authenticator else {
            throw CommonError.failed("Unable to get OAuth authenticator.")
        }

        try await authenticator.signOut()
    }
}

// MARK: - Preview Mock

class PreviewSignOutWithAmazonUseCase: SignOutWithAmazonUseCase {
    
    override func callAsFunction() async throws {
        // No need to do anything in preview mode
    }
}
