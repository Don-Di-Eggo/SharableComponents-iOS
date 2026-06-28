import SwiftUI

/// A single entry from the Process Color Conversion Chart.
/// The `id` matches the chart's color number (1–106) and is the canonical identifier.
/// CMYK values are stored as integer percentages (0–100) as published.
public struct ProcessColor: Identifiable, Hashable, Sendable {
    public let id: Int
    public let c: Int   // Cyan    0–100
    public let m: Int   // Magenta 0–100
    public let y: Int   // Yellow  0–100
    public let k: Int   // Black   0–100

    public init(id: Int, c: Int, m: Int, y: Int, k: Int) {
        self.id = id
        self.c = c
        self.m = m
        self.y = y
        self.k = k
    }

    /// RGB components (0…1) derived from the CMYK values using standard conversion.
    public var rgb: (r: Double, g: Double, b: Double) {
        (Double(100 - c) / 100.0 * Double(100 - k) / 100.0,
         Double(100 - m) / 100.0 * Double(100 - k) / 100.0,
         Double(100 - y) / 100.0 * Double(100 - k) / 100.0)
    }

    /// SwiftUI Color derived from the CMYK values using standard conversion.
    public var color: Color {
        let (r, g, b) = rgb
        return Color(red: r, green: g, blue: b)
    }

    /// Perceptual luminance (0 = black, 1 = white) — used to order colors by lightness.
    public var luminance: Double {
        let (r, g, b) = rgb
        return 0.299 * r + 0.587 * g + 0.114 * b
    }
}

// MARK: - All 106 Process Colors

