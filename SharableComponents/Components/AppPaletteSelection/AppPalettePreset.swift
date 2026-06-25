//
//  AppPalettePreset.swift
//  SharableComponents
//

import SwiftUI

// MARK: - Struct

/// A concrete palette sourced from Coolors (or any N-color hex set).
///
/// Semantic tokens (`accentColor`, `backgroundColor`, etc.) are derived automatically
/// by sorting the palette's colors by luminance and assigning roles — no manual mapping needed.
///
/// Colors are the same in light and dark mode; the user chose them intentionally.
///
/// ```swift
/// // From a Coolors URL:
/// AppPalettePreset(name: "Retro", coolorsURL: "https://coolors.co/264653-2a9d8f-e9c46a-f4a261-e76f51")
///
/// // From just the hex slug:
/// AppPalettePreset(name: "Retro", hexSlug: "264653-2a9d8f-e9c46a-f4a261-e76f51")
///
/// // From an explicit array:
/// AppPalettePreset(name: "Retro", hexColors: ["264653", "2a9d8f", "e9c46a", "f4a261", "e76f51"])
/// ```
public struct AppPalettePreset: AppPaletteSelectable {

    // MARK: Stored

    public let id: String
    public let paletteName: String
    /// Lowercased 6-char hex codes in Coolors order (used for persistence).
    public let hexCodes: [String]

    // MARK: Init

