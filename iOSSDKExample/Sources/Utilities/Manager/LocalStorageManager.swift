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

import SwiftUI

struct LocalStorageManager {
    
    // MARK: - Keys
    
    enum Keys: String, CaseIterable {
        case configuration
        case firstName
        case lastName
        case chatNavigationBarLightColor
        case chatNavigationBarDarkColor
        case chatNavigationElementsLightColor
        case chatNavigationElementsDarkColor
        case chatBackgroundLightColor
        case chatBackgroundDarkColor
        case chatAgentCellLightColor
        case chatAgentCellDarkColor
        case chatCustomerCellLightColor
        case chatCustomerCellDarkColor
        case chatAgentFontLightColor
        case chatAgentFontDarkColor
        case chatCustomerFontLightColor
        case chatCustomerFontDarkColor
        case chatFormTextLightColor
        case chatFormTextDarkColor
        case chatFormErrorLightColor
        case chatFormErrorDarkColor
        case chatButtonBackgroundLightColor
        case chatButtonBackgroundDarkColor
        case chatButtonTextLightColor
        case chatButtonTextDarkColor
    }
    
    // MARK: - Properties
    
    @Storage(key: .configuration)
    static var configuration: Configuration?
    
    @Storage(key: .firstName)
    static var firstName: String?
    
    @Storage(key: .lastName)
    static var lastName: String?
    
    @Storage(key: .chatNavigationBarLightColor)
    static var chatNavigationBarLightColor: Color?
    
    @Storage(key: .chatNavigationBarDarkColor)
    static var chatNavigationBarDarkColor: Color?
    
    @Storage(key: .chatNavigationElementsLightColor)
    static var chatNavigationElementsLightColor: Color?
    
    @Storage(key: .chatNavigationElementsDarkColor)
    static var chatNavigationElementsDarkColor: Color?
    
    @Storage(key: .chatBackgroundLightColor)
    static var chatBackgroundLightColor: Color?
    
    @Storage(key: .chatBackgroundDarkColor)
    static var chatBackgroundDarkColor: Color?
    
    @Storage(key: .chatAgentCellLightColor)
    static var chatAgentCellLightColor: Color?
    
    @Storage(key: .chatAgentCellDarkColor)
    static var chatAgentCellDarkColor: Color?
    
    @Storage(key: .chatCustomerCellLightColor)
    static var chatCustomerCellLightColor: Color?
    
    @Storage(key: .chatCustomerCellDarkColor)
    static var chatCustomerCellDarkColor: Color?
    
    @Storage(key: .chatAgentFontLightColor)
    static var chatAgentFontLightColor: Color?
    
    @Storage(key: .chatAgentFontDarkColor)
    static var chatAgentFontDarkColor: Color?
    
    @Storage(key: .chatCustomerFontLightColor)
    static var chatCustomerFontLightColor: Color?
    
    @Storage(key: .chatCustomerFontDarkColor)
    static var chatCustomerFontDarkColor: Color?
    
    @Storage(key: .chatFormTextLightColor)
    static var chatFormTextLightColor: Color?
    
    @Storage(key: .chatFormTextDarkColor)
    static var chatFormTextDarkColor: Color?
    
    @Storage(key: .chatFormErrorLightColor)
    static var chatFormErrorLightColor: Color?
    
    @Storage(key: .chatFormErrorDarkColor)
    static var chatFormErrorDarkColor: Color?
    
    @Storage(key: .chatButtonBackgroundLightColor)
    static var chatButtonBackgroundLightColor: Color?
    
    @Storage(key: .chatButtonBackgroundDarkColor)
    static var chatButtonBackgroundDarkColor: Color?
    
    @Storage(key: .chatButtonTextLightColor)
    static var chatButtonTextLightColor: Color?
    
    @Storage(key: .chatButtonTextDarkColor)
    static var chatButtonTextDarkColor: Color?
    
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
    private var cachedValue: T?
    
    var wrappedValue: T? {
        get {
            if let cachedValue {
                return cachedValue
            }
            
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
                cachedValue = newValue
                
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
