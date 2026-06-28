import SwiftUI

// MARK: - Facet 1: Hue
//
// The nine user-facing hue buckets from the book's "What's Your Color?" section.
// Coarser than ProcessColor.HueFamily — these collapse the 25 fine-grained families
// into the colors a user actually reaches for when filtering.

public enum PaletteHue: String, CaseIterable, Sendable {
    case red    = "Red"
    case pink   = "Pink"
    case orange = "Orange"
    case yellow = "Yellow"
    case green  = "Green"
    case blue   = "Blue"
    case purple = "Purple"
    case brown  = "Brown"
    case gray   = "Gray"

    /// Classify a single process color into one of the nine hue buckets from its CMYK values.
    public init(_ color: ProcessColor) {
        let c = Double(color.c), m = Double(color.m)
        let y = Double(color.y), k = Double(color.k)

        // Achromatic: no chroma at all → gray (covers the 97–106 K ramp).
        if c == 0, m == 0, y == 0 { self = .gray; return }

        // Brown: warm hue knocked down by black (dark amber/orange with K).
        if c == 0, m > 0, y > 0, k >= 15, m <= 70 { self = .brown; return }

        switch (c, m, y) {
        case let (c, m, y) where c == 0 && m >= y && y > 0:
            // Red/orange family: magenta-dominant warm with yellow.
            if m >= 80 && y >= 80 { self = .red }
            else if m <= 30 && y <= 30 { self = .pink }   // soft desaturated warm
            else { self = .orange }
        case let (c, m, y) where c == 0 && y > m:
            self = .yellow                                  // yellow-dominant warm
        case let (c, _, y) where c > 0 && y > 0 && color.m == 0:
            self = .green                                   // cyan + yellow, no magenta
        case let (c, m, _) where c > 0 && m == 0:
            // Cyan with little/no yellow → blue-green to blue; treat as blue/green by yellow.
            self = color.y >= 40 ? .green : .blue
        case let (c, m, _) where c >= m && m > 0 && y == 0:
            self = .blue                                    // cyan-dominant with magenta
        case let (_, m, _) where m > c && y == 0:
            self = m >= 80 ? .purple : .pink                // magenta-dominant cool
        default:
            self = .purple
        }
    }
}

// MARK: - Facet 2: Aspect
//
// The eight temperature/value qualities from the book's "Aspects of Color" section
// (p.15–23). Each is defined there in CMYK terms, so all are derivable.
// A color can satisfy several (e.g. Hot is also Warm and Bright).

public enum PaletteAspect: String, CaseIterable, Sendable {
    case hot    = "Hot"
    case cold   = "Cold"
    case warm   = "Warm"
    case cool   = "Cool"
    case light  = "Light"
    case dark   = "Dark"
    case pale   = "Pale"
    case bright = "Bright"

    /// All aspects a single color satisfies (per the book's CMYK definitions).
    public static func aspects(of color: ProcessColor) -> Set<PaletteAspect> {
        var result: Set<PaletteAspect> = []
        let c = color.c, m = color.m, y = color.y, k = color.k
        let chroma = max(c, m, y)                 // overall colourfulness
        let whiteness = 100 - chroma              // implied white in the mix

        // Hot: red at/near full saturation (M & Y high, no cyan, no black).
        if c == 0, m >= 90, y >= 70, k == 0 { result.insert(.hot) }
        // Cold: blue at/near full saturation (cyan high, no magenta-warmth/yellow).
        if c >= 90, m <= 60, y <= 40, k == 0 { result.insert(.cold) }
        // Warm: contains both red and yellow (magenta + yellow present).
        if m > 0, y > 0, c < m { result.insert(.warm) }
        // Cool: blue base with yellow added → greens/teals.
        if c > 0, y > 0, m < c { result.insert(.cool) }
        // Bright: full-strength pure colour — no black, no graying white.
        if k == 0, chroma >= 80, whiteness <= 20 { result.insert(.bright) }
        // Dark: meaningful black content.
        if k >= 25 { result.insert(.dark) }
        // Light: palest pastels — low chroma, no black.
        if k == 0, chroma <= 40 { result.insert(.light) }
        // Pale: ≥65% white in the mix (the book's threshold).
        if k == 0, whiteness >= 65 { result.insert(.pale) }
        return result
    }
}

// MARK: - Facet 3: Scheme
//
// The ten structural relationships from the book's "Basic Color Schemes" section
// (p.24–27). A scheme describes how the colors in a palette relate on the wheel,
// so it is a tag on the palette as a whole, not on an individual color.

public enum PaletteScheme: String, CaseIterable, Sendable {
    case achromatic         = "Achromatic"
    case analogous          = "Analogous"
    case clash              = "Clash"
    case complementary      = "Complementary"
    case monochromatic      = "Monochromatic"
    case neutral            = "Neutral"
    case splitComplementary = "Split Complementary"
    case primary            = "Primary"
    case secondary          = "Secondary"
    case tertiary           = "Tertiary"

    public var detail: String {
        switch self {
        case .achromatic:         return "Without color, uses only black, white, and grays."
        case .analogous:          return "Any three consecutive hues, or their tints and shades."
        case .clash:              return "A color with the hue to the right or left of its complement."
        case .complementary:      return "Direct opposites on the color wheel."
        case .monochromatic:      return "One hue with any of its tints and shades."
        case .neutral:            return "A hue neutralized by its complement or black."
        case .splitComplementary: return "A hue and the two hues on either side of its complement."
        case .primary:            return "The pure hues of red, yellow, and blue."
        case .secondary:          return "The secondary hues of green, violet, and orange."
        case .tertiary:           return "Three hues equidistant on the wheel (a tertiary triad)."
        }
    }
}

// MARK: - Facet 4: Mood
//
// Descriptive labels attached to each palette set in the book. Not derivable from
// CMYK — supplied per palette from the source material.

public enum PaletteMood: String, CaseIterable, Sendable {
    case powerful, rich, romantic, vital, earthy, friendly, soft, welcoming
    case moving, elegant, trendy, fresh, traditional, refreshing, tropical, classic
    case dependable, calm, regal, magical, nostalgic, energetic, subdued
    case pure, graphic

    /// User-facing display label — a synonym of the source mood word.
    ///
    /// The `rawValue` is kept as the stable internal id (it keys palette ids and the
    /// frozen `PaletteNames` map); only the presented word is swapped here.
    public var label: String {
        switch self {
        case .powerful:    return "Strong"
        case .rich:        return "Opulent"
        case .romantic:    return "Tender"
        case .vital:       return "Lively"
        case .earthy:      return "Rustic"
        case .friendly:    return "Genial"
        case .soft:        return "Gentle"
        case .welcoming:   return "Inviting"
        case .moving:      return "Dynamic"
        case .elegant:     return "Refined"
        case .trendy:      return "Stylish"
        case .fresh:       return "Crisp"
        case .traditional: return "Heritage"
        case .refreshing:  return "Invigorating"
        case .tropical:    return "Exotic"
        case .classic:     return "Enduring"
        case .dependable:  return "Reliable"
        case .calm:        return "Serene"
        case .regal:       return "Majestic"
        case .magical:     return "Enchanting"
        case .nostalgic:   return "Wistful"
        case .energetic:   return "Vibrant"
        case .subdued:     return "Muted"
        case .pure:        return "Pristine"
        case .graphic:     return "Bold"
        }
    }
}