    public init(name: String, hexColors: [String]) {
        let cleaned = hexColors.map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
              .replacingOccurrences(of: "#", with: "")
              .lowercased()
        }
        self.paletteName = name
        self.hexCodes    = cleaned
        self.id          = cleaned.joined(separator: "-")
    }

    public init?(name: String, hexSlug: String) {
        let codes = Self.parseSlug(hexSlug)
        guard codes.count >= 2 else { return nil }
        self.init(name: name, hexColors: codes)
    }

    public init?(name: String, coolorsURL: String) {
        guard let slug = Self.slugFrom(url: coolorsURL) else { return nil }
        self.init(name: name, hexSlug: slug)
    }

    // MARK: Equatable

    public static func == (lhs: AppPalettePreset, rhs: AppPalettePreset) -> Bool {
        lhs.id == rhs.id
    }

    // MARK: Parsing (internal — used by AddPaletteSheet)

    /// Extracts the hex slug from a Coolors URL. Handles both
    /// `coolors.co/hex1-hex2-…` and `coolors.co/palette/hex1-hex2-…`.
    static func slugFrom(url urlString: String) -> String? {
        guard let url = URL(string: urlString) else { return nil }
        return url.path
            .split(separator: "/")
            .map(String.init)
            .reversed()
            .first { parseSlug($0).count >= 2 }
    }

    /// Splits a slug like "264653-2a9d8f-e9c46a" into validated 6-char hex codes.
    static func parseSlug(_ slug: String) -> [String] {
        slug.split(separator: "-")
            .map(String.init)
            .filter { $0.count == 6 && Int($0, radix: 16) != nil }
    }

    // MARK: AppPaletteSelectable — raw swatches

    public var swatchColors: [Color] { hexCodes.map { Color(paletteHex: $0) } }

    // MARK: Semantic tokens — luminance-based assignment
    //
    // Sort palette colors darkest → lightest, then assign:
    //   [0]      → labelColor          (darkest = most readable as text)
    //   [last]   → backgroundColor     (lightest = most suitable as a surface)
    //   [last-1] → groupedBackground   (second-lightest = cards / sections)
    //   middle   → accentColor         (most saturated of the remaining colors)
    //   derived  → fillColor           (midpoint between bg and grouped bg)
    //   derived  → secondaryLabelColor (label blended 50% toward background)

    private var byLuminance: [Color] {
        swatchColors.sorted { $0.paletteLuminance < $1.paletteLuminance }
    }

    public var labelColor: Color {
        let candidate = byLuminance.first ?? .black
        // Enforce WCAG AA (4.5:1) against the background; nudge brightness if needed.
        return candidate.paletteAdjusted(for: 4.5, against: backgroundColor)
    }

    public var backgroundColor: Color {
        byLuminance.last ?? .white
    }

    public var groupedBackground: Color {
        let s = byLuminance
        return s.count >= 2 ? s[s.count - 2] : backgroundColor
    }

    public var accentColor: Color {
        let s = byLuminance
        guard s.count >= 3 else { return s[s.count / 2] }
        let middle = Array(s.dropFirst().dropLast())
        return middle.max(by: { $0.paletteSaturation < $1.paletteSaturation })
            ?? middle[middle.count / 2]
    }

    public var fillColor: Color {
        backgroundColor.paletteBlended(toward: groupedBackground, by: 0.5)
    }

    public var secondaryLabelColor: Color {
        // Blend 50% toward background for a lighter secondary feel,
        // then enforce WCAG Large Text (3.0:1) so it stays legible.
        let blended = labelColor.paletteBlended(toward: backgroundColor, by: 0.5)
        return blended.paletteAdjusted(for: 3.0, against: backgroundColor)
    }

    // MARK: Auto-derived search tags
    //
    // Tags are computed from the palette's swatch colors — no manual authoring needed.
    // Hue families: red, orange, yellow, green, teal, blue, purple, pink
    // Brightness:   dark (avg luminance < 0.25), light (avg > 0.72)
    // Character:    pastel (light + low sat), vibrant (high sat), neutral (very low sat)
    // Temperature:  warm (reds/oranges/yellows dominate), cool (blues/greens/purples dominate)
    // Texture:      earth (warm + mid saturation + mid brightness)

    public var tags: Set<String> {
        var result = Set<String>()

        let hsbs       = swatchColors.map(\.paletteHSB)
        let luminances = swatchColors.map(\.paletteLuminance)
        let avgLum     = luminances.reduce(0, +) / CGFloat(luminances.count)
        let avgSat     = hsbs.map(\.s).reduce(0, +) / CGFloat(hsbs.count)

        // Brightness
        if avgLum < 0.25 { result.insert("dark") }
        if avgLum > 0.72 { result.insert("light") }

        // Character
        if avgLum > 0.70 && avgSat < 0.35 { result.insert("pastel") }
        if avgSat < 0.18                   { result.insert("neutral") }
        if avgSat > 0.60                   { result.insert("vibrant") }

        // Hue families + warm/cool tallies
        var warmCount = 0, coolCount = 0, coloredCount = 0

        for (h, s, _) in hsbs {
            guard s > 0.15 else { continue }
            coloredCount += 1

            switch h {
            case 0.000..<0.042: result.insert("red")
            case 0.042..<0.125: result.insert("orange")
            case 0.125..<0.194: result.insert("yellow")
            case 0.194..<0.417: result.insert("green")
            case 0.417..<0.542: result.insert("teal")
            case 0.542..<0.708: result.insert("blue")
            case 0.708..<0.792: result.insert("purple")
            case 0.792..<0.958: result.insert("pink")
            default:            result.insert("red")   // wraps near 1.0
            }

            if h < 0.194 || h >= 0.958 { warmCount += 1 } else { coolCount += 1 }
        }

        if coloredCount > 0 {
            if warmCount > coolCount { result.insert("warm") }
            if coolCount > warmCount { result.insert("cool") }
        }

        // Earth: warm palette, mid saturation, mid brightness
        if result.contains("warm") && avgSat > 0.15 && avgSat < 0.65
            && avgLum > 0.20 && avgLum < 0.78 {
            result.insert("earth")
        }

        return result
    }
}

// MARK: - Built-in catalog

public extension AppPalettePreset {

