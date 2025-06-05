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

struct StoreView: View {
    
    // MARK: - Properies
    
    @ObservedObject private var viewModel: StoreViewModel
    
    @State private var searchText = ""
    @State private var isPresentingDisconnectAlert = false
    
    var searchResults: [ProductEntity] {
        if searchText.isEmpty {
            return viewModel.products
        } else {
            return viewModel.products.filter { $0.title.lowercased().contains(searchText.lowercased()) }
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
                
                Button(action: viewModel.openChat) {
                    chatButtonLabel
                }
                .padding(.trailing, 12)
                .padding(.bottom, UIDevice.hasHomeButton ? 12 : 0)
            }
        }
        .onAppear(perform: viewModel.onAppear)
        .onDisappear(perform: viewModel.onDisappear)
        .alert(isPresented: .constant(viewModel.error != nil))
        .alert(isPresented: $isPresentingDisconnectAlert) {
            Alert(
                title: Text(L10n.Common.attention),
                message: Text(L10n.Store.Signout.message),
                primaryButton: .destructive(Text(L10n.Common.signOut)) {
                    viewModel.signOut()
                },
                secondaryButton: .cancel()
            )
        }
        .navigationBarTitle(L10n.Store.title)
        .navigationBarItems(
            leading: HStack {
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
            },
            trailing: cartNavigationItem
        )
        .navigationBarHidden(false)
    }
}

// MARK: - Subviews

private extension StoreView {

    var chatButtonLabel: some View {
        Asset.Images.Store.chat
            .padding(16)
            .foregroundColor(.white)
            .background(
                Circle()
                    .fill(Color.accentColor)
            )
    }
    
    var cartNavigationItem: some View {
        Button(action: {
            viewModel.navigateToCart()
        }, label: {
            ZStack {
                Asset.Images.Store.cart
                
                if viewModel.itemsInCart > 0 {
                    Text(viewModel.itemsInCart.description)
                        .font(.footnote)
                        .foregroundColor(.white)
                        .padding(6)
                        .background(
                            Circle()
                                .fill(Color.accentColor)
                        )
                        .overlay(
                            Circle()
                                .stroke(Color(.systemBackground), lineWidth: 2)
                        )
                        .offset(x: 12, y: 12)
                }
            }
        })
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
    NavigationView {
        StoreView(
            viewModel: StoreViewModel(
                coordinator: StoreCoordinator(navigationController: UINavigationController()),
                deeplinkOption: nil,
                getProducts: GetProductsUseCase(repository: MockProductsRepositoryImpl()),
                getCart: GetCartUseCase(repository: MockCartRepositoryImpl())
            )
        )
    }
}
