//
//  Color+AppColor.swift
//  SharableComponents
//

import SwiftUI

extension Color {

    /// Creates a `Color` from a 6-digit hex string (e.g., "#FFAA00" or "FFAA00").
    init(colorHex hex: String) {
        let cleaned = hex
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")

        guard cleaned.count == 6,
              let value = Int(cleaned, radix: 16) else {
            self = .gray
            return
        }

        let r = Double((value >> 16) & 0xFF) / 255.0
        let g = Double((value >> 8)  & 0xFF) / 255.0
        let b = Double(value         & 0xFF) / 255.0

        self = Color(red: r, green: g, blue: b)
    }

    /// Returns a copy of this colour mixed toward white by `amount` (0 = unchanged, 1 = white).
    func blendedTowardWhite(_ amount: CGFloat) -> Color {
        let ui = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        return Color(
            red:   r + (1 - r) * amount,
            green: g + (1 - g) * amount,
            blue:  b + (1 - b) * amount
        )
    }

    /// Perceived brightness using the standard luminance formula (0 = black, 1 = white).
    var perceivedBrightness: CGFloat {
        let ui = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        return 0.299 * r + 0.587 * g + 0.114 * b
    }

    /// Returns a matched (surface, foreground) pair for use in preview cards.
    ///
    /// Contrast is split between the two colours so neither needs to travel as far
    /// from the original hue. Both values are derived in HSB space, keeping hue intact.
    ///
    /// - Light pair: surface is a faint hue tint; foreground drops brightness moderately.
    /// - Dark pair: surface picks up a subtle hue hint; foreground lifts brightness moderately.
    func previewPair(onDark isDark: Bool) -> (surface: Color, foreground: Color) {
        let ui = UIColor(self)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getHue(&h, saturation: &s, brightness: &b, alpha: &a)

        if isDark {
            let surface    = Color(hue: h, saturation: 0.30, brightness: 0.15)
            let foreground = Color(hue: h, saturation: s * 0.85, brightness: 0.82)
            return (surface, foreground)
        } else {
            let surface = Color(hue: h, saturation: 0.18, brightness: 0.97)
            // Dark accents are already legible — only adjust bright ones.
            let foreground = perceivedBrightness > 0.5
                ? Color(hue: h, saturation: max(s, 0.80), brightness: 0.52)
                : self
            return (surface, foreground)
        }
    }

    /// Convenience foreground-only accessor (used by the swatch checkmark).
    func foreground(onDark isDark: Bool) -> Color {
        previewPair(onDark: isDark).foreground
    }
}
