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

extension View {
    
    func adjustForA11y() -> some View {
        modifier(AdjustForA11yModifier())
    }
    
    /// Rounded gray card pinned to the bottom of the screen, padded above the home indicator.
    @MainActor
    func bottomCardStyle() -> some View {
        padding([.top, .leading, .trailing], 16)
            .padding(.bottom, UIDevice.hasHomeButton ? 16 : 32)
            .background(Color(.systemGray6))
            .cornerRadius(20, corners: [.topLeft, .topRight])
    }
    
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func onWillDisappear(_ perform: @escaping () -> Void) -> some View {
        background(WillDisappearHandler(onWillDisappear: perform))
    }
    
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, content: (Self) -> Content) -> some View {
        if condition {
            content(self)
        } else {
            self
        }
    }

    /// Applies a transform to the view when an optional value is non-`nil`, passing the unwrapped value to the closure.
    @ViewBuilder
    func ifLet<Content: View, T>(_ conditional: T?, @ViewBuilder _ content: (Self, _ value: T) -> Content) -> some View {
        if let conditional {
            content(self, conditional)
        } else {
            self
        }
    }

    /// Wraps `onChange(of:perform:)` to use the iOS 17 two-parameter form when available and
    /// fall back to the iOS 14 single-parameter form on iOS 16. The iOS 14 form is deprecated
    /// in iOS 17, so call sites should prefer this helper as long as iOS 16 is supported.
    @ViewBuilder
    func onValueChange<V: Equatable>(of value: V, perform action: @escaping (V) -> Void) -> some View {
        if #available(iOS 17, *) {
            self.onChange(of: value) { _, newValue in
                action(newValue)
            }
        } else {
            self.onChange(of: value, perform: action)
        }
    }
}
