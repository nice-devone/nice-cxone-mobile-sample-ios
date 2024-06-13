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

struct SettingsShareLogsDialogView: UIViewControllerRepresentable {

    // MARK: - Functions

    func makeUIViewController(context: Context) -> UIActivityViewController {
        guard let activityView = try? Log.getLogShareDialog() else {
            return UIActivityViewController(activityItems: [], applicationActivities: nil)
        }
        
        return activityView
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) { }
}
