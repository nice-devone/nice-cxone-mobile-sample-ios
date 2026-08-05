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

struct StoreView: View {

    // MARK: - Properties

    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var chatPresenter: ChatPresenter

    @ObservedObject var viewModel: StoreViewModel

    @State private var searchText = ""
    @State private var isPresentingDisconnectAlert = false
    
    var searchResults: [ProductEntity] {
        if searchText.isEmpty {
            return viewModel.products
        } else {
            return viewModel.products.filter { product in
                product.title.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    // MARK: - Init
    
    init(viewModel: StoreViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Builder
    
    var body: some View {
        LoadingView(isVisible: $viewModel.isLoading) {
            ZStack(alignment: .bottomTrailing) {
                storeContent
                
                Button {
                    viewModel.openChat()
                } label: {
                    chatButtonLabel
                }
                .padding(.trailing, 12)
                .padding(.bottom, UIDevice.hasHomeButton ? 12 : 0)
                .accessibilityIdentifier(A11y.Store.ButtonOpenChat.identifier)
                .accessibilityLabel(A11y.Store.ButtonOpenChat.label)
                .accessibilityHint(A11y.Store.ButtonOpenChat.hint)
                .accessibilitySortPriority(2)
            }
        }
        .onAppear(perform: viewModel.onAppear)
        .onDisappear(perform: viewModel.onDisappear)
        .sheet(
            isPresented: Binding(
                get: { chatPresenter.isPresented && chatPresenter.presentationStyle != .fullScreen },
                set: { isPresented in
                    if !isPresented {
                        chatPresenter.dismiss()
                    }
                }
            ),
            content: {
                LazyView {
                    chatContent(presentModally: true)
                }
            }
        )
        .navigationDestination(isPresented: Binding(
            get: { chatPresenter.isPresented && chatPresenter.presentationStyle == .fullScreen },
            set: { isPresented in
                if !isPresented {
                    chatPresenter.dismiss()
                }
            }
        )) {
            LazyView {
                chatContent(presentModally: false)
            }
        }
        .alert(L10n.Error.Generic.title, isPresented: .constant(viewModel.error != nil)) {
            Button(L10n.Common.confirm)
        } message: {
            Text(L10n.Error.Generic.message)
        }
        .alert(L10n.Common.attention, isPresented: $isPresentingDisconnectAlert) {
            Button(L10n.Common.signOut, role: .destructive, action: viewModel.signOut)
        } message: {
            Text(L10n.Store.Signout.message)
        }
        .navigationTitle(L10n.Store.title)
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                Button {
                    isPresentingDisconnectAlert = true
                } label: {
                    Asset.Images.Common.disconnect
                }
                
                Button {
                    viewModel.showSettings()
                } label: {
                    Asset.Images.Common.settings
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: viewModel.navigateToCart) {
                    Asset.Images.Store.cart
                }
                .badge(viewModel.itemsInCart)
            }
        }
    }
}

// MARK: - Subviews

private extension StoreView {

    var chatThreadId: String? {
        if case .thread(let id) = chatPresenter.deeplinkOption {
            return id
        }

        return nil
    }

    @ViewBuilder
    func chatContent(presentModally: Bool) -> some View {
        chatPresenter.chatCoordinator.content(
            threadId: chatThreadId,
            presentModally: presentModally,
            onFinish: chatPresenter.dismiss
        )
    }

    var chatButtonLabel: some View {
        Asset.Images.Store.chat
            .padding(16)
            .foregroundStyle(.white)
            .background(
                Circle()
                    .fill(Color.accentColor)
            )
    }
    
    var storeContent: some View {
        VStack {
            SearchBar(text: $searchText)
            
            GridStack(minCellWidth: 150, spacing: 10, numItems: searchResults.count) { index in
                let product = searchResults[index]
                
                StoreCard(
                    thumbnailUrl: product.thumbnailUrl,
                    title: product.title,
                    price: product.price
                )
                .onTapGesture {
                    viewModel.navigateToProduct(product)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let chatProvider = MockChatProvider()
    let chatPresenter = ChatPresenter(chatProvider: chatProvider)
    let router = AppRouter(chatPresenter: chatPresenter)

    NavigationStack {
        StoreView(
            viewModel: StoreViewModel(
                router: router,
                chatPresenter: chatPresenter,
                chatProvider: chatProvider,
                deeplinkOption: nil,
                getProducts: GetProductsUseCase(repository: MockProductsRepositoryImpl()),
                getCart: GetCartUseCase(repository: MockCartRepositoryImpl())
            )
        )
    }
    .environmentObject(router)
    .environmentObject(chatPresenter)
}
