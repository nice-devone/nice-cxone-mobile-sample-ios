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

import Foundation

class CartRepositoryImpl: CartRepository {
    
    // MARK: - Properties
    
    var cart = [ProductOrderEntity]()
    
    // MARK: - Methods
    
    func addProduct(_ product: ProductEntity) {
        if let index = cart.firstIndex(where: { $0.product == product }) {
            cart[index] = cart[index].incremented
        } else {
            cart.append(ProductOrderEntity(product: product, quantity: 1))
        }
    }
    
    func removeProduct(_ product: ProductEntity) {
        guard let index = cart.firstIndex(where: { $0.product == product }) else {
            return
        }

        if cart[index].quantity == 1 {
            cart.remove(at: index)
        } else {
            cart[index] = cart[index].decremented
        }
        
    }
    
    func checkout() {
        cart.removeAll()
    }
}

// MARK: - Preview Mock

// swiftlint:disable force_unwrapping
class MockCartRepositoryImpl: CartRepository {
    
    // MARK: - Properties
    
    var cart: [ProductOrderEntity] = [
        ProductOrderEntity(
            product: ProductEntity(
                id: 1,
                title: "iPhone 9",
                description: "An apple mobile which is nothing like apple",
                price: 549,
                rating: 4.56,
                brand: "Apple",
                thumbnailUrl: URL(string: "https://i.dummyjson.com/data/products/1/thumbnail.jpg")!,
                imagesUrls: [
                    URL(string: "https://i.dummyjson.com/data/products/1/1.jpg")!
                ]
            ),
            quantity: 2
        ),
        ProductOrderEntity(
            product: ProductEntity(
                id: 2,
                title: "iPhone X",
                description: "SIM-Free, Model A19211 6.5-inch Super Retina HD display with OLED technology A12 Bionic chip with ...",
                price: 899,
                rating: 4.44,
                brand: "Apple",
                thumbnailUrl: URL(string: "https://i.dummyjson.com/data/products/2/thumbnail.jpg")!,
                imagesUrls: [
                    URL(string: "https://i.dummyjson.com/data/products/2/1.jpg")!
                ]
            ),
            quantity: 1
        )
    ]
// swiftlint:enable force_unwrapping
    
    // MARK: - Methods
    
    func addProduct(_ product: ProductEntity) {
        if let index = cart.firstIndex(where: { $0.product == product }) {
            cart[index] = cart[index].incremented
        } else {
            cart.append(ProductOrderEntity(product: product, quantity: 1))
        }
    }
    
    func removeProduct(_ product: ProductEntity) {
        guard let index = cart.firstIndex(where: { $0.product == product }) else {
            return
        }

        if cart[index].quantity > 1 {
            cart[index] = cart[index].decremented
        } else {
            cart.remove(at: index)
        }
    }
    
    func checkout() {
        cart.removeAll()
    }
}
