//
//  AppColorOption.swift
//  SharableComponents
//

import SwiftUI

// MARK: - Protocol

/// The small contract any color model must satisfy to work with `AppColorSelectionView`.
///
/// Implement this on your own color enum/struct to supply custom presets
/// without coupling to `AppColorPreset`.
public protocol AppColorSelectable: Identifiable, Equatable {

    /// User-visible label shown under the swatch.
    var colorName: String { get }

    /// The deep accent colour — used for text, icons, and interactive controls.
    var accentColor: Color { get }

    /// The lightly tinted background colour paired with `accentColor`.
    var backgroundColor: Color { get }
}

// MARK: - Built-in presets

/// Ready-to-use color presets combining the LongLead curated set and
/// Apple's full 36-colour crayon palette.
///
/// Pass `AppColorPreset.all` to `AppColorSelectionView` for the full catalogue,
/// or use `AppColorPreset.longlead` / `AppColorPreset.crayon` for subsets.
public enum AppColorPreset: String, AppColorSelectable, CaseIterable {

    // MARK: LongLead curated (20)
    case forest
    case ocean
    case purple
    case crimson
    case orange
    case teal
    case midnight
    case burgundy
    case pine
    case indigo
    case graphite
    case olive
    case mauve
    case steel
    case amber
    case sage
    case plum
    case slate
    case moss
    case espresso

    // MARK: Apple crayons — dark row (7, excluding names already in LongLead set)
    case cayenne
    case mocha
    case asparagus
    case fern
    case clover
    case eggplant
    case maroon

    // MARK: Apple crayons — medium row (12)
    case maraschino
    case tangerine
    case lemon
    case lime
    case spring
    case seaFoam
    case turquoise
    case aqua
    case blueberry
    case grape
    case magenta
    case strawberry

    // MARK: Apple crayons — light row (12)
    case salmon
    case cantaloupe
    case banana
    case honeydew
    case flora
    case spindrift
    case ice
    case sky
    case orchid
    case lavender
    case bubblegum
    case carnation

    public var id: String { rawValue }

    public var colorName: String {
        switch self {
        // LongLead
        case .forest:        "Forest"
        case .ocean:         "Ocean"
        case .purple:        "Purple"
        case .crimson:       "Crimson"
        case .orange:        "Orange"
        case .teal:          "Teal"
        case .midnight:      "Midnight"
        case .burgundy:      "Burgundy"
        case .pine:          "Pine"
        case .indigo:        "Indigo"
        case .graphite:      "Graphite"
        case .olive:         "Olive"
        case .mauve:         "Mauve"
        case .steel:         "Steel"
        case .amber:         "Amber"
        case .sage:          "Sage"
        case .plum:          "Plum"
        case .slate:         "Slate"
        case .moss:          "Moss"
        case .espresso:      "Espresso"
        // Apple dark row
        case .cayenne:       "Cayenne"
        case .mocha:         "Mocha"
        case .asparagus:     "Asparagus"
        case .fern:          "Fern"
        case .clover:        "Clover"
        case .eggplant:      "Eggplant"
        case .maroon:        "Maroon"
        // Apple medium row
        case .maraschino:    "Maraschino"
        case .tangerine:     "Tangerine"
        case .lemon:         "Lemon"
        case .lime:          "Lime"
        case .spring:        "Spring"
        case .seaFoam:       "Sea Foam"
        case .turquoise:     "Turquoise"
        case .aqua:          "Aqua"
        case .blueberry:     "Blueberry"
        case .grape:         "Grape"
        case .magenta:       "Magenta"
        case .strawberry:    "Strawberry"
        // Apple light row
        case .salmon:        "Salmon"
        case .cantaloupe:    "Cantaloupe"
        case .banana:        "Banana"
        case .honeydew:      "Honeydew"
        case .flora:         "Flora"
        case .spindrift:     "Spindrift"
        case .ice:           "Ice"
        case .sky:           "Sky"
        case .orchid:        "Orchid"
        case .lavender:      "Lavender"
        case .bubblegum:     "Bubblegum"
        case .carnation:     "Carnation"
        }
    }

