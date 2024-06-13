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

class CartViewModel: AnalyticsReporter, ObservableObject {
    
    // MARK: - UseCases
    
    private let getCart: GetCartUseCase
    private let addProductToCart: AddProductToCartUseCase
    private let removeProductFromCart: RemoveProductFromCartUseCase
    
    // MARK: - Properties
    
    private let coordinator: StoreCoordinator
    
    @Published var cart = [ProductOrderEntity]()
    
    var totalAmount: Double {
        cart.reduce(0) { $0 + ($1.product.price * Double($1.quantity)) }
    }
    
    // MARK: - Init
    
    init(
        coordinator: StoreCoordinator,
        getCart: GetCartUseCase,
        addProductToCart: AddProductToCartUseCase,
        removeProductFromCart: RemoveProductFromCartUseCase
    ) {
        self.coordinator = coordinator
        self.getCart = getCart
        self.addProductToCart = addProductToCart
        self.removeProductFromCart = removeProductFromCart
        super.init(analyticsTitle: "cart", analyticsUrl: "/cart")
    }
    
    // MARK: - Methods
    
    override func onAppear() {
        super.onAppear()
        
        cart = getCart()
    }
    
    func navigateToPayment() {
        Log.trace("Navigatint to the payment")
        
        coordinator.showPayment()
    }
    
    func addProduct(_ product: ProductEntity) {
        Log.trace("Adding one piece of product \(product.title) to cart")
        
        addProductToCart(product)
        
        cart = getCart()
    }
    
    func removeProduct(_ product: ProductEntity) {
        Log.trace("Removing one piece of product \(product.title) to cart")
        
        removeProductFromCart(product)
        
        cart = getCart()
    }
}
