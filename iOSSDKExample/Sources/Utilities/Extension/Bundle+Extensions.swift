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

extension Bundle {
    
    var buildVersion: String {
        guard let buildVersion = infoDictionary?["CFBundleVersion"] as? String else {
            Log.error(.unableToParse("buildVersion", from: infoDictionary))
            return "Unknown"
        }
        
        return buildVersion
    }
    
    var branchName: String {
        guard let branchName = infoDictionary?["GitBranch"] as? String else {
            Log.error(.unableToParse("branchName", from: infoDictionary))
            return "Unknown"
        }
        
        return branchName
    }
    
    var commitHash: String {
        guard let branchName = infoDictionary?["GitCommit"] as? String else {
            Log.error(.unableToParse("commitHash", from: infoDictionary))
            return "Unknown"
        }
        
        return branchName
    }
    
    var branchTag: String? {
        infoDictionary?["GitTag"] as? String
    }
}
