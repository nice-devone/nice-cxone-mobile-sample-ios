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

struct PaymentDoneView: View {
    
    // MARK: - Properties
    
    let viewModel: PaymentDoneViewModel
    
    // MARK: - Builder
    
    var body: some View {
        VStack {
            Asset.Images.Common.success
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundStyle(.green)
                .padding(.bottom, 24)
            
            Text(L10n.PurchaseDone.message)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.bottom, 40)
            
            Button(action: viewModel.popToStore) {
                Text(L10n.PurchaseDone.backToStore)
                    .fontWeight(.bold)
            }
            .buttonStyle(.primary)
        }
        .padding(.horizontal, 24)
        .onAppear(perform: viewModel.onAppear)
        .navigationBarBackButtonHidden()
    }
}

// MARK: - Preview

#Preview {
    let chatProvider = MockChatProvider()

    PaymentDoneView(viewModel: PaymentDoneViewModel(router: AppRouter(chatPresenter: ChatPresenter(chatProvider: chatProvider)), chatProvider: chatProvider))
}
