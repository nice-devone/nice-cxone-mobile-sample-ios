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

import CXoneChatSDK
import PKCE

class LoginWithAmazonUseCase {
    
    func callAsFunction() async throws {
        if let entity = LocalStorageManager.oAuthEntity {
            // Authorize silently with existing code verifier and challenge
            CXoneChat.shared.customer.setCodeVerifier(entity.codeVerifier)
            CXoneChat.shared.customer.setAuthorizationCode(entity.codeChallenge)
        } else {
            // Authorize with UI prompt
            guard let authenticator = OAuthenticatorsManager.authenticator else {
                throw CommonError.failed("Unable to get OAuth authenticator.")
            }
            // Generate code verifier and challenge
            let verifier = try generateCodeVerifier()
            let challenge = try generateCodeChallenge(for: verifier)
            
            let (_, result) = try await authenticator.authorize(withChallenge: challenge)
            
            if let result {
                LocalStorageManager.oAuthEntity = OAuthEntity(codeVerifier: verifier, codeChallenge: result.challengeResult)
                
                CXoneChat.shared.customer.setCodeVerifier(verifier)
                CXoneChat.shared.customer.setAuthorizationCode(result.challengeResult)
            } else {
                throw CommonError.unableToParse("result")
            }
        }
    }
}

// MARK: - Preview Mock

class PreviewLoginWithAmazonUseCase: LoginWithAmazonUseCase {
    
    override func callAsFunction() async throws {
        await Task.sleep(seconds: 2)
    }
}
