//
//  Color+hex.swift
//  swift-paperless
//
//  Created by Paul Gessinger on 22.09.2024.
//

import SwiftUI

struct HexColor: Equatable {
    var color: Color

    init(_ color: Color) {
        self.color = color
    }
}

extension HexColor: Codable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let str = try container.decode(String.self)
        color = try Color(hex: str)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(color.hexString)
    }
}

extension Color {
    enum HexError: Error, Equatable {
        case invalid(String)
    }

    init(hex: String) throws (HexError) {
        var string = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if string.hasPrefix("#") {
            _ = string.removeFirst()
        }

        if string.count != 6 {
            throw .invalid(hex)
        }

        let scanner = Scanner(string: string)
        var color: UInt64 = 0
        scanner.scanHexInt64(&color)

        let mask = 0x0000FF
        let r = Double(Int(color >> 16) & mask) / 255.0
        let g = Double(Int(color >> 8) & mask) / 255.0
        let b = Double(Int(color) & mask) / 255.0

        self.init(.sRGB, red: r, green: g, blue: b)
    }

    var hexString: String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        #if canImport(AppKit)
            NSColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        #elseif canImport(UIKit)
            UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        #endif

        let convert = { v in
            let vv = max(0.0, min(1.0, v))
            return UInt(vv > 0.99999 ? 255 : vv * 255.0)
        }

        return "#" + String(format: "%02x", convert(red)) +
            String(format: "%02x", convert(green)) +
            String(format: "%02x", convert(blue))
    }

    var hex: HexColor {
        HexColor(self)
    }
}
