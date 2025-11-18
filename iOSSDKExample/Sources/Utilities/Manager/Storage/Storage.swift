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
import Foundation

@propertyWrapper
struct Storage<T: Codable> {
    
    // MARK: - Properties
    
    private let key: LocalStorageKey
    
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
                    Log.info("Setting \(newValue) for \(key.rawValue)")
                    
                    UserDefaults.standard.set(data, forKey: key.rawValue)
                    UserDefaults.standard.synchronize()
                } else {
                    Log.info("Setting nil for \(key.rawValue)")
                    
                    UserDefaults.standard.removeObject(forKey: key.rawValue)
                }
                
            } catch {
                error.logError()
            }
        }
    }
    
    // MARK: - Init
    
    init(key: LocalStorageKey) {
        self.key = key
    }
}
