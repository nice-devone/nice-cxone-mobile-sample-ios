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
import UIKit

extension UISegmentedControl {
    
    static func defaultAppearance() {
        Self.appearance(trait: UITraitCollection(userInterfaceStyle: .dark))
        Self.appearance(trait: UITraitCollection(userInterfaceStyle: .light))
    }
}

// MARK: - Helpers

private extension UISegmentedControl {
    
    static func appearance(trait: UITraitCollection) {
        let isDarkModeActive = trait.userInterfaceStyle == .dark
        
        UISegmentedControl.appearance(for: trait).selectedSegmentTintColor = .systemBackground
        UISegmentedControl.appearance(for: trait).setTitleTextAttributes(
            [.foregroundColor: isDarkModeActive ? UIColor.white : UIColor.black],
            for: .selected
        )
        UISegmentedControl.appearance(for: trait).setTitleTextAttributes(
            [.foregroundColor: (isDarkModeActive ? UIColor.white : UIColor.black).withAlphaComponent(0.5)],
            for: .normal
        )
        UISegmentedControl.appearance(for: trait).backgroundColor = .systemBackground
    }
}
