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

struct CartView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: CartViewModel
    
    // MARK: - Builder
    
    var body: some View {
        VStack {
            if viewModel.cart.isEmpty {
                Text(L10n.Cart.Empty.title)
            } else {
                ScrollView(showsIndicators: false) {
                    ForEach(viewModel.cart, id: \.product.id) { item in
                        CartItem(item.product, quantity: .constant(item.quantity)) { increase in
                            if increase {
                                viewModel.addProduct(item.product)
                            } else {
                                viewModel.removeProduct(item.product)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    
                    Spacer(minLength: 32)
                }
                
                CartSummaryView(totalAmount: .constant(viewModel.totalAmount)) {
                    viewModel.navigateToPayment()
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear(perform: viewModel.onAppear)
        .navigationTitle(L10n.Cart.title)
    }
}

// MARK: - Preview

#Preview {
    let chatProvider = MockChatProvider()

    NavigationStack {
        CartView(viewModel: CartViewModel(
            router: AppRouter(chatPresenter: ChatPresenter(chatProvider: chatProvider)),
            getCart: GetCartUseCase(repository: MockCartRepositoryImpl()),
            addProductToCart: AddProductToCartUseCase(repository: MockCartRepositoryImpl()),
            removeProductFromCart: RemoveProductFromCartUseCase(repository: MockCartRepositoryImpl()),
            chatProvider: chatProvider
        ))
    }
}
