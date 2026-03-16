//
//  ColorHelper.swift
//  Altar
//
//  Hex <-> Color conversion.
//

import SwiftUI
import AppKit

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }

    var hexString: String {
        guard let c = NSColor(self).usingColorSpace(.sRGB) else { return "007AFF" }
        let r = Int(c.redComponent * 255)
        let g = Int(c.greenComponent * 255)
        let b = Int(c.blueComponent * 255)
        return String(format: "%02X%02X%02X", r, g, b)
    }
}
