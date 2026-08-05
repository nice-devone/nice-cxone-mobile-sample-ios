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

import CXoneChatSDK
import SwiftUI

struct LoginView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: LoginViewModel
    
    // MARK: - Builder
    
    var body: some View {
        LoadingView(isVisible: $viewModel.isLoading) {
            content
        }
        .onAppear(perform: viewModel.onAppear)
        .alertable(isPresented: viewModel.showAlert, presenting: viewModel.alertType)
        .sheet(isPresented: $viewModel.isFlowSelectionPresented) {
            OAuthFlowSelectionView(onConfirm: viewModel.signInWithGoogle)
        }
        .navigationTitle(L10n.Login.title)
        .navigationBarBackButtonHidden()
        .if(!viewModel.isLoading) { view in
            view.toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: viewModel.signOut) {
                        Asset.Images.Common.disconnect
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: viewModel.navigateToSettings) {
                        Asset.Images.Common.settings
                    }
                }
            }
        }
    }
}

// MARK: - Subviews

private extension LoginView {
    
    var content: some View {
        VStack(alignment: .center, spacing: 16) {
            if viewModel.isOAuthEnabled {
                Text(L10n.Login.Oauth.availableProvidersTitle)
                    .fontWeight(.bold)
                    .font(.headline)
                    .foregroundStyle(Color(.systemGray))
                
                Button(action: viewModel.onGoogleLoginTapped) {
                    HStack {
                        Asset.Images.logoGoogleG
                            .swiftUIImage
                            .accessibilityHidden(true)

                        Text(L10n.Login.Oauth.buttonTitle)
                    }
                }
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .adjustForA11y()
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black)
                )
            } else {
                ValidatedTextField(
                    L10n.Login.Guest.UserDetails.firstNamePlaceholder,
                    text: $viewModel.firstName,
                    label: L10n.Login.Guest.UserDetails.firstName
                )

                ValidatedTextField(
                    L10n.Login.Guest.UserDetails.lastNamePlaceholder,
                    text: $viewModel.lastName,
                    label: L10n.Login.Guest.UserDetails.lastName
                )
                
                Button(L10n.Login.Guest.buttonTitle, action: viewModel.onGuestLoginTapped)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .adjustForA11y()
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.primaryButtonColor)
                    )
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Preview

#Preview {
    let chatProvider = MockChatProvider()

    NavigationStack {
        LoginView(viewModel: LoginViewModel(
            router: AppRouter(chatPresenter: ChatPresenter(chatProvider: chatProvider)),
            chatProvider: chatProvider,
            configuration: Configuration(
                brandId: 1386,
                channelId: "chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4",
                environment: .NA1
            ),
            getChannelConfiguration: GetChannelConfigurationUseCase(chatProvider: chatProvider),
            googleSignIn: PreviewGoogleSignInUseCase(chatProvider: chatProvider)
        ))
    }
}
