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

extension ButtonStyle where Self == PrimaryButtonStyle {

    static var primary: PrimaryButtonStyle {
        PrimaryButtonStyle()
    }
}

// MARK: - ButtonStyle+Primary

struct PrimaryButtonStyle: ButtonStyle {
    
    // MARK: - Properties
    
    private static let horizontalPadding: CGFloat = 16
    private static let pressedOpacity: Double = 0.8
    private static let backgroundCornerRadius: CGFloat = 8
    
    // MARK: - Methods
    
    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        configuration.label
            .adjustForA11y()
            .padding(.horizontal, Self.horizontalPadding)
            .foregroundColor(.white)
            .background(configuration.isPressed ? Color.primaryButtonColor.opacity(Self.pressedOpacity) : Color.primaryButtonColor)
            .clipShape(RoundedRectangle(cornerRadius: Self.backgroundCornerRadius))
    }
}

// MARK: - Preview

#Preview {
    Button("Button") { }
        .padding()
        .buttonStyle(.primary)
}