extension ProcessColor {
    public static let all: [ProcessColor] = [

        // MARK: Deep Reds (1–4) — C=0 M=100 Y=100, K=45→0
        ProcessColor(id:  1, c:  0, m: 100, y: 100, k: 45),
        ProcessColor(id:  2, c:  0, m: 100, y: 100, k: 25),
        ProcessColor(id:  3, c:  0, m: 100, y: 100, k: 15),
        ProcessColor(id:  4, c:  0, m: 100, y: 100, k:  0),

        // MARK: Light Reds / Roses (5–8)
        ProcessColor(id:  5, c:  0, m:  85, y:  70, k:  0),
        ProcessColor(id:  6, c:  0, m:  65, y:  50, k:  0),
        ProcessColor(id:  7, c:  0, m:  45, y:  30, k:  0),
        ProcessColor(id:  8, c:  0, m:  20, y:  10, k:  0),

        // MARK: Burnt Oranges (9–12) — C=0 M=90 Y=80, K=45→0
        ProcessColor(id:  9, c:  0, m:  90, y:  80, k: 45),
        ProcessColor(id: 10, c:  0, m:  90, y:  80, k: 25),
        ProcessColor(id: 11, c:  0, m:  90, y:  80, k: 15),
        ProcessColor(id: 12, c:  0, m:  90, y:  80, k:  0),

        // MARK: Light Oranges / Peach (13–16)
        ProcessColor(id: 13, c:  0, m:  70, y:  65, k:  0),
        ProcessColor(id: 14, c:  0, m:  55, y:  50, k:  0),
        ProcessColor(id: 15, c:  0, m:  40, y:  35, k:  0),
        ProcessColor(id: 16, c:  0, m:  20, y:  20, k:  0),

        // MARK: Ambers (17–20) — C=0 M=60 Y=100, K=45→0
        ProcessColor(id: 17, c:  0, m:  60, y: 100, k: 45),
        ProcessColor(id: 18, c:  0, m:  60, y: 100, k: 25),
        ProcessColor(id: 19, c:  0, m:  60, y: 100, k: 15),
        ProcessColor(id: 20, c:  0, m:  60, y: 100, k:  0),

        // MARK: Light Ambers / Warm Tints (21–24)
        ProcessColor(id: 21, c:  0, m:  50, y:  80, k:  0),
        ProcessColor(id: 22, c:  0, m:  40, y:  60, k:  0),
        ProcessColor(id: 23, c:  0, m:  25, y:  40, k:  0),
        ProcessColor(id: 24, c:  0, m:  15, y:  20, k:  0),

        // MARK: Golden Yellows (25–28) — C=0 M=40 Y=100, K=45→0
        ProcessColor(id: 25, c:  0, m:  40, y: 100, k: 45),
        ProcessColor(id: 26, c:  0, m:  40, y: 100, k: 25),
        ProcessColor(id: 27, c:  0, m:  40, y: 100, k: 15),
        ProcessColor(id: 28, c:  0, m:  40, y: 100, k:  0),

        // MARK: Light Golds (29–32)
        ProcessColor(id: 29, c:  0, m:  30, y:  80, k:  0),
        ProcessColor(id: 30, c:  0, m:  25, y:  60, k:  0),
        ProcessColor(id: 31, c:  0, m:  15, y:  40, k:  0),
        ProcessColor(id: 32, c:  0, m:  10, y:  20, k:  0),

        // MARK: Pure Yellows (33–36) — C=0 M=0 Y=100, K=45→0
        ProcessColor(id: 33, c:  0, m:   0, y: 100, k: 45),
        ProcessColor(id: 34, c:  0, m:   0, y: 100, k: 25),
        ProcessColor(id: 35, c:  0, m:   0, y: 100, k: 15),
        ProcessColor(id: 36, c:  0, m:   0, y: 100, k:  0),

        // MARK: Pale Yellows (37–40)
        ProcessColor(id: 37, c:  0, m:   0, y:  80, k:  0),
        ProcessColor(id: 38, c:  0, m:   0, y:  60, k:  0),
        ProcessColor(id: 39, c:  0, m:   0, y:  40, k:  0),
        ProcessColor(id: 40, c:  0, m:   0, y:  20, k:  0),

        // MARK: Yellow-Greens / Chartreuse (41–44) — C=60 M=0 Y=100, K=45→0
        ProcessColor(id: 41, c: 60, m:   0, y: 100, k: 45),
        ProcessColor(id: 42, c: 60, m:   0, y: 100, k: 25),
        ProcessColor(id: 43, c: 60, m:   0, y: 100, k: 15),
        ProcessColor(id: 44, c: 60, m:   0, y: 100, k:  0),

        // MARK: Light Yellow-Greens (45–48)
        ProcessColor(id: 45, c: 50, m:   0, y:  80, k:  0),
        ProcessColor(id: 46, c: 35, m:   0, y:  60, k:  0),
        ProcessColor(id: 47, c: 25, m:   0, y:  40, k:  0),
        ProcessColor(id: 48, c: 12, m:   0, y:  20, k:  0),

        // MARK: Deep Greens (49–52) — C=100 M=0 Y=90, K=45→0
        ProcessColor(id: 49, c: 100, m:  0, y:  90, k: 45),
        ProcessColor(id: 50, c: 100, m:  0, y:  90, k: 25),
        ProcessColor(id: 51, c: 100, m:  0, y:  90, k: 15),
        ProcessColor(id: 52, c: 100, m:  0, y:  90, k:  0),

        // MARK: Medium Greens (53–56)
        ProcessColor(id: 53, c: 80, m:   0, y:  75, k:  0),
        ProcessColor(id: 54, c: 60, m:   0, y:  55, k:  0),
        ProcessColor(id: 55, c: 45, m:   0, y:  35, k:  0),
        ProcessColor(id: 56, c: 25, m:   0, y:  20, k:  0),

        // MARK: Teals / Cyan-Greens (57–60) — C=100 M=0 Y=40, K=45→0
        ProcessColor(id: 57, c: 100, m:  0, y:  40, k: 45),
        ProcessColor(id: 58, c: 100, m:  0, y:  40, k: 25),
        ProcessColor(id: 59, c: 100, m:  0, y:  40, k: 15),
        ProcessColor(id: 60, c: 100, m:  0, y:  40, k:  0),

        // MARK: Light Teals (61–64)
        ProcessColor(id: 61, c: 80, m:   0, y:  30, k:  0),
        ProcessColor(id: 62, c: 60, m:   0, y:  25, k:  0),
        ProcessColor(id: 63, c: 45, m:   0, y:  20, k:  0),
        ProcessColor(id: 64, c: 25, m:   0, y:  10, k:  0),

        // MARK: Deep Blues (65–68) — C=100 M=60 Y=0, K=45→0
        ProcessColor(id: 65, c: 100, m: 60, y:   0, k: 45),
        ProcessColor(id: 66, c: 100, m: 60, y:   0, k: 25),
        ProcessColor(id: 67, c: 100, m: 60, y:   0, k: 15),
        ProcessColor(id: 68, c: 100, m: 60, y:   0, k:  0),

        // MARK: Medium Blues (69–72)
        ProcessColor(id: 69, c: 85, m:  50, y:   0, k:  0),
        ProcessColor(id: 70, c: 65, m:  40, y:  0, k:  0),
        ProcessColor(id: 71, c: 50, m:  25, y:   0, k:  0),
        ProcessColor(id: 72, c: 30, m:  15, y:   0, k:  0),

        // MARK: Blue-Violets (73–76) — C=100 M=90 Y=0, K=45→0
        ProcessColor(id: 73, c: 100, m: 90, y:   0, k: 45),
        ProcessColor(id: 74, c: 100, m: 90, y:   0, k: 25),
        ProcessColor(id: 75, c: 100, m: 90, y:   0, k: 15),
        ProcessColor(id: 76, c: 100, m: 90, y:   0, k:  0),

        // MARK: Light Blue-Violets (77–80)
        ProcessColor(id: 77, c: 85, m:  80, y:   0, k:  0),
        ProcessColor(id: 78, c: 75, m:  65, y:   0, k:  0),
        ProcessColor(id: 79, c: 60, m:  55, y:   0, k:  0),
        ProcessColor(id: 80, c: 45, m:  40, y:   0, k:  0),

        // MARK: Deep Purples (81–84) — C=80 M=100 Y=0, K=45→0
        ProcessColor(id: 81, c: 80, m: 100, y:   0, k: 45),
        ProcessColor(id: 82, c: 80, m: 100, y:   0, k: 25),
        ProcessColor(id: 83, c: 80, m: 100, y:   0, k: 15),
        ProcessColor(id: 84, c: 80, m: 100, y:   0, k:  0),

        // MARK: Light Purples (85–88)
        ProcessColor(id: 85, c: 65, m:  85, y:   0, k:  0),
        ProcessColor(id: 86, c: 55, m:  65, y:   0, k:  0),
        ProcessColor(id: 87, c: 40, m:  50, y:   0, k:  0),
        ProcessColor(id: 88, c: 25, m:  30, y:   0, k:  0),

        // MARK: Deep Magentas (89–92) — C=40 M=100 Y=0, K=45→0
        ProcessColor(id: 89, c: 40, m: 100, y:   0, k: 45),
        ProcessColor(id: 90, c: 40, m: 100, y:   0, k: 25),
        ProcessColor(id: 91, c: 40, m: 100, y:   0, k: 15),
        ProcessColor(id: 92, c: 40, m: 100, y:   0, k:  0),

        // MARK: Light Magentas / Pinks (93–96)
        ProcessColor(id: 93, c: 35, m:  80, y:   0, k:  0),
        ProcessColor(id: 94, c: 25, m:  60, y:   0, k:  0),
        ProcessColor(id: 95, c: 20, m:  40, y:   0, k:  0),
        ProcessColor(id: 96, c: 10, m:  20, y:   0, k:  0),

        // MARK: Grays / Blacks (97–106) — Pure K steps
        ProcessColor(id:  97, c: 0, m: 0, y: 0, k: 10),
        ProcessColor(id:  98, c: 0, m: 0, y: 0, k: 20),
        ProcessColor(id:  99, c: 0, m: 0, y: 0, k: 30),
        ProcessColor(id: 100, c: 0, m: 0, y: 0, k: 35),
        ProcessColor(id: 101, c: 0, m: 0, y: 0, k: 45),
        ProcessColor(id: 102, c: 0, m: 0, y: 0, k: 55),
        ProcessColor(id: 103, c: 0, m: 0, y: 0, k: 65),
        ProcessColor(id: 104, c: 0, m: 0, y: 0, k: 75),
        ProcessColor(id: 105, c: 0, m: 0, y: 0, k: 85),
        ProcessColor(id: 106, c: 0, m: 0, y: 0, k: 100),

        // MARK: White (107) — introduced by the "Pure" palettes as the white token
        ProcessColor(id: 107, c: 0, m: 0, y: 0, k: 0),
    ]

