//
//  AppPaletteSelectable.swift
//  SharableComponents
//

import SwiftUI

// MARK: - Protocol

/// The contract any palette model must satisfy to work with `AppPaletteSelectionView`.
///
/// Implement this on your own type to supply custom palettes without coupling to `AppPalettePreset`.
public protocol AppPaletteSelectable: Identifiable, Equatable {
    /// User-visible name for this palette.
    var paletteName: String { get }

    /// Raw swatch colors in their original order (shown as a horizontal strip in the picker).
    var swatchColors: [Color] { get }

    /// Auto-derived search tags (e.g. "red", "dark", "pastel", "warm").
    /// Used by `AppPaletteSelectionView`'s search bar to filter the catalog.
    var tags: Set<String> { get }

    // MARK: Semantic tokens
    /// Buttons, icons, links, interactive controls.
    var accentColor: Color { get }
    /// Overall app surface — the primary background.
    var backgroundColor: Color { get }
    /// Cards, list sections — offset from the primary background.
    var groupedBackground: Color { get }
    /// Text fields, search bars, input controls.
    var fillColor: Color { get }
    /// Primary text — titles, labels.
    var labelColor: Color { get }
    /// Captions, supporting text, secondary information.
    var secondaryLabelColor: Color { get }
}

// MARK: - Color helpers (internal to this component)
// Prefixed `palette` to avoid colliding with extensions in other components.

extension Color {

    init(paletteHex hex: String) {
        let clean = hex
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        guard clean.count == 6, let v = Int(clean, radix: 16) else { self = .gray; return }
        self = Color(
            red:   Double((v >> 16) & 0xFF) / 255,
            green: Double((v >>  8) & 0xFF) / 255,
            blue:  Double( v        & 0xFF) / 255
        )
    }

    /// Perceived brightness (0 = black, 1 = white) using the luma formula.
    var paletteLuminance: CGFloat {
        let ui = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        return 0.299 * r + 0.587 * g + 0.114 * b
    }

    var paletteHSB: (h: CGFloat, s: CGFloat, b: CGFloat) {
        let ui = UIColor(self)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return (h, s, b)
    }

    var paletteSaturation: CGFloat {
        let ui = UIColor(self)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return s
    }

    // MARK: WCAG contrast helpers

    /// WCAG 2.1 relative luminance (more accurate than the luma shortcut).
    var wcagLuminance: CGFloat {
        let ui = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        func lin(_ c: CGFloat) -> CGFloat { c <= 0.03928 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4) }
        return 0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b)
    }

    /// WCAG contrast ratio between this color and `other` (1.0 – 21.0).
    func wcagContrast(against other: Color) -> CGFloat {
        let l1 = max(wcagLuminance, other.wcagLuminance)
        let l2 = min(wcagLuminance, other.wcagLuminance)
        return (l1 + 0.05) / (l2 + 0.05)
    }

    /// Returns a copy of this color with brightness nudged (in HSB) until it achieves
    /// `minimum` contrast against `background`. Uses binary search; preserves hue and saturation.
    /// Falls back to pure black or white only if the palette color is already at the limit.
    func paletteAdjusted(for minimum: CGFloat, against background: Color) -> Color {
        guard wcagContrast(against: background) < minimum else { return self }

        let ui = UIColor(self)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getHue(&h, saturation: &s, brightness: &b, alpha: &a)

        // Push toward dark when bg is light, toward light when bg is dark.
        let pushDark = background.wcagLuminance > 0.18
        var lo: CGFloat = pushDark ? 0.0 : b
        var hi: CGFloat = pushDark ? b   : 1.0

        for _ in 0..<24 {
            let mid = (lo + hi) / 2
            let candidate = Color(hue: h, saturation: s, brightness: mid)
            if candidate.wcagContrast(against: background) >= minimum {
                if pushDark { lo = mid } else { hi = mid }
            } else {
                if pushDark { hi = mid } else { lo = mid }
            }
        }
        return Color(hue: h, saturation: s, brightness: pushDark ? lo : hi)
    }

    /// Linear interpolation toward `other` in RGB space.
    func paletteBlended(toward other: Color, by ratio: CGFloat) -> Color {
        let u1 = UIColor(self),  u2 = UIColor(other)
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        u1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        u2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        return Color(
            red:   r1 + (r2 - r1) * ratio,
            green: g1 + (g2 - g1) * ratio,
            blue:  b1 + (b2 - b1) * ratio
        )
    }
}
