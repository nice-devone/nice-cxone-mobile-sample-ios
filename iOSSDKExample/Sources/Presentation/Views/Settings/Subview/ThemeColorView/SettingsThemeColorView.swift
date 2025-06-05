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

struct SettingsThemeColorView: View {
    
    // MARK: - Properties

    @ObservedObject private var viewModel: SettingsThemeColorViewModel
    
    @FocusState private var isFocused

    // MARK: - Content

    init(color: Color, title: String, didUpdateColor: @escaping (String, Color?) -> Void) {
        self.viewModel = SettingsThemeColorViewModel(color: color, title: title, didUpdateColor: didUpdateColor)
    }
    
    // MARK: - Builder
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(viewModel.title)
                    .font(Font.footnote.weight(.light))
                    .frame(maxWidth: .infinity, alignment: .leading)

                TextField(
                    L10n.Settings.Theme.NoColor.placeholder,
                    text: Binding<String>(
                        get: { viewModel.colorCode },
                        set: { viewModel.colorCode = $0 }
                    )
                )
                .submitLabel(.done)
                .focused($isFocused)
                
                if viewModel.colorCode.isEmpty {
                    Text(L10n.Settings.Theme.NoColor.error)
                        .font(.caption2)
                        .foregroundColor(.red)
                }
            }

            Spacer()

            Color(hex: viewModel.colorCode)
                .frame(width: 50, height: 25, alignment: .trailing)
                .border(viewModel.colorCode.isEmpty ? .clear : .black)
        }
        .onChange(of: isFocused) { isFocused in
            guard !isFocused else {
                return
            }
            
            viewModel.onCodeChanged(viewModel.colorCode)
        }
    }
}

// MARK: - Preview

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var backgroundColor = Color.red
    @Previewable @State var onBackgroundColor = Color.clear
    
    NavigationView {
        List {
            SettingsThemeColorView(color: backgroundColor, title: "Background") { _, color in
                backgroundColor = color ?? .clear
            }
            
            SettingsThemeColorView(color: onBackgroundColor, title: "On Background Color") { _, color in
                onBackgroundColor = color ?? .clear
            }
        }
        .navigationTitle("Settings")
    }
}
