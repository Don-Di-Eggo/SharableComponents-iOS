import Foundation

/// Generates evocative, color-derived names for palettes.
///
/// A name is built from the palette's dominant hue (an evocative noun) optionally
/// paired with a mood-flavored adjective. Selection is deterministic — seeded by the
/// palette's color ids — so a given palette always yields the same name, while
/// neighbouring palettes vary.
enum PaletteNaming {

    static func name(for palette: CategorizedPalette) -> String {
        let colors = palette.colors
        guard !colors.isEmpty else { return "Palette" }

        // Dominant color = the most saturated/strongest member (drives the noun).
        let dominant = colors.max { chroma($0) < chroma($1) } ?? colors[0]
        let hue = PaletteHue(dominant)

        let seed = palette.colorIDs.reduce(0) { $0 &* 31 &+ $1 }
        let nouns = nounBank[hue] ?? ["Hue"]
        let noun = nouns[abs(seed) % nouns.count]

        // Mood adjective when the palette carries one; else a neutral texture word.
        let adjectives: [String]
        if let mood = palette.moods.sorted(by: { $0.rawValue < $1.rawValue }).first {
            adjectives = adjectiveBank[mood] ?? neutralAdjectives
        } else {
            adjectives = neutralAdjectives
        }
        let adjective = adjectives[abs(seed / 7) % adjectives.count]

        return "\(adjective) \(noun)"
    }

    private static func chroma(_ c: ProcessColor) -> Int { max(c.c, c.m, c.y) }

    // MARK: Hue → evocative nouns

    private static let nounBank: [PaletteHue: [String]] = [
        .red:    ["Ember", "Crimson", "Garnet", "Scarlet", "Cinder", "Flame", "Ruby", "Vermilion"],
        .pink:   ["Blush", "Rose", "Petal", "Coral", "Fawn", "Camellia", "Quartz", "Peony"],
        .orange:["Amber", "Saffron", "Marigold", "Ginger", "Tangerine", "Copper", "Persimmon", "Sienna"],
        .yellow:["Gilt", "Honey", "Daffodil", "Sunlit", "Citrine", "Buttercup", "Lemon", "Chamomile"],
        .green: ["Fern", "Pine", "Moss", "Verdant", "Jade", "Clover", "Basil", "Meadow"],
        .blue:  ["Cobalt", "Azure", "Marine", "Sapphire", "Tide", "Indigo", "Harbor", "Slate"],
        .purple:["Plum", "Violet", "Iris", "Orchid", "Amethyst", "Mauve", "Thistle", "Wisteria"],
        .brown: ["Umber", "Walnut", "Chestnut", "Clay", "Cocoa", "Hazel", "Bark", "Loam"],
        .gray:  ["Ash", "Pewter", "Stone", "Slate", "Mist", "Graphite", "Flint", "Smoke"],
    ]

    // MARK: Mood → flavor adjectives

    private static let neutralAdjectives = ["Quiet", "Still", "Plain", "Open"]

    private static let adjectiveBank: [PaletteMood: [String]] = [
        .powerful:    ["Fierce", "Bold", "Mighty", "Roaring"],
        .rich:        ["Lavish", "Opulent", "Deep", "Velvet"],
        .romantic:    ["Tender", "Wistful", "Sweet", "Dreaming"],
        .vital:       ["Living", "Vivid", "Pulsing", "Bright"],
        .earthy:      ["Rooted", "Rustic", "Wild", "Raw"],
        .friendly:    ["Sunny", "Warm", "Easy", "Cheerful"],
        .soft:        ["Hushed", "Gentle", "Tender", "Downy"],
        .welcoming:   ["Glowing", "Cozy", "Open", "Inviting"],
        .moving:      ["Restless", "Drifting", "Flowing", "Surging"],
        .elegant:     ["Refined", "Graceful", "Polished", "Stately"],
        .trendy:      ["Bright", "Sharp", "Modern", "Electric"],
        .fresh:       ["Crisp", "Dewy", "Cool", "Clean"],
        .traditional: ["Heritage", "Timeless", "Old-World", "Classic"],
        .refreshing:  ["Cooling", "Breezy", "Sparkling", "Clear"],
        .tropical:    ["Sunlit", "Lush", "Island", "Vivid"],
        .classic:     ["Enduring", "Timeless", "Noble", "Poised"],
        .dependable:  ["Steady", "Solid", "True", "Grounded"],
        .calm:        ["Serene", "Tranquil", "Quiet", "Still"],
        .regal:       ["Royal", "Majestic", "Crowned", "Noble"],
        .magical:     ["Enchanted", "Mystic", "Dreaming", "Spellbound"],
        .nostalgic:   ["Faded", "Wistful", "Vintage", "Remembered"],
        .energetic:   ["Electric", "Charged", "Lively", "Kinetic"],
        .subdued:     ["Muted", "Hushed", "Dusky", "Soft"],
        .pure:        ["Clean", "Simple", "Clear", "Bright"],
        .graphic:     ["Striking", "Stark", "Bold", "Vivid"],
    ]
}
