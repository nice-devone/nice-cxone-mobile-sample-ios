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

    @State private var showResetToDefaultConfirmation = false
    
    // MARK: - Content

    var body: some View {
        List {
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
            
            HStack {
                Text(L10n.Settings.Build.commitHash)
                
                Spacer()
                
                Text(viewModel.appCommitHash)
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
        Section {
            themeBackgroundSection
            
            themeContentSection
            
            themeBrandSection
            
            themeBorderSection
            
            themeStatusSection
        } header: {
            HStack {
                Text(L10n.Settings.Theme.title)
                
                Spacer()
                
                Button(L10n.Settings.Theme.ResetToDefault.title) {
                    showResetToDefaultConfirmation = true
                }
                .truncationMode(.middle)
            }
        } footer: {
            Text(L10n.Settings.Theme.info)
                .font(.footnote)
        }
        .alert(isPresented: $showResetToDefaultConfirmation) {
            Alert(
                title: Text(L10n.Settings.Theme.Alert.ResetToDefault.title),
                message: Text(L10n.Settings.Theme.Alert.ResetToDefault.text),
                primaryButton: .default(Text(L10n.Common.confirm), action: viewModel.resetThemeToDefault),
                secondaryButton: .cancel()
            )
        }
    }
    
    var themeBackgroundSection: some View {
        DisclosureGroup {
            SettingsThemeColorView(
                color: ChatAppearance.Background.default,
                title: L10n.Settings.Theme.Background.Default.placeholder,
                didUpdateColor: viewModel.colorDidChange
            )
            
            SettingsThemeColorView(
                color: ChatAppearance.Background.inverse,
                title: L10n.Settings.Theme.Background.Inverse.placeholder,
                didUpdateColor: viewModel.colorDidChange
            )
            
            themeBackgroundSurfaceSection
        } label: {
            Text(L10n.Settings.Theme.Background.title)
                .font(.body.weight(.medium))
        }
    }
    
    var themeBackgroundSurfaceSection: some View {
        DisclosureGroup {
            SettingsThemeColorView(
                color: ChatAppearance.Background.Surface.default,
                title: L10n.Settings.Theme.Background.Surface.Default.placeholder,
                didUpdateColor: viewModel.colorDidChange
            )
            
            SettingsThemeColorView(
                color: ChatAppearance.Background.Surface.variant,
                title: L10n.Settings.Theme.Background.Surface.Variant.placeholder,
                didUpdateColor: viewModel.colorDidChange
            )
            
            SettingsThemeColorView(
                color: ChatAppearance.Background.Surface.container,
                title: L10n.Settings.Theme.Background.Surface.Container.placeholder,
                didUpdateColor: viewModel.colorDidChange
            )
            
            SettingsThemeColorView(
                color: ChatAppearance.Background.Surface.subtle,
                title: L10n.Settings.Theme.Background.Surface.Subtle.placeholder,
                didUpdateColor: viewModel.colorDidChange
            )
            
            SettingsThemeColorView(
                color: ChatAppearance.Background.Surface.emphasis,
                title: L10n.Settings.Theme.Background.Surface.Emphasis.placeholder,
                didUpdateColor: viewModel.colorDidChange
            )
        } label: {
            Text(L10n.Settings.Theme.Background.Surface.title)
                .font(.body.weight(.medium))
        }
    }
    
    @ViewBuilder
    var themeContentSection: some View {
        DisclosureGroup {
            SettingsThemeColorView(
                color: ChatAppearance.Content.primary,
                title: L10n.Settings.Theme.Content.Primary.placeholder,
                didUpdateColor: viewModel.colorDidChange
            )
            
            SettingsThemeColorView(
                color: ChatAppearance.Content.secondary,
                title: L10n.Settings.Theme.Content.Secondary.placeholder,
                didUpdateColor: viewModel.colorDidChange
            )
            
            SettingsThemeColorView(
                color: ChatAppearance.Content.tertiary,
                title: L10n.Settings.Theme.Content.Tertiary.placeholder,
                didUpdateColor: viewModel.colorDidChange
            )
            
            SettingsThemeColorView(
                color: ChatAppearance.Content.inverse,
                title: L10n.Settings.Theme.Content.Inverse.placeholder,
                didUpdateColor: viewModel.colorDidChange
            )
        } label: {
            Text(L10n.Settings.Theme.Content.title)
                .font(.body.weight(.medium))
        }
    }
    
    var themeBrandSection: some View {
        DisclosureGroup {
            SettingsThemeColorView(
                color: ChatAppearance.Brand.primary,
                title: L10n.Settings.Theme.Brand.Primary.placeholder,
                didUpdateColor: viewModel.colorDidChange
            )
            
            SettingsThemeColorView(
                color: ChatAppearance.Brand.onPrimary,
                title: L10n.Settings.Theme.Brand.OnPrimary.placeholder,
                didUpdateColor: viewModel.colorDidChange
            )
            
            SettingsThemeColorView(
                color: ChatAppearance.Brand.primaryContainer,
                title: L10n.Settings.Theme.Brand.PrimaryContainer.placeholder,
                didUpdateColor: viewModel.colorDidChange
            )
            
            SettingsThemeColorView(
                color: ChatAppearance.Brand.onPrimaryContainer,
                title: L10n.Settings.Theme.Brand.OnPrimaryContainer.placeholder,
                didUpdateColor: viewModel.colorDidChange
            )
            
            SettingsThemeColorView(
                color: ChatAppearance.Brand.secondary,
                title: L10n.Settings.Theme.Brand.Secondary.placeholder,
                didUpdateColor: viewModel.colorDidChange
            )
            
            SettingsThemeColorView(
                color: ChatAppearance.Brand.onSecondary,
                title: L10n.Settings.Theme.Brand.OnSecondary.placeholder,
                didUpdateColor: viewModel.colorDidChange
            )
            
            SettingsThemeColorView(
                color: ChatAppearance.Brand.secondaryContainer,
                title: L10n.Settings.Theme.Brand.SecondaryContainer.placeholder,
                didUpdateColor: viewModel.colorDidChange
            )
            
            SettingsThemeColorView(
                color: ChatAppearance.Brand.onSecondaryContainer,
                title: L10n.Settings.Theme.Brand.OnSecondaryContainer.placeholder,
                didUpdateColor: viewModel.colorDidChange
            )
        } label: {
            Text(L10n.Settings.Theme.Brand.title)
                .font(.body.weight(.medium))
        }
    }
    
    var themeBorderSection: some View {
        DisclosureGroup {
            SettingsThemeColorView(
                color: ChatAppearance.Border.default,
                title: L10n.Settings.Theme.Border.Default.placeholder,
                didUpdateColor: viewModel.colorDidChange
            )
            
            SettingsThemeColorView(
                color: ChatAppearance.Border.subtle,
                title: L10n.Settings.Theme.Border.Subtle.placeholder,
                didUpdateColor: viewModel.colorDidChange
            )
        } label: {
            Text(L10n.Settings.Theme.Border.title)
                .font(.body.weight(.medium))
        }
    }
    
    var themeStatusSection: some View {
        DisclosureGroup {
            SettingsThemeColorView(
                color: ChatAppearance.Status.success,
                title: L10n.Settings.Theme.Status.Success.placeholder,
                didUpdateColor: viewModel.colorDidChange
            )
            
            SettingsThemeColorView(
                color: ChatAppearance.Status.onSuccess,
                title: L10n.Settings.Theme.Status.OnSuccess.placeholder,
                didUpdateColor: viewModel.colorDidChange
            )
            
            SettingsThemeColorView(
                color: ChatAppearance.Status.successContainer,
                title: L10n.Settings.Theme.Status.SuccessContainer.placeholder,
                didUpdateColor: viewModel.colorDidChange
            )
            
            SettingsThemeColorView(
                color: ChatAppearance.Status.onSuccessContainer,
                title: L10n.Settings.Theme.Status.OnSuccessContainer.placeholder,
                didUpdateColor: viewModel.colorDidChange
            )
            
            SettingsThemeColorView(
                color: ChatAppearance.Status.warning,
                title: L10n.Settings.Theme.Status.Warning.placeholder,
                didUpdateColor: viewModel.colorDidChange
            )
            
            SettingsThemeColorView(
                color: ChatAppearance.Status.onWarning,
                title: L10n.Settings.Theme.Status.OnWarning.placeholder,
                didUpdateColor: viewModel.colorDidChange
            )
            
            SettingsThemeColorView(
                color: ChatAppearance.Status.warningContainer,
                title: L10n.Settings.Theme.Status.WarningContainer.placeholder,
                didUpdateColor: viewModel.colorDidChange
            )
            
            SettingsThemeColorView(
                color: ChatAppearance.Status.onWarningContainer,
                title: L10n.Settings.Theme.Status.OnWarningContainer.placeholder,
                didUpdateColor: viewModel.colorDidChange
            )
            
            SettingsThemeColorView(
                color: ChatAppearance.Status.error,
                title: L10n.Settings.Theme.Status.Error.placeholder,
                didUpdateColor: viewModel.colorDidChange
            )
            
            SettingsThemeColorView(
                color: ChatAppearance.Status.onError,
                title: L10n.Settings.Theme.Status.OnError.placeholder,
                didUpdateColor: viewModel.colorDidChange
            )
            
            SettingsThemeColorView(
                color: ChatAppearance.Status.errorContainer,
                title: L10n.Settings.Theme.Status.ErrorContainer.placeholder,
                didUpdateColor: viewModel.colorDidChange
            )
            
            SettingsThemeColorView(
                color: ChatAppearance.Status.onErrorContainer,
                title: L10n.Settings.Theme.Status.OnErrorContainer.placeholder,
                didUpdateColor: viewModel.colorDidChange
            )
        } label: {
            Text(L10n.Settings.Theme.Status.title)
                .font(.body.weight(.medium))
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        SettingsView(viewModel: SettingsViewModel { })
    }
}
