//
//  UIColor+Extension.swift
//  DanceSocialRp
//
//  Created by  mac on 2026/5/27.
//

import UIKit

extension UIColor {

    /// 十六进制颜色，支持 `#FFFFFF`、`#FFF`、`#FFFFFFFF`（RRGGBBAA）
    /// - Parameters:
    ///   - hex: 色值字符串，可带 `#`
    ///   - alpha: 透明度（6/3 位色值时生效；8 位未传 alpha 时使用色值末尾两位）
    convenience init(hex: String, alpha: CGFloat? = nil) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexString = hexString.replacingOccurrences(of: "#", with: "")

        guard !hexString.isEmpty else {
            self.init(white: 0, alpha: 1)
            return
        }

        var value: UInt64 = 0
        guard Scanner(string: hexString).scanHexInt64(&value) else {
            self.init(white: 0, alpha: 1)
            return
        }

        let red: CGFloat
        let green: CGFloat
        let blue: CGFloat
        let opacity: CGFloat

        switch hexString.count {
        case 3:
            red = Self.component(from: value, shift: 8, length: 1)
            green = Self.component(from: value, shift: 4, length: 1)
            blue = Self.component(from: value, shift: 0, length: 1)
            opacity = alpha ?? 1
        case 6:
            red = Self.component(from: value, shift: 16, length: 2)
            green = Self.component(from: value, shift: 8, length: 2)
            blue = Self.component(from: value, shift: 0, length: 2)
            opacity = alpha ?? 1
        case 8:
            red = Self.component(from: value, shift: 24, length: 2)
            green = Self.component(from: value, shift: 16, length: 2)
            blue = Self.component(from: value, shift: 8, length: 2)
            opacity = alpha ?? CGFloat(value & 0xFF) / 255
        default:
            self.init(white: 0, alpha: 1)
            return
        }

        self.init(red: red, green: green, blue: blue, alpha: opacity)
    }

    /// `UIColor.hex("#FFFFFF")`
    static func hex(_ hex: String, alpha: CGFloat? = nil) -> UIColor {
        UIColor(hex: hex, alpha: alpha)
    }

    private static func component(from value: UInt64, shift: UInt64, length: Int) -> CGFloat {
        let mask = UInt64((1 << (length * 4)) - 1)
        let component = (value >> shift) & mask
        let normalized = length == 1 ? (component * 17) : component
        return CGFloat(normalized) / 255
    }
}
