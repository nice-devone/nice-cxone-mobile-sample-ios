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

import CXoneChatSDK
import SwiftUI

struct LoginView: View, Alertable {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: LoginViewModel
    
    // MARK: - Builder
    
    var body: some View {
        LoadingView(isVisible: $viewModel.isLoading) {
            VStack(alignment: .center, spacing: 16) {
                VStack(spacing: 4) {
                    Text(L10n.Login.Oauth.availableProvidersTitle)
                        .fontWeight(.bold)
                        .font(.headline)
                        .foregroundColor(Color(.systemGray))
                    
                    if !viewModel.isOAuthEnabled {
                        Text(L10n.Login.Oauth.Disabled.description)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                }
                
                Button(action: viewModel.invokeLoginWithAmazon) {
                    Asset.OAuth.loginWithAmazon.swiftUIImage
                        .opacity(viewModel.isOAuthEnabled ? 1 : 0.3)
                }
                .disabled(!viewModel.isOAuthEnabled)
                
                guestLoginDivider
                
                VStack {
                    ValidatedTextField("John", text: $viewModel.firstName, validator: required, label: L10n.Login.Guest.UserDetails.firstName)

                    ValidatedTextField("Doe", text: $viewModel.lastName, validator: required, label: L10n.Login.Guest.UserDetails.lastName)
                }
                .padding(.horizontal, 12)
                
                Button(action: viewModel.onGuestLoginTapped) {
                    Text(L10n.Login.Guest.buttonTitle)
                        .fontWeight(.bold)
                        .frame(maxWidth: 210)
                        .adjustForA11y()
                        .foregroundColor(.white)
                        .background(Color.primaryButtonColor)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(.horizontal, 20)
        }
        .onAppear(perform: viewModel.onAppear)
        .alert(item: $viewModel.alertType, content: alertContent)
        .navigationBarTitle(L10n.Login.title)
        .navigationBarBackButtonHidden()
        .if(!viewModel.isLoading) { view in
                view.toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: viewModel.signOut) {
                            Asset.Common.disconnect
                        }
                    }
                 
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: viewModel.navigateToSettings) {
                            Asset.Common.settings
                        }
                    }
                }
        }
    }
}

// MARK: - Subviews

private extension LoginView {
    
    var guestLoginDivider: some View {
        HStack {
            VStack {
                Divider()
                    .background(Color(.systemGray2))
            }
            
            Text(L10n.Login.Guest.dividerTitle)
                .font(.headline)
                .foregroundColor(Color(.systemGray2))
            
            VStack {
                Divider()
                    .background(Color(.systemGray2))
            }
        }
    }
}

// MARK: - Preview

struct LoginView_Previews: PreviewProvider {
    
    private static let coordinator = LoginCoordinator(navigationController: UINavigationController())
    private static var appModule = PreviewAppModule(coordinator: coordinator) {
        didSet {
            coordinator.assembler = appModule.assembler
        }
    }
    // swiftlint:disable force_unwrapping
    private static let viewModel = LoginViewModel(
        coordinator: coordinator,
        configuration: Configuration(
            brandId: 1386,
            channelId: "chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4",
            environment: .NA1
        ),
        deeplinkOption: nil,
        loginWithAmazon: appModule.resolver.resolve(LoginWithAmazonUseCase.self)!,
        getChannelConfiguration: appModule.resolver.resolve(GetChannelConfigurationUseCase.self)!
    )
    // swiftlint:enable force_unwrapping
    
    static var previews: some View {
        Group {
            NavigationView {
                LoginView(viewModel: viewModel)
            }
            .previewDisplayName("Light Mode")
            
            NavigationView {
                LoginView(viewModel: viewModel)
            }
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
    }
}
