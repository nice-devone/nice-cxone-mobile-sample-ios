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

protocol Alertable {
    
    func alertContent(for alertType: AlertType) -> Alert
}

// MARK: - Default Implementation

extension Alertable {
    
    func alertContent(for alertType: AlertType) -> Alert {
        let primaryAction: Alert.Button = alertType.primary
        let secondaryAction: Alert.Button? = alertType.secondary
        
        return secondaryAction.map { secondaryAction in
            Alert(
                title: Text(alertType.title),
                message: Text(alertType.message),
                primaryButton: primaryAction,
                secondaryButton: secondaryAction
            )
        } ?? Alert(
            title: Text(alertType.title),
            message: Text(alertType.message),
            dismissButton: primaryAction
        )
    }
}

// MARK: - Model

final class AlertType: Identifiable {
    
    // MARK: - Properties
    
    let title: String
    let message: String
    let primary: Alert.Button
    let secondary: Alert.Button?
    
    // MARK: - Init
    
    init(title: String, message: String, primary: Alert.Button, secondary: Alert.Button? = nil) {
        self.title = title
        self.message = message
        self.primary = primary
        self.secondary = secondary
    }
    
    // MARK: - Static methods
    
    static func genericError(primaryAction: (() -> Void)?) -> AlertType {
        AlertType(
            title: L10n.Common.oops,
            message: L10n.Common.genericError,
            primary: .destructive(Text(L10n.Common.confirm), action: primaryAction),
            secondary: .cancel()
        )
    }
    
    static func loginError(brandId: Int, channelId: String, primaryAction: @escaping () -> Void, secondaryAction: @escaping () -> Void) -> AlertType {
        AlertType(
            title: L10n.Common.oops,
            message: L10n.Login.ConfigurationFetchFailed.message(brandId, channelId),
            primary: .default(Text(L10n.Login.Repeat.buttonTitle), action: primaryAction),
            secondary: .destructive(Text(L10n.Common.cancel), action: secondaryAction)
        )
    }
    
    static func configMissingFieldsError() -> AlertType {
        AlertType(
            title: L10n.Configuration.Default.MissingFields.title,
            message: L10n.Configuration.Default.MissingFields.message,
            primary: .cancel()
        )
    }
    
    static func sdkVersionNotSupportedError(primaryAction: @escaping () -> Void) -> AlertType {
        AlertType(
            title: L10n.Common.oops,
            message: L10n.Login.UnsupportedSdkVersion.message,
            primary: .destructive(Text(L10n.Common.confirm), action: primaryAction)
        )
    }
}
