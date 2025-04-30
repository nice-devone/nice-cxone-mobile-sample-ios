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

extension Asset.Images {
    
    enum Common {
        static let clear = Image(systemName: "xmark.circle.fill")
        static let success = Image(systemName: "checkmark.circle")
        static let settings = Image(systemName: "gear")
        static let disconnect = Image(systemName: "bolt.slash.fill")
    }
    
    enum Settings {
        static let removeCustomField = Image(systemName: "minus.circle")
        static let addCustomField = Image(systemName: "plus.circle")
        static let removeCustomFieldRow = Image(systemName: "trash")
    }
    
    enum Store {
        static let search = Image(systemName: "magnifyingglass")
        static let cart = Image(systemName: "cart")
        static let chat = Image(systemName: "text.bubble.fill")
        
        enum Product {
            static let imagePlaceholder = Image(systemName: "photo")
            static let rating = Image(systemName: "star")
        }
    }
}
