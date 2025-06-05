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

class SettingsThemeColorViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var colorCode: String
    
    let title: String
    let didUpdateColor: (String, Color?) -> Void
    
    // MARK: - Init
    
    init(color: Color, title: String, didUpdateColor: @escaping (String, Color?) -> Void) {
        self.didUpdateColor = didUpdateColor
        self.title = title
        self._colorCode = Published(initialValue: color == .clear ? "" : color.toHexString)
    }
}

// MARK: - Actions

extension SettingsThemeColorViewModel {
    
    func onCodeChanged(_ colorCode: String) {
        Log.trace("Color code changed for `\(title)` to `\(colorCode)`")
        
        didUpdateColor(title, Color(hex: colorCode))
    }
}