    // MARK: - Accent hex

    private var accentHex: String {
        switch self {
        // LongLead curated
        case .forest:        "#3A6B0E"
        case .ocean:         "#1A4A7A"
        case .purple:        "#5A1A8A"
        case .crimson:       "#8A1A1A"
        case .orange:        "#8A3A0A"
        case .teal:          "#0A5A5A"
        case .midnight:      "#0D2560"
        case .burgundy:      "#7A1040"
        case .pine:          "#1A4A2A"
        case .indigo:        "#2A1A7A"
        case .graphite:      "#2A2A3A"
        case .olive:         "#4A4A0A"
        case .mauve:         "#7A1A5A"
        case .steel:         "#1A3A5A"
        case .amber:         "#7A4A0A"
        case .sage:          "#2A5A3A"
        case .plum:          "#5A0A6A"
        case .slate:         "#2A3A5A"
        case .moss:          "#2A4A1A"
        case .espresso:      "#4A2A0A"
        // Apple dark row
        case .cayenne:       "#891100"
        case .mocha:         "#894800"
        case .asparagus:     "#888501"
        case .fern:          "#458401"
        case .clover:        "#028401"
        case .eggplant:      "#491A91"
        case .maroon:        "#8E0039"
        // Apple medium row
        case .maraschino:    "#FF2101"
        case .tangerine:     "#FF7F00"
        case .lemon:         "#FFFA03"
        case .lime:          "#83F902"
        case .spring:        "#05F842"
        case .seaFoam:       "#03F78B"
        case .turquoise:     "#00FDFF"
        case .aqua:          "#00AEFF"
        case .blueberry:     "#0433FF"
        case .grape:         "#7A00FF"
        case .magenta:       "#FF40FF"
        case .strawberry:    "#FF2F92"
        // Apple light row
        case .salmon:        "#FF8177"
        case .cantaloupe:    "#FFD479"
        case .banana:        "#FFFC79"
        case .honeydew:      "#D4FB79"
        case .flora:         "#73FA79"
        case .spindrift:     "#73FCD6"
        case .ice:           "#73FDFF"
        case .sky:           "#76D6FF"
        case .orchid:        "#7A81FF"
        case .lavender:      "#D783FF"
        case .bubblegum:     "#FF85FF"
        case .carnation:     "#FF98AA"
        }
    }

    // LongLead presets use hand-tuned background tints; Apple crayons derive theirs at runtime.
    private var lightBgHex: String? {
        switch self {
        case .forest:   "#F2F7EE"
        case .ocean:    "#EEF3F8"
        case .purple:   "#F5EEFA"
        case .crimson:  "#FAF0F0"
        case .orange:   "#FAF3EE"
        case .teal:     "#EEF7F7"
        case .midnight: "#EEF0F8"
        case .burgundy: "#F8EEF2"
        case .pine:     "#EFF7F1"
        case .indigo:   "#F2EEF9"
        case .graphite: "#F2F2F4"
        case .olive:    "#F6F6EE"
        case .mauve:    "#F8EEF5"
        case .steel:    "#EEF2F7"
        case .amber:    "#F8F4EE"
        case .sage:     "#EFF7F2"
        case .plum:     "#F6EEF8"
        case .slate:    "#EEF1F6"
        case .moss:     "#EFF6EE"
        case .espresso: "#F6F2EE"
        default:        nil  // Apple crayons derive from accent
        }
    }

    // MARK: - Protocol conformance

    public var accentColor: Color     { Color(colorHex: accentHex) }
    public var backgroundColor: Color {
        if let hex = lightBgHex { return Color(colorHex: hex) }
        return accentColor.blendedTowardWhite(0.93)
    }

    // MARK: - Subsets

    public static var all: [AppColorPreset]      { allCases }
    public static var longlead: [AppColorPreset]  { allCases.filter { $0.lightBgHex != nil } }
    public static var crayon: [AppColorPreset]    { allCases.filter { $0.lightBgHex == nil } }
}
