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

struct SettingsThemeColorView: View {
    
    // MARK: - Properties

    @State private var colorCodeString: String
    
    private let title: String
    private let didUpdateColor: (String, Color?) -> Void

    // MARK: - Content

    init(color: Color, title: String, didUpdateColor: @escaping (String, Color?) -> Void) {
        self.title = title
        self.didUpdateColor = didUpdateColor
        
        _colorCodeString = State(initialValue: color == .clear ? "" : color.toHexString)
    }
    
    // MARK: - Builder
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(Font.footnote.weight(.light))
                    .frame(maxWidth: .infinity, alignment: .leading)

                TextField(L10n.Settings.Theme.NoColor.placeholder, text: $colorCodeString) { isEditing in
                    guard !isEditing else {
                        return
                    }
                    
                    didUpdateColor(title, Color(hex: colorCodeString))
                }
                .introspect(.textField, on: .iOS(.v14, .v15, .v16, .v17)) { field in
                    field.returnKeyType = .done
                }
                
                if colorCodeString.isEmpty {
                    Text(L10n.Settings.Theme.NoColor.error)
                        .font(.caption2)
                        .foregroundColor(.red)
                }
            }

            Spacer()

            Color(hex: colorCodeString)
                .frame(width: 50, height: 25, alignment: .trailing)
                .border(colorCodeString.isEmpty ? .clear : .black)
        }
    }
}

// MARK: - Previews

struct SettingsThemeColorView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack {
                SettingsThemeColorView(color: .red, title: "Title") { _, _ in }
                
                SettingsThemeColorView(color: .clear, title: "Title") { _, _ in }
            }
            .previewDisplayName("Light Mode")
            
            VStack {
                SettingsThemeColorView(color: .red, title: "Title") { _, _ in }
                
                SettingsThemeColorView(color: .clear, title: "Title") { _, _ in }
            }
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
        .padding()
    }
}
