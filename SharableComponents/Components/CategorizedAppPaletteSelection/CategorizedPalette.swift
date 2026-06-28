import SwiftUI

/// A three-color palette drawn from the source book.
///
/// A palette is stored as three `ProcessColor` chart numbers (1–106) — the native
/// format the book uses — plus the descriptive **moods** the book assigns to it.
/// The remaining facets (**hue**, **aspect**, **scheme**) are derived from the
/// member colors so they never have to be hand-maintained.
public struct CategorizedPalette: Identifiable, Hashable, Sendable {
    public let id: String
    /// The three ProcessColor chart numbers, in the order presented in the book.
    public let colorIDs: [Int]
    /// Descriptive moods supplied from the book (e.g. `.romantic`, `.elegant`).
    public let moods: Set<PaletteMood>
    /// Optional structural scheme tag (e.g. `.analogous`) when the book states one.
    public let scheme: PaletteScheme?

    public init(
        id: String,
        colorIDs: [Int],
        moods: Set<PaletteMood> = [],
        scheme: PaletteScheme? = nil
    ) {
        self.id = id
        self.colorIDs = colorIDs
        self.moods = moods
        self.scheme = scheme
    }

    /// An evocative, color-derived display name.
    ///
    /// Returns the frozen, stable name from `PaletteNames` so labels never change once
    /// shipped; falls back to live generation only for palettes added since the freeze.
    public var name: String {
        PaletteNames.byID[id] ?? PaletteNaming.name(for: self)
    }

    // MARK: Resolved colors

    /// The member `ProcessColor`s, resolved from their chart numbers (skips any unknown id).
    public var colors: [ProcessColor] {
        colorIDs.compactMap { ProcessColor.color(id: $0) }
    }

    /// Member colors as SwiftUI `Color`s.
    public var swiftUIColors: [Color] { colors.map(\.color) }

    // MARK: Derived facets

    /// All hue buckets represented across the three colors.
    public var hues: Set<PaletteHue> {
        Set(colors.map(PaletteHue.init))
    }

    /// All aspects satisfied by any member color.
    public var aspects: Set<PaletteAspect> {
        colors.reduce(into: Set<PaletteAspect>()) { $0.formUnion(PaletteAspect.aspects(of: $1)) }
    }

    // MARK: Filtering

    /// True when the palette matches the supplied facet constraints.
    ///
    /// Hue, aspect, and scheme are **AND**-combined (all must match). Moods are
    /// **OR**-combined: the palette matches if it carries *any* of the requested moods —
    /// since each palette has a single mood, requiring all of them would match nothing.
    /// Any `nil`/empty constraint is ignored.
    public func matches(
        hue: PaletteHue? = nil,
        aspect: PaletteAspect? = nil,
        scheme: PaletteScheme? = nil,
        moods requestedMoods: Set<PaletteMood> = []
    ) -> Bool {
        if let hue, !hues.contains(hue) { return false }
        if let aspect, !aspects.contains(aspect) { return false }
        if let scheme, self.scheme != scheme { return false }
        if !requestedMoods.isEmpty, requestedMoods.isDisjoint(with: moods) { return false }
        return true
    }

    // MARK: Representative colors (for theming UI from a selection)

    private func chroma(_ c: ProcessColor) -> Int { max(c.c, c.m, c.y) }

    /// The most saturated member — a good accent/tint color.
    public var dominantColor: Color {
        (colors.max { chroma($0) < chroma($1) } ?? colors.first ?? ProcessColor(id: 0, c: 0, m: 0, y: 0, k: 0)).color
    }

    /// The member carrying the least ink — a good pale surface color.
    public var lightestColor: Color {
        (colors.min { (chroma($0) + $0.k) < (chroma($1) + $1.k) } ?? colors.first ?? ProcessColor(id: 0, c: 0, m: 0, y: 0, k: 0)).color
    }

    /// The lightest member by perceptual luminance — best as text on a dark surface.
    public var lightestByLuminance: Color {
        (colors.max { $0.luminance < $1.luminance } ?? colors.first ?? ProcessColor(id: 0, c: 0, m: 0, y: 0, k: 0)).color
    }

    /// The darkest member by perceptual luminance — best as text on a light surface.
    public var darkestByLuminance: Color {
        (colors.min { $0.luminance < $1.luminance } ?? colors.first ?? ProcessColor(id: 0, c: 0, m: 0, y: 0, k: 0)).color
    }

    /// Black or white, whichever reads better on the dominant color (for button labels).
    public var dominantContrastColor: Color {
        let lum = (colors.max { chroma($0) < chroma($1) } ?? colors.first)?.luminance ?? 0
        return lum > 0.55 ? .black : .white
    }
}

// MARK: - Palette Library

extension CategorizedPalette {
    /// The curated three-color palettes from the book.
    /// Assembled per-mood in `PaletteData` as source pages are transcribed.
    public static let all: [CategorizedPalette] = PaletteData.all

    // Convenience filtered views over `all`.

    public static func palettes(hue: PaletteHue) -> [CategorizedPalette] {
        all.filter { $0.matches(hue: hue) }
    }

    public static func palettes(aspect: PaletteAspect) -> [CategorizedPalette] {
        all.filter { $0.matches(aspect: aspect) }
    }

    public static func palettes(mood: PaletteMood) -> [CategorizedPalette] {
        all.filter { $0.moods.contains(mood) }
    }
}
