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

import CXoneChatUI
import SwiftUI

@MainActor
struct LocalStorageManager {
    
    // MARK: - Properties
    
    @Storage(key: .configuration)
    static var configuration: Configuration?
    
    @Storage(key: .firstName)
    static var firstName: String?
    
    @Storage(key: .lastName)
    static var lastName: String?
    
    @Storage(key: .chatPresentationStyle)
    static var chatPresentationStyle: ChatPresentationStyle?
    
    @Storage(key: .additionalCustomerCustomFields)
    static var additionalCustomerCustomFields: [String: String]?
    
    @Storage(key: .additionalContactCustomFields)
    static var additionalContactCustomFields: [String: String]?
    
    @Storage(key: .oAuthFlow)
    static var oAuthFlow: OAuthFlow?
    
    // MARK: - Methods
    
    static func reset() {
        Log.trace("Resetting local storage")
        
        LocalStorageKey.allCases.forEach { key in
            UserDefaults.standard.removeObject(forKey: key.rawValue)
        }
        
        UserDefaults.standard.synchronize()
    }
    
    static func resetTheme() {
        Log.trace("Resetting theme in local storage")
        
        LocalStorageKey.themeCases.forEach { key in
            UserDefaults.standard.removeObject(forKey: key.rawValue)
        }
        
        UserDefaults.standard.synchronize()
    }
}
