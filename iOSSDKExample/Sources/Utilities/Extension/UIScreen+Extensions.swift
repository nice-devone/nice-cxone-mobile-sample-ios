//
// Copyright (c) 2021-2026. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-sample-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN "AS IS" BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

import UIKit

extension UIScreen {

    /// Bounds of the foreground scene's screen, falling back to `UIScreen.main.bounds`
    /// when no `UIWindowScene` is available (cold launch, SwiftUI previews, headless tests)
    /// so callers that rely on a non-zero rect at first access do not collapse to zero.
    @MainActor
    static var currentBounds: CGRect {
        UIWindowScene.activeWindowScene?.screen.bounds ?? UIScreen.main.bounds
    }
}
