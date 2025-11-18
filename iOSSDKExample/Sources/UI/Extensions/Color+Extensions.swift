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

extension Color {
    
    // MARK: - Properties
    
    static var backgroundColor: Color = Color(.systemBackground)
    static var primaryButtonColor: Color = .accentColor
    
    // MARK: - Init
    
    init?(hex: String) {
        let regex = try? NSRegularExpression(pattern: "^#?[0-9A-Fa-f]*$")
        
        guard let regex, !regex.matches(in: hex, range: NSRange(hex.startIndex..., in: hex)).isEmpty else {
            return nil
        }
        
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        
        guard [3, 4, 6, 8].contains(hex.count) else {
            return nil
        }
        
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let alpha, red, green, blue: UInt64
        switch hex.count {
        case 3:
            (alpha, red, green, blue) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 4:
            (alpha, red, green, blue) = (255, (int >> 12) * 17, (int >> 8 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (alpha, red, green, blue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (alpha, red, green, blue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (alpha, red, green, blue) = (1, 1, 1, 1)
        }

        self.init(.sRGB, red: Double(red) / 255, green: Double(green) / 255, blue: Double(blue) / 255, opacity: Double(alpha) / 255)
    }
    
    // MARK: - Static methods
    
    static func themedColor(light: Color, dark: Color) -> Color {
        UIApplication.isDarkModeActive ? dark : light
    }
    
    // MARK: - Methods
    
    var toHexString: String {
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
            return "#000000"
        }

        let uiColor = UIColor(self)
        let cgColorInRGB = uiColor.cgColor.converted(to: colorSpace, intent: .defaultIntent, options: nil) ?? UIColor.white.cgColor
        let colorRef = cgColorInRGB.components
        let red = colorRef?[0] ?? 0
        let green = colorRef?[1] ?? 0
        let blue = ((colorRef?.count ?? 0) > 2 ? colorRef?[2] : green) ?? 0
        let alpha = uiColor.cgColor.alpha

        var color = String(format: "#%02lX%02lX%02lX", red.intColorComponent(), green.intColorComponent(), blue.intColorComponent())

        if alpha < 1 {
            color += String(format: "%02lX", alpha.intColorComponent())
        }

        return color
    }
}

// MARK: - Codable

extension Color: @retroactive Codable {
    
    enum CodingKeys: String, CodingKey {
        case red, green, blue, alpha
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let red = try container.decode(Double.self, forKey: .red)
        let green = try container.decode(Double.self, forKey: .green)
        let blue = try container.decode(Double.self, forKey: .blue)
        let alpha = try container.decode(Double.self, forKey: .alpha)
        
        self.init(red: red, green: green, blue: blue, opacity: alpha)
    }

    public func encode(to encoder: Encoder) throws {
        guard let colorComponents = self.colorComponents else {
            throw EncodingError.invalidValue(UIColor.self, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "No color components"))
        }
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(colorComponents.red, forKey: .red)
        try container.encode(colorComponents.green, forKey: .green)
        try container.encode(colorComponents.blue, forKey: .blue)
        try container.encode(colorComponents.alpha, forKey: .alpha)
    }
}

// MARK: - Helpers

private extension Color {
    
    // swiftlint:disable:next large_tuple
    var colorComponents: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        guard UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }
        
        return (red, green, blue, alpha)
    }
}
