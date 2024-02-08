//
// Copyright (c) 2021-2023. NICE Ltd. All rights reserved.
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

enum ChatAppearance {
    
    static var navigationBarColor: Color {
        .themedColor(
            light: LocalStorageManager.chatNavigationBarLightColor ?? .white,
            dark: LocalStorageManager.chatNavigationBarDarkColor ?? .black
        )
    }
    static var navigationBarElementsColor: Color {
        .themedColor(
            light: LocalStorageManager.chatNavigationElementsLightColor ?? Color(.systemBlue),
            dark: LocalStorageManager.chatNavigationElementsDarkColor ?? Color(.systemBlue)
        )
    }
    static var backgroundColor: Color {
        .themedColor(
            light: LocalStorageManager.chatBackgroundLightColor ?? .white,
            dark: LocalStorageManager.chatBackgroundDarkColor ?? .black
        )
    }
    static var agentCellColor: Color {
        .themedColor(
            light: LocalStorageManager.chatAgentCellLightColor ?? Color(.lightGray),
            dark: LocalStorageManager.chatAgentCellDarkColor ?? Color(.lightGray)
        )
    }
    static var customerCellColor: Color {
        .themedColor(
            light: LocalStorageManager.chatCustomerCellLightColor ?? Color(.systemBlue),
            dark: LocalStorageManager.chatCustomerCellDarkColor ?? Color(.systemBlue)
        )
    }
    static var agentFontColor: Color {
        .themedColor(
            light: LocalStorageManager.chatAgentFontLightColor ?? .black,
            dark: LocalStorageManager.chatAgentFontDarkColor ?? .black
        )
    }
    static var customerFontColor: Color {
        .themedColor(
            light: LocalStorageManager.chatCustomerFontLightColor ?? .white,
            dark: LocalStorageManager.chatCustomerFontDarkColor ?? .white
        )
    }
    
    static var formTextColor: Color {
        .themedColor(
            light: LocalStorageManager.chatFormTextLightColor ?? .black,
            dark: LocalStorageManager.chatFormTextDarkColor ?? .white
        )
    }
    
    static var formErrorColor: Color {
        .themedColor(
            light: LocalStorageManager.chatFormErrorLightColor ?? .red,
            dark: LocalStorageManager.chatFormErrorDarkColor ?? .red
        )
    }
    
    static var buttonBackgroundColor: Color {
        .themedColor(
            light: LocalStorageManager.chatButtonBackgroundLightColor ?? .accentColor,
            dark: LocalStorageManager.chatButtonBackgroundDarkColor ?? .accentColor
        )
    }
    
    static var buttonTextColor: Color {
        .themedColor(
            light: LocalStorageManager.chatButtonTextLightColor ?? .white,
            dark: LocalStorageManager.chatButtonTextDarkColor ?? .white
        )
    }
}
