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

struct SettingsView: View {

    // MARK: - Properties

    @ObservedObject var viewModel: SettingsViewModel

    // MARK: - Content

    var body: some View {
        Form {
            sdkInfoSectionView

            uiInfoSectionView
            
            logsSectionView

            themeColorSectionView
        }
        .alert(isPresented: $viewModel.showInvalidColorError, title: L10n.Common.attention, message: L10n.Settings.Theme.NoColor.alertMessage)
        .navigationBarTitle(L10n.Settings.title)
    }
}

// MARK: - Subviews

private extension SettingsView {
    
    var sdkInfoSectionView: some View {
        Section(header: Text(L10n.Settings.Sdk.title)) {
            HStack {
                Text(L10n.Settings.Module.version)

                Spacer()

                Text(viewModel.sdkVersion)
                    .fontWeight(.bold)
            }
            
            HStack(alignment: .bottom, spacing: 2) {
                Text(L10n.Settings.Sdk.RestoreCustomerName.currentName)
                
                Spacer()
                
                Text(String(format: "%@ %@", viewModel.firstName ?? "", viewModel.lastName ?? ""))
                    .fontWeight(.bold)
            }
        }
    }
    
    var uiInfoSectionView: some View {
        Section(header: Text(L10n.Settings.Ui.title)) {
            HStack {
                Text(L10n.Settings.Module.version)

                Spacer()

                Text(viewModel.uiVersion)
                    .fontWeight(.bold)
            }
        }
    }

    var logsSectionView: some View {
        Section(header: Text(L10n.Settings.Logs.title)) {
            HStack {
                Text(L10n.Settings.Logs.Share.label)

                Spacer()

                Button(L10n.Settings.Logs.Share.button) {
                    viewModel.shouldShareLogs.toggle()
                }
                .sheet(isPresented: $viewModel.shouldShareLogs) {
                    SettingsShareLogsDialogView()
                }
            }
            HStack {
                Text(L10n.Settings.Logs.Remove.label)

                Spacer()

                Button(L10n.Settings.Logs.Remove.button) {
                    viewModel.showRemoveLogsAlert = true
                }
                .alert(isPresented: $viewModel.showRemoveLogsAlert) {
                    Alert(title: Text(L10n.Settings.Logs.Remove.label), message: Text(viewModel.removeLogs()))
                }
            }
        }
    }

    var themeColorSectionView: some View {
        Section(header: Text(L10n.Settings.Theme.title)) {
            Text(L10n.Settings.Theme.info)

            SettingsThemeColorView(
                color: viewModel.navigationBarColor,
                title: L10n.Settings.Theme.ChatNavigationBarColorField.placeholder
            ) { fieldTitle, color in
                viewModel.colorDidChange(color: color, for: fieldTitle)
            }

            SettingsThemeColorView(
                color: viewModel.navigationBarElementsColor,
                title: L10n.Settings.Theme.ChatNavigationElementsColorField.placeholder
            ) { fieldTitle, color in
                viewModel.colorDidChange(color: color, for: fieldTitle)
            }

            SettingsThemeColorView(
                color: viewModel.backgroundColor,
                title: L10n.Settings.Theme.ChatBackgroundColorField.placeholder
            ) { fieldTitle, color in
                viewModel.colorDidChange(color: color, for: fieldTitle)
            }

            SettingsThemeColorView(
                color: viewModel.agentCellColor,
                title: L10n.Settings.Theme.ChatAgentCellColorField.placeholder
            ) { fieldTitle, color in
                viewModel.colorDidChange(color: color, for: fieldTitle)
            }

            SettingsThemeColorView(
                color: viewModel.customerCellColor,
                title: L10n.Settings.Theme.ChatCustomerCellColorField.placeholder
            ) { fieldTitle, color in
                viewModel.colorDidChange(color: color, for: fieldTitle)
            }

            SettingsThemeColorView(
                color: viewModel.agentFontColor,
                title: L10n.Settings.Theme.ChatAgentFontColorField.placeholder
            ) { fieldTitle, color in
                viewModel.colorDidChange(color: color, for: fieldTitle)
            }

            SettingsThemeColorView(
                color: viewModel.customerFontColor,
                title: L10n.Settings.Theme.ChatCustomerFontColorField.placeholder
            ) { fieldTitle, color in
                viewModel.colorDidChange(color: color, for: fieldTitle)
            }
            
            SettingsThemeColorView(
                color: viewModel.formTextColor,
                title: L10n.Settings.Theme.ChatFormTextColor.placeholder
            ) { fieldTitle, color in
                viewModel.colorDidChange(color: color, for: fieldTitle)
            }
            
            SettingsThemeColorView(
                color: viewModel.formErrorColor,
                title: L10n.Settings.Theme.ChatFormErrorColor.placeholder
            ) { fieldTitle, color in
                viewModel.colorDidChange(color: color, for: fieldTitle)
            }
            
            SettingsThemeColorView(
                color: viewModel.buttonTextColor,
                title: L10n.Settings.Theme.ChatButtonTextColor.placeholder
            ) { fieldTitle, color in
                viewModel.colorDidChange(color: color, for: fieldTitle)
            }
            
            SettingsThemeColorView(
                color: viewModel.buttonBackgroundColor,
                title: L10n.Settings.Theme.ChatButtonBackgroundColor.placeholder
            ) { fieldTitle, color in
                viewModel.colorDidChange(color: color, for: fieldTitle)
            }
        }
    }
}

// MARK: - Previews

#Preview {
    let appModule = PreviewAppModule(coordinator: LoginCoordinator(navigationController: UINavigationController()))
    
    return NavigationView {
        // swiftlint:disable:next force_unwrapping
        appModule.resolver.resolve(SettingsView.self)!
    }
}
