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

import SwiftUI

final class AlertType: Identifiable {
    
    // MARK: - Properties
    
    let id = UUID()
    let title: String
    let message: Text
    let actions: AnyView
    
    // MARK: - Init
    
    init<Content: View>(title: String, message: String, @ViewBuilder actions: () -> Content) {
        self.title = title
        self.message = Text(message)
        self.actions = AnyView(actions())
    }
    
    // MARK: - Static methods
    
    @MainActor
    static let genericError = AlertType(title: L10n.Error.Generic.title, message: L10n.Error.Generic.message) {
        Button(L10n.Common.cancel)
    }
    
    static func loginError(brandId: Int, channelId: String, primaryAction: @escaping () -> Void, secondaryAction: @escaping () -> Void) -> AlertType {
        AlertType(
            title: L10n.Error.Generic.title,
            message: L10n.Login.ConfigurationFetchFailed.message(brandId, channelId)
        ) {
            Button(L10n.Common.cancel, action: secondaryAction)
            
            Button(L10n.Login.Repeat.buttonTitle, action: primaryAction)
        }
    }
    
    @MainActor
    static let configMissingFieldsError = AlertType(
        title: L10n.Configuration.Default.MissingFields.title,
        message: L10n.Configuration.Default.MissingFields.message
    ) {
        Button(L10n.Common.cancel)
    }
    
    static func sdkVersionNotSupportedError(_ action: @escaping () -> Void) -> AlertType {
        AlertType(
            title: L10n.Error.Generic.title,
            message: L10n.Error.UnsupportedSdkVersion.message
        ) {
            Button(L10n.Common.confirm, action: action)
        }
    }
}

// MARK: - Preview

@available(iOS 17, *)
#Preview {
    @Previewable @State var showAlert = false
    @Previewable @State var alertTypeName: SelectedAlertType = .genericError
    @Previewable @State var alertType: AlertType? = .genericError
    
    VStack {
        Text("Select Alert")
        
        Picker("Select Alert", selection: $alertTypeName) {
            ForEach(SelectedAlertType.allCases) { type in
                Text(type.rawValue).tag(type)
            }
        }
        .pickerStyle(.wheel)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemGray6))
        )
        
        Button("Show Alert") {
            showAlert.toggle()
        }
        .onChange(of: alertTypeName) { name in
            switch name {
            case .genericError:
                alertType = .genericError
            case .loginError:
                alertType = .loginError(brandId: 0, channelId: "", primaryAction: { }, secondaryAction: { })
            case .configMissingFieldsError:
                alertType = .configMissingFieldsError
            case .sdkVersionNotSupportedError:
                alertType = .sdkVersionNotSupportedError { }
            }
        }
    }
    .padding(.horizontal, 12)
    .alertable(isPresented: $showAlert, presenting: alertType)
}

private enum SelectedAlertType: String, CaseIterable, Identifiable {
    case genericError
    case loginError
    case configMissingFieldsError
    case sdkVersionNotSupportedError

    var id: String { self.rawValue }
}
