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

extension UINavigationController {
    
    func setNormalAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemBackground
        appearance.shadowColor = nil
        appearance.shadowImage = nil
        
        navigationBar.shadowImage = UIImage()
        navigationBar.tintColor = .systemBlue
        navigationBar.barTintColor = .systemBackground
        navigationBar.standardAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
    }
    
    func setCustomAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor(ChatAppearance.navigationBarColor)
        appearance.shadowColor = nil
        appearance.shadowImage = nil
        appearance.titleTextAttributes = [.foregroundColor: UIColor(ChatAppearance.navigationBarElementsColor)]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(ChatAppearance.navigationBarElementsColor)]
        
        navigationBar.shadowImage = UIImage()
        navigationBar.tintColor = UIColor(ChatAppearance.navigationBarElementsColor)
        navigationBar.barTintColor = UIColor(ChatAppearance.navigationBarColor)
        navigationBar.standardAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        
        UISegmentedControl.appearance().backgroundColor = UIColor(ChatAppearance.backgroundColor.opacity(0.8))
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(ChatAppearance.customerCellColor)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(ChatAppearance.customerFontColor)], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(ChatAppearance.agentFontColor)], for: .normal)
    }
}
