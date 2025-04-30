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

import SwiftUI

struct LocalStorageManager {
    
    // MARK: - Keys
    
    enum Keys: String, CaseIterable {
        case configuration
        case firstName
        case lastName
        case primaryLightColor
        case primaryDarkColor
        case onPrimaryLightColor
        case onPrimaryDarkColor
        case backgroundLightColor
        case backgroundDarkColor
        case onBackgroundLightColor
        case onBackgroundDarkColor
        case accentLightColor
        case accentDarkColor
        case onAccentLightColor
        case onAccentDarkColor
        case agentBackgroundLightColor
        case agentBackgroundDarkColor
        case agentTextLightColor
        case agentTextDarkColor
        case customerBackgroundLightColor
        case customerBackgroundDarkColor
        case customerTextLightColor
        case customerTextDarkColor
        case chatPresentationStyle
        case additionalCustomerCustomFields
        case additionalContactCustomFields
    }
    
    // MARK: - Properties
    
    @Storage(key: .configuration)
    static var configuration: Configuration?
    
    @Storage(key: .firstName)
    static var firstName: String?
    
    @Storage(key: .lastName)
    static var lastName: String?
    
    @Storage(key: .primaryLightColor)
    static var primaryLightColor: Color?
    
    @Storage(key: .primaryDarkColor)
    static var primaryDarkColor: Color?
    
    @Storage(key: .onPrimaryLightColor)
    static var onPrimaryLightColor: Color?
    
    @Storage(key: .onPrimaryDarkColor)
    static var onPrimaryDarkColor: Color?
    
    @Storage(key: .backgroundLightColor)
    static var backgroundLightColor: Color?
    
    @Storage(key: .backgroundDarkColor)
    static var backgroundDarkColor: Color?
    
    @Storage(key: .onBackgroundLightColor)
    static var onBackgroundLightColor: Color?
    
    @Storage(key: .onBackgroundDarkColor)
    static var onBackgroundDarkColor: Color?
    
    @Storage(key: .accentLightColor)
    static var accentLightColor: Color?
    
    @Storage(key: .accentDarkColor)
    static var accentDarkColor: Color?
    
    @Storage(key: .onAccentLightColor)
    static var onAccentLightColor: Color?
    
    @Storage(key: .onAccentDarkColor)
    static var onAccentDarkColor: Color?
    
    @Storage(key: .agentBackgroundLightColor)
    static var agentBackgroundLightColor: Color?
    
    @Storage(key: .agentBackgroundDarkColor)
    static var agentBackgroundDarkColor: Color?
    
    @Storage(key: .agentTextLightColor)
    static var agentTextLightColor: Color?
    
    @Storage(key: .agentTextDarkColor)
    static var agentTextDarkColor: Color?
    
    @Storage(key: .customerBackgroundLightColor)
    static var customerBackgroundLightColor: Color?
    
    @Storage(key: .customerBackgroundDarkColor)
    static var customerBackgroundDarkColor: Color?
    
    @Storage(key: .customerTextLightColor)
    static var customerTextLightColor: Color?
    
    @Storage(key: .customerTextDarkColor)
    static var customerTextDarkColor: Color?
    
    @Storage(key: .chatPresentationStyle)
    static var chatPresentationStyle: ChatPresentationStyle?
    
    @Storage(key: .additionalCustomerCustomFields)
    static var additionalCustomerCustomFields: [String: String]?
    
    @Storage(key: .additionalContactCustomFields)
    static var additionalContactCustomFields: [String: String]?
    
    // MARK: - Methods
    
    static func reset() {
        Log.trace("Reseting local storage")
        
        Keys.allCases.forEach { key in
            UserDefaults.standard.removeObject(forKey: key.rawValue)
        }
        
        UserDefaults.standard.synchronize()
    }
}

// MARK: - Helpers

@propertyWrapper
struct Storage<T: Codable> {
    
    // MARK: - Properties
    
    private let key: LocalStorageManager.Keys
    
    var wrappedValue: T? {
        get {
            guard let data = UserDefaults.standard.object(forKey: key.rawValue) as? Data else {
                return nil
            }
            
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                error.logError()
                
                return nil
            }
        }
        set {
            do {
                if let newValue {
                    let data = try JSONEncoder().encode(newValue)
                    
                    UserDefaults.standard.set(data, forKey: key.rawValue)
                    UserDefaults.standard.synchronize()
                } else {
                    UserDefaults.standard.removeObject(forKey: key.rawValue)
                }
                
            } catch {
                error.logError()
            }
        }
    }
    
    // MARK: - Init
    
    init(key: LocalStorageManager.Keys) {
        self.key = key
    }
}
