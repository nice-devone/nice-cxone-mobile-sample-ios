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

struct SettingsAdditionalCustomFieldsView: View {
    
    // MARK: - Properties
    
    @Binding var isVisible: Bool
    
    @State private var key: String = ""
    @State private var value: String = ""
    
    let customFields: [String: String]
    let onConfirm: (String, String) -> Void
    let onRemove: (String) -> Void
    
    // MARK: - Builder
    
    @ViewBuilder
    var body: some View {
        if isVisible {
            newFieldSection
        }
        
        fieldListSection
    }
}

// MARK: - Subviews

private extension SettingsAdditionalCustomFieldsView {

    var newFieldSection: some View {
        HStack {
            HStack(alignment: .bottom, spacing: 4) {
                Text(L10n.Settings.Ui.ChatAdditionalCustomFields.keyLabel)
                    .font(.footnote)
                    .foregroundStyle(Color.gray)
                
                TextField(L10n.Settings.Ui.ChatAdditionalCustomFields.keyPlaceholder, text: $key)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.done)
            }
            
            HStack(alignment: .bottom, spacing: 4) {
                Text(L10n.Settings.Ui.ChatAdditionalCustomFields.valueLabel)
                    .font(.footnote)
                    .foregroundStyle(Color.gray)
                
                TextField(L10n.Settings.Ui.ChatAdditionalCustomFields.valuePlaceholder, text: $value)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.done)
            }
            
            Spacer(minLength: 20)
            
            Button {
                withAnimation {
                    isVisible = false
                    
                    onConfirm(key, value)
                    
                    key = ""
                    value = ""
                }
            } label: {
                Asset.Images.Settings.addCustomField
            }
            .disabled(key.isEmpty || value.isEmpty)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                withAnimation {
                    isVisible = false
                    
                    key = ""
                    value = ""
                }
            } label: {
                Label {
                    Text(L10n.Settings.Ui.ChatAdditionalCustomFields.rowDelete)
                } icon: {
                    Asset.Images.Settings.removeCustomFieldRow
                }
            }
        }
        .padding(.leading, 12)
    }
    
    var fieldListSection: some View {
        ForEach(Array(customFields), id: \.key) { customField in
            HStack {
                HStack(alignment: .bottom, spacing: 2) {
                    Text(L10n.Settings.Ui.ChatAdditionalCustomFields.keyLabel)
                        .font(.footnote)
                        .foregroundStyle(Color.gray)
                    
                    Text(customField.key)
                        .bold()
                }
                
                HStack(alignment: .bottom, spacing: 2) {
                    Text(L10n.Settings.Ui.ChatAdditionalCustomFields.valueLabel)
                        .font(.footnote)
                        .foregroundStyle(Color.gray)
                    
                    Text(customField.value)
                        .bold()
                }
                
                Spacer()
                
                Button {
                    withAnimation {
                        onRemove(customField.key)
                    }
                } label: {
                    Asset.Images.Settings.removeCustomField
                        .foregroundStyle(Color.red)
                }
            }
        }
    }
}