    /// Look up a color by its chart number (1–107). Returns nil for out-of-range ids.
    public static func color(id: Int) -> ProcessColor? {
        guard id >= 1, id <= 107 else { return nil }
        return all.first { $0.id == id }
    }
}

// MARK: - Hue Family

extension ProcessColor {
    public enum HueFamily: String, CaseIterable {
        case deepReds        = "Deep Reds"
        case lightReds       = "Light Reds"
        case burntOranges    = "Burnt Oranges"
        case lightOranges    = "Light Oranges"
        case ambers          = "Ambers"
        case lightAmbers     = "Light Ambers"
        case goldenYellows   = "Golden Yellows"
        case lightGolds      = "Light Golds"
        case pureYellows     = "Pure Yellows"
        case paleYellows     = "Pale Yellows"
        case yellowGreens    = "Yellow-Greens"
        case lightYellowGreens = "Light Yellow-Greens"
        case deepGreens      = "Deep Greens"
        case mediumGreens    = "Medium Greens"
        case teals           = "Teals"
        case lightTeals      = "Light Teals"
        case deepBlues       = "Deep Blues"
        case mediumBlues     = "Medium Blues"
        case blueViolets     = "Blue-Violets"
        case lightBlueViolets = "Light Blue-Violets"
        case deepPurples     = "Deep Purples"
        case lightPurples    = "Light Purples"
        case deepMagentas    = "Deep Magentas"
        case lightMagentas   = "Light Magentas"
        case grays           = "Grays"
    }

    public var family: HueFamily {
        switch id {
        case  1...4:   return .deepReds
        case  5...8:   return .lightReds
        case  9...12:  return .burntOranges
        case 13...16:  return .lightOranges
        case 17...20:  return .ambers
        case 21...24:  return .lightAmbers
        case 25...28:  return .goldenYellows
        case 29...32:  return .lightGolds
        case 33...36:  return .pureYellows
        case 37...40:  return .paleYellows
        case 41...44:  return .yellowGreens
        case 45...48:  return .lightYellowGreens
        case 49...52:  return .deepGreens
        case 53...56:  return .mediumGreens
        case 57...60:  return .teals
        case 61...64:  return .lightTeals
        case 65...68:  return .deepBlues
        case 69...72:  return .mediumBlues
        case 73...76:  return .blueViolets
        case 77...80:  return .lightBlueViolets
        case 81...84:  return .deepPurples
        case 85...88:  return .lightPurples
        case 89...92:  return .deepMagentas
        case 93...96:  return .lightMagentas
        default:       return .grays
        }
    }

    public static func colors(in family: HueFamily) -> [ProcessColor] {
        all.filter { $0.family == family }
    }
}
