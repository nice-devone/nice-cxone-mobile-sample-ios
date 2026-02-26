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

import CXoneChatUI
import SwiftUI

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
    
    @Storage(key: .oAuthEntity)
    static var oAuthEntity: OAuthEntity?
    
    // MARK: - Properties - Theme/Background
    
    @Storage(key: .chatLightTheme(.background(.default)))
    static var backgroundDefaultLightColor: Color?
    
    @Storage(key: .chatDarkTheme(.background(.default)))
    static var backgroundDefaultDarkColor: Color?
    
    @Storage(key: .chatLightTheme(.background(.inverse)))
    static var backgroundInverseLightColor: Color?
    
    @Storage(key: .chatDarkTheme(.background(.inverse)))
    static var backgroundInverseDarkColor: Color?
    
    // MARK: - Properties - Theme/Background/Surface
    
    @Storage(key: .chatLightTheme(.background(.surface(.default))))
    static var backgroundSurfaceDefaultLightColor: Color?
    
    @Storage(key: .chatDarkTheme(.background(.surface(.default))))
    static var backgroundSurfaceDefaultDarkColor: Color?
    
    @Storage(key: .chatLightTheme(.background(.surface(.variant))))
    static var backgroundSurfaceVariantLightColor: Color?
    
    @Storage(key: .chatDarkTheme(.background(.surface(.variant))))
    static var backgroundSurfaceVariantDarkColor: Color?
    
    @Storage(key: .chatLightTheme(.background(.surface(.container))))
    static var backgroundSurfaceContainerLightColor: Color?
    
    @Storage(key: .chatDarkTheme(.background(.surface(.container))))
    static var backgroundSurfaceContainerDarkColor: Color?
    
    @Storage(key: .chatLightTheme(.background(.surface(.subtle))))
    static var backgroundSurfaceSubtleLightColor: Color?
    
    @Storage(key: .chatDarkTheme(.background(.surface(.subtle))))
    static var backgroundSurfaceSubtleDarkColor: Color?
    
    @Storage(key: .chatLightTheme(.background(.surface(.emphasis))))
    static var backgroundSurfaceEmphasisLightColor: Color?
    
    @Storage(key: .chatDarkTheme(.background(.surface(.emphasis))))
    static var backgroundSurfaceEmphasisDarkColor: Color?
    
    // MARK: - Properties - Theme/Content
    
    @Storage(key: .chatLightTheme(.content(.primary)))
    static var contentPrimaryLightColor: Color?
    
    @Storage(key: .chatDarkTheme(.content(.primary)))
    static var contentPrimaryDarkColor: Color?
    
    @Storage(key: .chatLightTheme(.content(.secondary)))
    static var contentSecondaryLightColor: Color?
    
    @Storage(key: .chatDarkTheme(.content(.secondary)))
    static var contentSecondaryDarkColor: Color?
    
    @Storage(key: .chatLightTheme(.content(.tertiary)))
    static var contentTertiaryLightColor: Color?
    
    @Storage(key: .chatDarkTheme(.content(.tertiary)))
    static var contentTertiaryDarkColor: Color?
    
    @Storage(key: .chatLightTheme(.content(.inverse)))
    static var contentInverseLightColor: Color?
    
    @Storage(key: .chatDarkTheme(.content(.inverse)))
    static var contentInverseDarkColor: Color?
    
    // MARK: - Properties - Theme/Brand
    
    @Storage(key: .chatLightTheme(.brand(.primary)))
    static var brandPrimaryLightColor: Color?
    
    @Storage(key: .chatDarkTheme(.brand(.primary)))
    static var brandPrimaryDarkColor: Color?
    
    @Storage(key: .chatLightTheme(.brand(.onPrimary)))
    static var brandOnPrimaryLightColor: Color?
    
    @Storage(key: .chatDarkTheme(.brand(.onPrimary)))
    static var brandOnPrimaryDarkColor: Color?
    
    @Storage(key: .chatLightTheme(.brand(.primaryContainer)))
    static var brandPrimaryContainerLightColor: Color?
    
    @Storage(key: .chatDarkTheme(.brand(.primaryContainer)))
    static var brandPrimaryContainerDarkColor: Color?
    
    @Storage(key: .chatLightTheme(.brand(.onPrimaryContainer)))
    static var brandOnPrimaryContainerLightColor: Color?
    
    @Storage(key: .chatDarkTheme(.brand(.onPrimaryContainer)))
    static var brandOnPrimaryContainerDarkColor: Color?
    
    @Storage(key: .chatLightTheme(.brand(.secondary)))
    static var brandSecondaryLightColor: Color?
    
    @Storage(key: .chatDarkTheme(.brand(.secondary)))
    static var brandSecondaryDarkColor: Color?
    
    @Storage(key: .chatLightTheme(.brand(.onSecondary)))
    static var brandOnSecondaryLightColor: Color?
    
    @Storage(key: .chatDarkTheme(.brand(.onSecondary)))
    static var brandOnSecondaryDarkColor: Color?
    
    @Storage(key: .chatLightTheme(.brand(.secondaryContainer)))
    static var brandSecondaryContainerLightColor: Color?
    
    @Storage(key: .chatDarkTheme(.brand(.secondaryContainer)))
    static var brandSecondaryContainerDarkColor: Color?
    
    @Storage(key: .chatLightTheme(.brand(.onSecondaryContainer)))
    static var brandOnSecondaryContainerLightColor: Color?
    
    @Storage(key: .chatDarkTheme(.brand(.onSecondaryContainer)))
    static var brandOnSecondaryContainerDarkColor: Color?
    
    // MARK: - Properties - Theme/Border
    
    @Storage(key: .chatLightTheme(.border(.default)))
    static var borderDefaultLightColor: Color?
    
    @Storage(key: .chatDarkTheme(.border(.default)))
    static var borderDefaultDarkColor: Color?
    
    @Storage(key: .chatLightTheme(.border(.subtle)))
    static var borderSubtleLightColor: Color?
    
    @Storage(key: .chatDarkTheme(.border(.subtle)))
    static var borderSubtleDarkColor: Color?
    
    // MARK: - Properties - Theme/Status
    
    @Storage(key: .chatLightTheme(.status(.success)))
    static var statusSuccessLightColor: Color?
    
    @Storage(key: .chatDarkTheme(.status(.success)))
    static var statusSuccessDarkColor: Color?
    
    @Storage(key: .chatLightTheme(.status(.onSuccess)))
    static var statusOnSuccessLightColor: Color?
    
    @Storage(key: .chatDarkTheme(.status(.onSuccess)))
    static var statusOnSuccessDarkColor: Color?
    
    @Storage(key: .chatLightTheme(.status(.successContainer)))
    static var statusSuccessContainerLightColor: Color?
    
    @Storage(key: .chatDarkTheme(.status(.successContainer)))
    static var statusSuccessContainerDarkColor: Color?
    
    @Storage(key: .chatLightTheme(.status(.onSuccessContainer)))
    static var statusOnSuccessContainerLightColor: Color?
    
    @Storage(key: .chatDarkTheme(.status(.onSuccessContainer)))
    static var statusOnSuccessContainerDarkColor: Color?
    
    @Storage(key: .chatLightTheme(.status(.warning)))
    static var statusWarningLightColor: Color?
    
    @Storage(key: .chatDarkTheme(.status(.warning)))
    static var statusWarningDarkColor: Color?
    
    @Storage(key: .chatLightTheme(.status(.onWarning)))
    static var statusOnWarningLightColor: Color?
    
    @Storage(key: .chatDarkTheme(.status(.onWarning)))
    static var statusOnWarningDarkColor: Color?
    
    @Storage(key: .chatLightTheme(.status(.warningContainer)))
    static var statusWarningContainerLightColor: Color?
    
    @Storage(key: .chatDarkTheme(.status(.warningContainer)))
    static var statusWarningContainerDarkColor: Color?
    
    @Storage(key: .chatLightTheme(.status(.onWarningContainer)))
    static var statusOnWarningContainerLightColor: Color?
    
    @Storage(key: .chatDarkTheme(.status(.onWarningContainer)))
    static var statusOnWarningContainerDarkColor: Color?
    
    @Storage(key: .chatLightTheme(.status(.error)))
    static var statusErrorLightColor: Color?
    
    @Storage(key: .chatDarkTheme(.status(.error)))
    static var statusErrorDarkColor: Color?
    
    @Storage(key: .chatLightTheme(.status(.onError)))
    static var statusOnErrorLightColor: Color?
    
    @Storage(key: .chatDarkTheme(.status(.onError)))
    static var statusOnErrorDarkColor: Color?
    
    @Storage(key: .chatLightTheme(.status(.errorContainer)))
    static var statusErrorContainerLightColor: Color?
    
    @Storage(key: .chatDarkTheme(.status(.errorContainer)))
    static var statusErrorContainerDarkColor: Color?
    
    @Storage(key: .chatLightTheme(.status(.onErrorContainer)))
    static var statusOnErrorContainerLightColor: Color?
    
    @Storage(key: .chatDarkTheme(.status(.onErrorContainer)))
    static var statusOnErrorContainerDarkColor: Color?
    
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
        
        let cases: [LocalStorageKey] = LocalStorageKey.Theme.allCases.map { .chatLightTheme($0) }
            + LocalStorageKey.Theme.allCases.map { .chatDarkTheme($0) }
        
        cases.forEach { key in
            UserDefaults.standard.removeObject(forKey: key.rawValue)
        }
        
        UserDefaults.standard.synchronize()
    }
}
