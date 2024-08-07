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
                    Asset.Store.chat
                }
                .padding(12)
                .foregroundColor(.white)
                .background(
                    Circle()
                        .fill(Color.accentColor)
                )
                .offset(x: -12, y: -12)
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
                    Asset.Common.disconnect
                }
                
                Button {
                    viewModel.showSettings()
                } label: {
                    Asset.Common.settings
                }

            },
            trailing: cartNavigationItem
        )
        .navigationBarHidden(false)
    }
}

// MARK: - Subviews

private extension StoreView {

    var cartNavigationItem: some View {
        Button(action: {
            viewModel.navigateToCart()
        }, label: {
            ZStack {
                Asset.Store.cart
                
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

struct StoreView_Previews: PreviewProvider {
    
    private static let coordinator = LoginCoordinator(navigationController: UINavigationController())
    private static var appModule = PreviewAppModule(coordinator: coordinator) {
        didSet {
            coordinator.assembler = appModule.assembler
        }
    }
    
    static var previews: some View {
        Group {
            // swiftlint:disable force_unwrapping
            NavigationView {
                appModule.resolver.resolve(StoreView.self)!
            }
            .previewDisplayName("Light Mode")
            
            NavigationView {
                appModule.resolver.resolve(StoreView.self)!
            }
            // swiftlint:enable force_unwrapping
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
    }
}
