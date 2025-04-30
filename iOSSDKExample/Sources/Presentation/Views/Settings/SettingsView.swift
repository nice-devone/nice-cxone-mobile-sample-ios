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

struct SettingsView: View {

    // MARK: - Properties

    @ObservedObject var viewModel: SettingsViewModel

    // MARK: - Content

    var body: some View {
        Form {
            buildSectionView
            
            sdkInfoSectionView

            uiInfoSectionView
            
            logsSectionView

            themeColorSectionView
        }
        .onDisappear(perform: viewModel.onDisappear)
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
            
            Picker(L10n.Settings.Ui.ChatPresentationStyle.title, selection: $viewModel.chatPresentationStyle) {
                Text(L10n.Settings.Ui.ChatPresentationStyle.optionModal).tag(ChatPresentationStyle.modal)
                Text(L10n.Settings.Ui.ChatPresentationStyle.optionFullscreen).tag(ChatPresentationStyle.fullScreen)
            }
            .onChange(of: viewModel.chatPresentationStyle, perform: viewModel.chatPresentationStyleChanged)
            
            Group {
                additionalContactCustomFields
                
                additionalCustomerCustomFields
            }
        }
        .animation(.default, value: viewModel.additionalContactCustomFields)
        .animation(.default, value: viewModel.additionalCustomerCustomFields)
    }
    
    @ViewBuilder
    var additionalContactCustomFields: some View {
        HStack {
            Text(L10n.Settings.Ui.ChatAdditionalContactCustomFields.title)
                .fontWeight(.medium)
            
            Spacer()
            
            if !viewModel.isAdditionalContactFieldVisible {
                Button(L10n.Common.add) {
                    withAnimation {
                        viewModel.isAdditionalContactFieldVisible = true
                    }
                }
            }
        }
        
        SettingsAdditionalCustomFieldsView(
            isVisible: $viewModel.isAdditionalContactFieldVisible,
            customFields: viewModel.additionalContactCustomFields,
            onConfirm: viewModel.setAdditionalContactCustomField,
            onRemove: viewModel.removeAdditionalContactCustomField
        )
    }
    
    @ViewBuilder
    var additionalCustomerCustomFields: some View {
        HStack {
            Text(L10n.Settings.Ui.ChatAdditionalCustomerCustomFields.title)
                .fontWeight(.medium)
            
            Spacer()
            
            if !viewModel.isAdditionalCustomerFieldVisible {
                Button(L10n.Common.add) {
                    withAnimation {
                        viewModel.isAdditionalCustomerFieldVisible = true
                    }
                }
            }
        }
        
        SettingsAdditionalCustomFieldsView(
            isVisible: $viewModel.isAdditionalCustomerFieldVisible,
            customFields: viewModel.additionalCustomerCustomFields,
            onConfirm: viewModel.setAdditionalCustomerCustomField,
            onRemove: viewModel.removeAdditionalCustomerCustomField
        )
    }
    
    var buildSectionView: some View {
        Section(header: Text(L10n.Settings.Build.title)) {
            HStack {
                Text(L10n.Settings.Build.buildNumber)

                Spacer()

                Text(viewModel.appBuildNumber)
                    .fontWeight(.bold)
            }
            
            HStack {
                Text(L10n.Settings.Build.branchName)
                
                Spacer()
                
                Text(viewModel.appBranchName)
                    .fontWeight(.bold)
            }
            
            if let tag = viewModel.appBranchTag {
                HStack {
                    Text(L10n.Settings.Build.branchTag)
                    
                    Spacer()
                    
                    Text(tag)
                        .fontWeight(.bold)
                }
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
                color: ChatAppearance.primaryColor,
                title: L10n.Settings.Theme.Primary.placeholder
            ) { fieldTitle, color in
                viewModel.colorDidChange(color: color, for: fieldTitle)
            }

            SettingsThemeColorView(
                color: ChatAppearance.onPrimaryColor,
                title: L10n.Settings.Theme.OnPrimary.placeholder
            ) { fieldTitle, color in
                viewModel.colorDidChange(color: color, for: fieldTitle)
            }

            SettingsThemeColorView(
                color: ChatAppearance.backgroundColor,
                title: L10n.Settings.Theme.Background.placeholder
            ) { fieldTitle, color in
                viewModel.colorDidChange(color: color, for: fieldTitle)
            }

            SettingsThemeColorView(
                color: ChatAppearance.onBackgroundColor,
                title: L10n.Settings.Theme.OnBackground.placeholder
            ) { fieldTitle, color in
                viewModel.colorDidChange(color: color, for: fieldTitle)
            }

            SettingsThemeColorView(
                color: ChatAppearance.accentColor,
                title: L10n.Settings.Theme.Accent.placeholder
            ) { fieldTitle, color in
                viewModel.colorDidChange(color: color, for: fieldTitle)
            }

            SettingsThemeColorView(
                color: ChatAppearance.onAccentColor,
                title: L10n.Settings.Theme.OnAccent.placeholder
            ) { fieldTitle, color in
                viewModel.colorDidChange(color: color, for: fieldTitle)
            }

            SettingsThemeColorView(
                color: ChatAppearance.agentBackgroundColor,
                title: L10n.Settings.Theme.AgentBackground.placeholder
            ) { fieldTitle, color in
                viewModel.colorDidChange(color: color, for: fieldTitle)
            }
            
            SettingsThemeColorView(
                color: ChatAppearance.agentTextColor,
                title: L10n.Settings.Theme.AgentText.placeholder
            ) { fieldTitle, color in
                viewModel.colorDidChange(color: color, for: fieldTitle)
            }
            
            SettingsThemeColorView(
                color: ChatAppearance.customerBackgroundColor,
                title: L10n.Settings.Theme.CustomerBackground.placeholder
            ) { fieldTitle, color in
                viewModel.colorDidChange(color: color, for: fieldTitle)
            }
            
            SettingsThemeColorView(
                color: ChatAppearance.customerTextColor,
                title: L10n.Settings.Theme.CustomerText.placeholder
            ) { fieldTitle, color in
                viewModel.colorDidChange(color: color, for: fieldTitle)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        SettingsView(viewModel: SettingsViewModel { })
    }
}
