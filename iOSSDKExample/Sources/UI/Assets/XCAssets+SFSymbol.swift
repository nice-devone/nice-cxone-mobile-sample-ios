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
import UIKit

extension Asset {
    
    enum Common {
        static let clear = Image(systemName: "xmark.circle.fill")
        static let success = Image(systemName: "checkmark.circle")
        static let circle = Image(systemName: "circle")
        static let settings = Image(systemName: "gear")
        static let disconnect = Image(systemName: "bolt.slash.fill")
        static let disclosure = Image(systemName: "chevron.right")
        static let check = Image(systemName: "checkmark")
    }
    
    enum Settings {
        static let brandLogoPlaceholder: Image = Image(systemName: "photo")
    }
    
    enum Chat {
        static let newThread: Image = Image(systemName: "plus")
        static let sendEvents: Image = Image(systemName: "arrow.up.square")
        static let editThreadName: Image = Image(systemName: "square.and.pencil")
    }
    
    enum Message {
        static let send: Image = Image(systemName: "arrow.up.circle.fill")
        static let attachments: Image = Image(systemName: "arrow.up.doc")
        static let record: Image = Image(systemName: "mic")
    }
    
    enum Store {
        static let search = Image(systemName: "magnifyingglass")
        static let cart = Image(systemName: "cart")
        static let chat = Image(systemName: "text.bubble.fill")
        
        enum Product {
            static let imagePlaceholder = Image(systemName: "photo")
            static let rating = Image(systemName: "star")
            static let add = Image(systemName: "plus.circle.fill")
            
        }
    }
}