    /// Built-in palettes sourced from Coolors, sorted alphabetically by name.
    static let builtIn: [AppPalettePreset] = ([
        .init(name: "Retro",                   hexSlug: "264653-2a9d8f-e9c46a-f4a261-e76f51")!,
        .init(name: "Sunset Glow",             hexSlug: "f4e409-eeba0b-c36f09-a63c06-710000")!,
        .init(name: "Nature Harmony",          hexSlug: "eff1ed-373d20-717744-bcbd8b-766153")!,
        .init(name: "Autumn Glow",             hexSlug: "780116-f7b538-db7c26-d8572a-c32f27")!,
        .init(name: "Sunset Bliss",            hexSlug: "ee6352-59cd90-3fa7d6-fac05e-f79d84")!,
        .init(name: "Mystic Waters",           hexSlug: "360568-5b2a86-7785ac-9ac6c5-a5e6ba")!,
        .init(name: "Dark Romance",            hexSlug: "211103-3d1308-7b0d1e-9f2042-f8e5ee")!,
        .init(name: "Oceanic Sunburst",        hexSlug: "11296b-00509d-ededed-ffdb57-ffcb05")!,
        .init(name: "Rustic Charm",            hexSlug: "fffcf2-ccc5b9-403d39-252422-eb5e28")!,
        .init(name: "Summer Ocean Breeze",     hexSlug: "e63946-f1faee-a8dadc-457b9d-1d3557")!,
        .init(name: "Soft Pink Delight",       hexSlug: "ffe5ec-ffc2d1-ffb3c6-ff8fab-fb6f92")!,
        .init(name: "Fiery Palette",           hexSlug: "5f0f40-9a031e-fb8b24-e36414-0f4c5c")!,
        .init(name: "Neutral Harmony Bliss",   hexSlug: "f4f1de-e07a5f-3d405b-81b29a-f2cc8f")!,
        .init(name: "Sweet Summer Melody",     hexSlug: "f6bd60-f7ede2-f5cac3-84a59d-f28482")!,
        .init(name: "Warm Rustic",             hexSlug: "585123-eec170-f2a65a-f58549-772f1a")!,
        .init(name: "Cool Coastal",            hexSlug: "2b2d42-8d99ae-edf2f4-ef233c-d90429")!,
        .init(name: "Deep Sea",                hexSlug: "0d1b2a-1b263b-415a77-778da9-e0e1dd")!,
        .init(name: "Candy Pop",               hexSlug: "9b5de5-f15bb5-fee440-00bbf9-00f5d4")!,
        .init(name: "Golden Glow",             hexSlug: "7c6a0a-babd8d-ffdac6-fa9500-eb6424")!,
        .init(name: "Autumn Harvest", hexSlug: "6f1d1b-bb9457-432818-99582a-ffe6a7")!,
        .init(name: "Black And Gold", hexSlug: "000000-14213d-fca311-e5e5e5-ffffff")!,
        .init(name: "Midnight Sky",   hexSlug: "00296b-003f88-00509d-fdc500-ffd500")!,
        .init(name: "Earthy Tones",   hexSlug: "f0ead2-dde5b6-adc178-a98467-6c584c")!,
        .init(name: "Fiery Ocean",    hexSlug: "780000-c1121f-fdf0d5-003049-669bbc")!,
        .init(name: "Bold Berry",     hexSlug: "f9dbbd-ffa5ab-da627d-a53860-450920")!,
        .init(name: "Pastel Dream", hexSlug: "ffadad-ffd6a5-fdffb6-caffbf-9bf6ff")!,
        .init(name: "Olive Garden Feast", hexSlug: "606c38-283618-fefae0-dda15e-bc6c25")!,
        .init(name: "Nordic",       hexSlug: "d8e2dc-ffe5d9-ffcad4-f4acb7-9d8189")!,
        .init(name: "Ocean",        hexSlug: "03045e-023e8a-0077b6-0096c7-00b4d8")!,
        .init(name: "Neon",         hexSlug: "f72585-7209b7-3a0ca3-4361ee-4cc9f0")!,
        .init(name: "Berry",        hexSlug: "590d22-800f2f-a4133c-c9184a-ff4d6d")!,
        .init(name: "Mint",         hexSlug: "007f5f-2b9348-55a630-80b918-aacc00")!,
        .init(name: "Dusty Rose",   hexSlug: "e8c5d0-c9a0b8-a07891-795063-4a2938")!,
        .init(name: "Slate",        hexSlug: "22223b-4a4e69-9a8c98-c9b8c5-f2e9e4")!,
        .init(name: "Citrus",       hexSlug: "f94144-f3722c-f8961e-f9c74f-90be6d")!,
        .init(name: "Lavender",     hexSlug: "e0aaff-c77dff-9d4edd-7b2d8b-3c096c")!,
        .init(name: "Warm Sand",    hexSlug: "ccd5ae-e9edc9-fefae0-faedcd-d4a373")!,
        .init(name: "Twilight",     hexSlug: "10002b-240046-3c096c-5a189a-7b2fbe")!,
        .init(name: "Coral",               hexSlug: "ffb5a7-fcd5ce-f8edeb-f9dcc4-fec89a")!,
        .init(name: "Enchanted Forest",    hexSlug: "134611-3e8914-3da35d-96e072-e8fccf")!,
        .init(name: "Turquoise Harmony",   hexSlug: "05668d-028090-00a896-02c39a-f0f3bd")!,
        .init(name: "Golden Meadow",       hexSlug: "fb6107-f3de2c-7cb518-5c8001-fbb02d")!,
        .init(name: "Mossy Woods",         hexSlug: "0a100d-b9baa3-d6d5c9-a22c29-902923")!,
        .init(name: "Soft Lavender",       hexSlug: "9381ff-b8b8ff-f8f7ff-ffeedd-ffd8be")!,
        .init(name: "Raspberry Sorbet",    hexSlug: "f2ccc3-e78f8e-ffe6e8-acd8aa-f48498")!,
        .init(name: "Sunrise Glow",        hexSlug: "233d4d-fe7f2d-fcca46-a1c181-619b8a")!,
        .init(name: "Blood And Sand",      hexSlug: "020213-800020-7b1e2b-daa520-dba622")!,
        .init(name: "Groovy 60s",          hexSlug: "17181c-16215b-62f9d1-e6ff2b-efefef")!,
        .init(name: "Vibrant Color Blast", hexSlug: "006ba6-0496ff-ffbc42-d81159-8f2d56")!,
        .init(name: "Vibrant Fusion",      hexSlug: "d00000-ffba08-3f88c5-032b43-136f63")!,
        .init(name: "Peachy Sunrise",      hexSlug: "ffffff-84dcc6-a5ffd6-ffa69e-ff686b")!,
        .init(name: "Sunshine Bliss",      hexSlug: "06aed5-086788-f0c808-fff1d0-dd1c1a")!,
        .init(name: "Vibrant Shades",      hexSlug: "660000-990033-5f021f-8c001a-ff9000")!,
        .init(name: "Rustic Earth",        hexSlug: "515a47-d7be82-7a4419-755c1b-400406")!,
        .init(name: "Cozy Cabin",          hexSlug: "7a7265-c0b7b1-8e6e53-c69c72-433e3f")!,
        .init(name: "Deep Navy",           hexSlug: "21295c-1b3b6f-065a82-1c7293-9eb3c2")!,
        .init(name: "Monochrome Harmony",  hexSlug: "cfdbd5-e8eddf-f5cb5c-242423-333533")!,
        .init(name: "Antique Rose",        hexSlug: "cc8b86-f9eae1-7d4f50-d1be9c-aa998f")!,
        .init(name: "Mauve Serenity",      hexSlug: "565264-706677-a6808c-ccb7ae-d6cfcb")!,
        .init(name: "Sunny Delight",       hexSlug: "156064-00c49a-f8e16c-ffc2b4-fb8f67")!,
        .init(name: "Tropical Bliss",      hexSlug: "227c9d-17c3b2-ffcb77-fef9ef-fe6d73")!,
        .init(name: "Mystic Midnight",     hexSlug: "dce0d9-31081f-6b0f1a-595959-808f85")!,
        .init(name: "Forest Adventure",    hexSlug: "3c91e6-342e37-a2d729-fafffd-fa824c")!,
        .init(name: "Tropical Spice",      hexSlug: "ffc15e-f7b05b-f7934c-cc5803-1f1300")!,
        .init(name: "Golden Harvest",      hexSlug: "ffe169-edc531-c9a227-926c15-76520e")!,
        .init(name: "Bright Green",        hexSlug: "004b23-007200-38b000-70e000-ccff33")!,
        .init(name: "Sunset Gradient",     hexSlug: "ffedd8-e7bc91-bc8a5f-8b5e34-583101")!,
        .init(name: "Red Gradient",        hexSlug: "641220-85182a-a71e34-bd1f36-e01e37")!,
        .init(name: "Vivid Nightfall",     hexSlug: "10002b-3c096c-7b2cbf-9d4edd-e0aaff")!,
        .init(name: "Fiery Sunset",        hexSlug: "03071e-6a040f-d00000-e85d04-faa307")!,
        .init(name: "Orange Sunset",       hexSlug: "ff7b00-ff9500-ffaa00-ffc300-ffd000")!,
    ] as [AppPalettePreset]).sorted { $0.paletteName < $1.paletteName }

