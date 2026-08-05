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

import SwiftUI

/// Bottom sheet that lets the user choose which OAuth flow to use before Google sign-in (DE-170289).
///
/// The selected `OAuthFlow` is handed back via `onConfirm`; the caller runs the Google sign-in.
struct OAuthFlowSelectionView: View {

    // MARK: - Properties

    private static let detentFraction: CGFloat = 0.33
    private static let contentSpacing: CGFloat = 20
    private static let contentHorizontalPadding: CGFloat = 16
    private static let contentTopPadding: CGFloat = 10
    private static let contentBottomPadding: CGFloat = 100
    private static let buttonCornerRadius: CGFloat = 20

    @Environment(\.dismiss) private var dismiss

    @State private var selectedFlow: OAuthFlow = .implicit

    let onConfirm: (OAuthFlow) -> Void

    // MARK: - Builder

    var body: some View {
        VStack(alignment: .center, spacing: Self.contentSpacing) {
            Text(L10n.Login.Oauth.FlowSelection.title)
                .font(.headline)
            
            Text(L10n.Login.Oauth.FlowSelection.message)
                .font(.subheadline)
                .foregroundStyle(Color(.systemGray))
                .multilineTextAlignment(.center)
            
            Picker(L10n.Login.Oauth.FlowSelection.title, selection: $selectedFlow) {
                ForEach(OAuthFlow.allCases) { flow in
                    Text(title(for: flow))
                        .tag(flow)
                }
            }
            .pickerStyle(.segmented)

            Spacer()

            Button(L10n.Login.Oauth.FlowSelection.confirm) {
                onConfirm(selectedFlow)

                dismiss()
            }
            .fontWeight(.bold)
            .adjustForA11y()
            .frame(maxWidth: .infinity)
            .foregroundStyle(.white)
            .background(
                RoundedRectangle(cornerRadius: Self.buttonCornerRadius)
                    .fill(Color.primaryButtonColor)
            )
        }
        .padding(.horizontal, Self.contentHorizontalPadding)
        .padding(.top, Self.contentTopPadding)
        .padding(.bottom, UIDevice.hasHomeButton ? Self.contentBottomPadding : .zero)
        .presentationDetents([.fraction(Self.detentFraction)])
    }
}

// MARK: - Subviews

private extension OAuthFlowSelectionView {

    func title(for flow: OAuthFlow) -> String {
        switch flow {
        case .implicit:
            return L10n.Login.Oauth.Flow.Implicit.title
        case .explicit:
            return L10n.Login.Oauth.Flow.Explicit.title
        }
    }
}

// MARK: - Preview

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            OAuthFlowSelectionView { _ in }
        }
}
