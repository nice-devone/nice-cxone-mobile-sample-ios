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

import CXoneChatSDK
import SwiftUI
import Swinject

struct ConfigurationView: View, Alertable {

    // MARK: - Properties

    @State private var isShowingEnvironmentsSheet = false
    @State private var isShowingConfigurationsSheet = false

    @ObservedObject var viewModel: ConfigurationViewModel

    // MARK: - Builder

    var body: some View {
        VStack {
            Spacer()

            if viewModel.isDefaultConfigurationHidden {
                customConfigurationSection
                    .transition(.opacity)
            } else {
                defaultConfigurationSection
                    .transition(.opacity)
            }

            Button(viewModel.isDefaultConfigurationHidden ? L10n.Configuration.Default.buttonTitle : L10n.Configuration.Custom.buttonTitle) {
                withAnimation {
                    viewModel.isDefaultConfigurationHidden.toggle()
                }
            }
            .padding(.vertical, 24)
            
            Button(action: viewModel.onConfirmButtonTapped) {
                Text(L10n.Common.continue)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.primary)
            .padding(.bottom, 10)
        }
        .background(Color.backgroundColor)
        .padding(.horizontal, 24)
        .onAppear(perform: viewModel.onAppear)
        .alert(item: $viewModel.alertType, content: alertContent)
        .navigationBarTitle(L10n.Configuration.title)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: viewModel.navigateToSettings) {
                    Asset.Images.Common.settings
                }
            }
        }
    }
}

// MARK: - Subviews

private extension ConfigurationView {

    var defaultConfigurationSection: some View {
        VStack {
            HStack {
                Text(L10n.Configuration.environmentSelectionTitle)

                Spacer()

                Button(viewModel.environment.rawValue) {
                    isShowingEnvironmentsSheet = true
                }
                .confirmationDialog(L10n.Configuration.environmentSelectionTitle, isPresented: $isShowingEnvironmentsSheet) {
                    ForEach(CXoneChatSDK.Environment.allCases, id: \.hashValue) { option in
                        Button(option.rawValue) {
                            viewModel.environment = option
                        }
                        .accessibilityIdentifier("configuration.default.environment_options.option_\(option.rawValue)")
                    }
                    
                    Button(L10n.Common.cancel, role: .cancel) {
                        isShowingEnvironmentsSheet = false
                    }
                    .accessibilityIdentifier("configuration.default.environment_options.option_cancel")
                }
                .accessibilityIdentifier("configuration.default.environment_options")
            }

            ValidatedTextField(
                "1234",
                text: $viewModel.brandId,
                validator: allOf(required, numeric),
                label: L10n.Configuration.Default.brandIdPlaceholder
            )
            .keyboardType(.numberPad)
            .padding(.top, 10)

            ValidatedTextField(
                "chat_e11131fa...",
                text: $viewModel.channelId,
                validator: required,
                label: L10n.Configuration.Default.channelIdPlaceholder
            )
            .padding(.top, 10)

            customCustomerIDSection
        }
    }

    var customConfigurationSection: some View {
        VStack {
            HStack {
                Text(L10n.Configuration.configurationSelectionTitle)
                
                Spacer()
                
                Button(viewModel.customConfiguration.title) {
                    isShowingConfigurationsSheet = true
                }
                .confirmationDialog(L10n.Configuration.configurationSelectionTitle, isPresented: $isShowingConfigurationsSheet) {
                    ForEach(viewModel.configurations, id: \.hashValue) { option in
                        Button {
                            viewModel.customConfiguration = option
                        } label: {
                            Text(option.title)
                        }
                        .accessibilityIdentifier("configuration.custom.environment_options.option_\(option.title)")
                    }
                    
                    Button(L10n.Common.cancel, role: .cancel) {
                        isShowingConfigurationsSheet = false
                    }
                    .accessibilityIdentifier("configuration.custom.environment_options.option_cancel")
                }
                .accessibilityIdentifier("configuration.custom.environment_options")
            }
            
            customCustomerIDSection
        }
    }
    
    var customCustomerIDSection: some View {
        ValidatedTextField(
            viewModel.customerIdExample,
            text: $viewModel.customerId,
            label: L10n.Configuration.UserDetails.customerIdPlaceholder,
            hint: L10n.Configuration.UserDetails.customerIdDescription
        )
        .font(.footnote)
    }
}

// MARK: - Preview

// swiftlint:disable force_unwrapping
struct ConfigurationView_Previews: PreviewProvider {

    private static let coordinator = LoginCoordinator(navigationController: UINavigationController())
    private static var appModule = PreviewAppModule(coordinator: coordinator) {
        didSet {
            coordinator.assembler = appModule.assembler
        }
    }

    static var previews: some View {
        Group {
            NavigationView {
                appModule.resolver.resolve(ConfigurationView.self)!
            }
            .previewDisplayName("Light Mode")

            NavigationView {
                appModule.resolver.resolve(ConfigurationView.self)!
            }
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
    }
}
// swiftlint:enable force_unwrapping