    // MARK: Named statics — for ergonomic subset catalogs
    //
    // Usage:
    //   AppPaletteStore(catalog: [.retro, .ocean, .midnightSky, .candyPop])

    static let retro               = builtIn.first { $0.paletteName == "Retro" }!
    static let sunsetGlow          = builtIn.first { $0.paletteName == "Sunset Glow" }!
    static let natureHarmony       = builtIn.first { $0.paletteName == "Nature Harmony" }!
    static let autumnGlow          = builtIn.first { $0.paletteName == "Autumn Glow" }!
    static let sunsetBliss         = builtIn.first { $0.paletteName == "Sunset Bliss" }!
    static let mysticWaters        = builtIn.first { $0.paletteName == "Mystic Waters" }!
    static let darkRomance         = builtIn.first { $0.paletteName == "Dark Romance" }!
    static let oceanicSunburst     = builtIn.first { $0.paletteName == "Oceanic Sunburst" }!
    static let rusticCharm         = builtIn.first { $0.paletteName == "Rustic Charm" }!
    static let summerOceanBreeze   = builtIn.first { $0.paletteName == "Summer Ocean Breeze" }!
    static let softPinkDelight     = builtIn.first { $0.paletteName == "Soft Pink Delight" }!
    static let fieryPalette        = builtIn.first { $0.paletteName == "Fiery Palette" }!
    static let neutralHarmonyBliss = builtIn.first { $0.paletteName == "Neutral Harmony Bliss" }!
    static let sweetSummerMelody   = builtIn.first { $0.paletteName == "Sweet Summer Melody" }!
    static let warmRustic          = builtIn.first { $0.paletteName == "Warm Rustic" }!
    static let coolCoastal         = builtIn.first { $0.paletteName == "Cool Coastal" }!
    static let deepSea             = builtIn.first { $0.paletteName == "Deep Sea" }!
    static let candyPop            = builtIn.first { $0.paletteName == "Candy Pop" }!
    static let goldenGlow          = builtIn.first { $0.paletteName == "Golden Glow" }!
    static let autumnHarvest       = builtIn.first { $0.paletteName == "Autumn Harvest" }!
    static let blackAndGold        = builtIn.first { $0.paletteName == "Black And Gold" }!
    static let midnightSky         = builtIn.first { $0.paletteName == "Midnight Sky" }!
    static let earthyTones         = builtIn.first { $0.paletteName == "Earthy Tones" }!
    static let fieryOcean          = builtIn.first { $0.paletteName == "Fiery Ocean" }!
    static let boldBerry           = builtIn.first { $0.paletteName == "Bold Berry" }!
    static let pastelDream         = builtIn.first { $0.paletteName == "Pastel Dream" }!
    static let oliveGardenFeast    = builtIn.first { $0.paletteName == "Olive Garden Feast" }!
    static let nordic              = builtIn.first { $0.paletteName == "Nordic" }!
    static let ocean               = builtIn.first { $0.paletteName == "Ocean" }!
    static let neon                = builtIn.first { $0.paletteName == "Neon" }!
    static let berry               = builtIn.first { $0.paletteName == "Berry" }!
    static let mint                = builtIn.first { $0.paletteName == "Mint" }!
    static let dustyRose           = builtIn.first { $0.paletteName == "Dusty Rose" }!
    static let slate               = builtIn.first { $0.paletteName == "Slate" }!
    static let citrus              = builtIn.first { $0.paletteName == "Citrus" }!
    static let lavender            = builtIn.first { $0.paletteName == "Lavender" }!
    static let warmSand            = builtIn.first { $0.paletteName == "Warm Sand" }!
    static let twilight            = builtIn.first { $0.paletteName == "Twilight" }!
    static let coral               = builtIn.first { $0.paletteName == "Coral" }!
    static let enchantedForest     = builtIn.first { $0.paletteName == "Enchanted Forest" }!
    static let turquoiseHarmony    = builtIn.first { $0.paletteName == "Turquoise Harmony" }!
    static let goldenMeadow        = builtIn.first { $0.paletteName == "Golden Meadow" }!
    static let mossyWoods          = builtIn.first { $0.paletteName == "Mossy Woods" }!
    static let softLavender        = builtIn.first { $0.paletteName == "Soft Lavender" }!
    static let raspberrySorbet     = builtIn.first { $0.paletteName == "Raspberry Sorbet" }!
    static let sunriseGlow         = builtIn.first { $0.paletteName == "Sunrise Glow" }!
    static let bloodAndSand        = builtIn.first { $0.paletteName == "Blood And Sand" }!
    static let groovy60s           = builtIn.first { $0.paletteName == "Groovy 60s" }!
    static let vibrantColorBlast   = builtIn.first { $0.paletteName == "Vibrant Color Blast" }!
    static let vibrantFusion       = builtIn.first { $0.paletteName == "Vibrant Fusion" }!
    static let peachySunrise       = builtIn.first { $0.paletteName == "Peachy Sunrise" }!
    static let sunshineBliss       = builtIn.first { $0.paletteName == "Sunshine Bliss" }!
    static let vibrantShades       = builtIn.first { $0.paletteName == "Vibrant Shades" }!
    static let rusticEarth         = builtIn.first { $0.paletteName == "Rustic Earth" }!
    static let cozyCabin           = builtIn.first { $0.paletteName == "Cozy Cabin" }!
    static let deepNavy            = builtIn.first { $0.paletteName == "Deep Navy" }!
    static let monochromeHarmony   = builtIn.first { $0.paletteName == "Monochrome Harmony" }!
    static let antiqueRose         = builtIn.first { $0.paletteName == "Antique Rose" }!
    static let mauveSerenity       = builtIn.first { $0.paletteName == "Mauve Serenity" }!
    static let sunnyDelight        = builtIn.first { $0.paletteName == "Sunny Delight" }!
    static let tropicalBliss       = builtIn.first { $0.paletteName == "Tropical Bliss" }!
    static let mysticMidnight      = builtIn.first { $0.paletteName == "Mystic Midnight" }!
    static let forestAdventure     = builtIn.first { $0.paletteName == "Forest Adventure" }!
    static let tropicalSpice       = builtIn.first { $0.paletteName == "Tropical Spice" }!
    static let goldenHarvest       = builtIn.first { $0.paletteName == "Golden Harvest" }!
    static let brightGreen         = builtIn.first { $0.paletteName == "Bright Green" }!
    static let sunsetGradient      = builtIn.first { $0.paletteName == "Sunset Gradient" }!
    static let redGradient         = builtIn.first { $0.paletteName == "Red Gradient" }!
    static let vividNightfall      = builtIn.first { $0.paletteName == "Vivid Nightfall" }!
    static let fierySunset         = builtIn.first { $0.paletteName == "Fiery Sunset" }!
    static let orangeSunset        = builtIn.first { $0.paletteName == "Orange Sunset" }!
}
