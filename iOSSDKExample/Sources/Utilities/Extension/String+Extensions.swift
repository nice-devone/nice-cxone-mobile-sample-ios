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

import UIKit

extension String {
    
    func nilIfEmpty() -> String? {
        isEmpty ? nil : self
    }
    
    func substring(from: String) -> String? {
        guard let range = self.range(of: from) else {
            return nil
        }
        
        return String(self[range.upperBound...])
    }
    
    func substring(to: String) -> String? {
        guard let range = self.range(of: to) else {
            return nil
        }
        
        return String(self[..<range.lowerBound])
    }
    
    func substring(from: String, to: String) -> String? {
        guard let range = self.range(of: from) else {
            return nil
        }
        
        let subString = String(self[range.upperBound...])
        
        guard let range = subString.range(of: to) else {
            return nil
        }
        
        return String(subString[..<range.lowerBound])
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont.TextStyle) -> CGFloat {
        self.height(withConstrainedWidth: width, font: .preferredFont(forTextStyle: font))
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil
        )
    
        return ceil(boundingBox.height)
    }
}
