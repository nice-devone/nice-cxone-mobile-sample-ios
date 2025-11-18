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

enum LocalStorageKey {
    
    // MARK: - Cases
    
    case configuration
    case firstName
    case lastName
    case chatPresentationStyle
    case additionalCustomerCustomFields
    case additionalContactCustomFields
    case oAuthEntity
    case chatLightTheme(Theme)
    case chatDarkTheme(Theme)
    
    enum Theme {
        
        // MARK: - Cases
        
        case background(Background)
        case content(Content)
        case brand(Brand)
        case border(Border)
        case status(Status)
        
        // MARK: - Enums
        
        enum Background {
            
            // MARK: - Cases
            
            case `default`
            case inverse
            case surface(Surface)
            
            // MARK: - Enums
            
            enum Surface: String, CaseIterable {
                
                case `default`
                case variant
                case container
                case subtle
                case emphasis
            }
            
            // MARK: - Properties
            
            var rawValue: String {
                switch self {
                case .default:
                    "default"
                case .inverse:
                    "inverse"
                case .surface(let surface):
                    "surface.\(surface.rawValue)"
                }
            }
        }
        
        enum Content: String, CaseIterable {
            case primary
            case secondary
            case tertiary
            case inverse
        }
        
        enum Brand: String, CaseIterable {
            case primary
            case onPrimary
            case primaryContainer
            case onPrimaryContainer
            case secondary
            case onSecondary
            case secondaryContainer
            case onSecondaryContainer
        }
        
        enum Border: String, CaseIterable {
            case `default`
            case subtle
        }
        
        enum Status: String, CaseIterable {
            case success
            case onSuccess
            case successContainer
            case onSuccessContainer
            case warning
            case onWarning
            case warningContainer
            case onWarningContainer
            case error
            case onError
            case errorContainer
            case onErrorContainer
        }
        
        // MARK: - Properties
        
        var rawValue: String {
            switch self {
            case .background(let background):
                "background.\(background.rawValue)"
            case .content(let content):
                "content.\(content.rawValue)"
            case .brand(let brand):
                "brand.\(brand.rawValue)"
            case .border(let border):
                "border.\(border.rawValue)"
            case .status(let status):
                "status.\(status.rawValue)"
            }
        }
    }
    
    // MARK: - Variables
    
    var rawValue: String {
        switch self {
        case .configuration:
            "configuration"
        case .firstName:
            "firstName"
        case .lastName:
            "lastName"
        case .chatPresentationStyle:
            "chatPresentationStyle"
        case .additionalCustomerCustomFields:
            "additionalCustomerCustomFields"
        case .additionalContactCustomFields:
            "additionalContactCustomFields"
        case .oAuthEntity:
            "oAuthEntity"
        case .chatLightTheme(let theme):
            "chatLightTheme.\(theme.rawValue)"
        case .chatDarkTheme(let theme):
            "chatDarkTheme.\(theme.rawValue)"
        }
    }
}

// MARK: - CaseIterable

extension LocalStorageKey: CaseIterable {
    
    static var allCases: [LocalStorageKey] {
        [.configuration, .firstName, .lastName, .chatPresentationStyle, .additionalCustomerCustomFields, .additionalContactCustomFields, .oAuthEntity]
            + Theme.allCases.map { .chatLightTheme($0) }
            + Theme.allCases.map { .chatDarkTheme($0) }
    }
}

extension LocalStorageKey.Theme: CaseIterable {
    
    static var allCases: [LocalStorageKey.Theme] {
        Background.allCases.map { .background($0) }
            + Content.allCases.map { .content($0) }
            + Brand.allCases.map { .brand($0) }
            + Border.allCases.map { .border($0) }
            + Status.allCases.map { .status($0) }
    }
}

extension LocalStorageKey.Theme.Background: CaseIterable {
    
    static var allCases: [LocalStorageKey.Theme.Background] {
        [.default, .inverse]
            + Surface.allCases.map { .surface($0) }
    }
}
