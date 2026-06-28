import Foundation
import SwiftUI
import Testing
@testable import SharableComponents

@MainActor
struct CategorizedAppPaletteSelectionTests {

    // MARK: - ProcessColor chart

    @Test("Chart has 107 colors with unique ids 1...107")
    func chartIntegrity() {
        #expect(ProcessColor.all.count == 107)
        let ids = ProcessColor.all.map(\.id)
        #expect(Set(ids).count == 107)
        #expect(ids.min() == 1)
        #expect(ids.max() == 107)
    }

    @Test("color(id:) resolves in range and is nil outside")
    func colorLookupBounds() {
        #expect(ProcessColor.color(id: 1) != nil)
        #expect(ProcessColor.color(id: 107) != nil)
        #expect(ProcessColor.color(id: 0) == nil)
        #expect(ProcessColor.color(id: 108) == nil)
    }

    @Test("White (107) and black (106) sit at the luminance extremes")
    func luminanceExtremes() {
        let white = ProcessColor.color(id: 107)!
        let black = ProcessColor.color(id: 106)!
        #expect(white.luminance > 0.99)
        #expect(black.luminance < 0.01)
    }

    @Test("CMYK→RGB: pure red (id 4) converts correctly")
    func cmykConversion() {
        let red = ProcessColor.color(id: 4)!   // C0 M100 Y100 K0
        let (r, g, b) = red.rgb
        #expect(r == 1.0)
        #expect(g == 0.0)
        #expect(b == 0.0)
    }

    // MARK: - Library integrity

    @Test("Library has 919 palettes, each resolving to three colors")
    func libraryIntegrity() {
        #expect(CategorizedPalette.all.count == 919)
        for p in CategorizedPalette.all {
            #expect(p.colorIDs.count == 3)
            #expect(p.colors.count == 3, "Palette \(p.id) has an unresolvable color id")
        }
    }

    @Test("No three-color palette uses Clash or Complementary")
    func noEmptySchemes() {
        let schemes = Set(CategorizedPalette.all.compactMap(\.scheme))
        #expect(!schemes.contains(.clash))
        #expect(!schemes.contains(.complementary))
    }

    @Test("Professional mood was excluded")
    func professionalExcluded() {
        #expect(!PaletteMood.allCases.contains { $0.rawValue == "professional" })
        #expect(CategorizedPalette.all.allSatisfy { !$0.moods.contains { $0.rawValue == "professional" } })
    }

    // MARK: - Filtering semantics

    @Test("Hue / aspect / scheme are AND-combined")
    func andFacets() {
        let p = CategorizedPalette(id: "t", colorIDs: [4, 36, 68], moods: [.powerful], scheme: .primary)
        // [4,36,68] = red, yellow, blue → primary scheme
        #expect(p.matches(scheme: .primary))
        #expect(!p.matches(scheme: .analogous))
        #expect(p.matches(hue: .red, scheme: .primary))
        // A hue the palette lacks should fail even with a matching scheme.
        #expect(!p.matches(hue: .green, scheme: .primary))
    }

    @Test("Moods are OR-combined")
    func orMoods() {
        let p = CategorizedPalette(id: "t", colorIDs: [4, 36, 68], moods: [.powerful], scheme: .primary)
        #expect(p.matches(moods: [.powerful]))
        #expect(p.matches(moods: [.powerful, .rich]))   // OR: matches because it has powerful
        #expect(!p.matches(moods: [.rich]))             // has neither → no match
        #expect(p.matches(moods: []))                   // empty constraint ignored
    }

    @Test("Derived hues and aspects are non-empty")
    func derivedFacets() {
        let p = CategorizedPalette(id: "t", colorIDs: [4, 36, 68], moods: [.powerful], scheme: .primary)
        #expect(!p.hues.isEmpty)
        #expect(!p.aspects.isEmpty)
        #expect(p.hues.contains(.red))
    }

    // MARK: - Stable names

    @Test("Every palette has a frozen, non-empty name")
    func frozenNames() {
        for p in CategorizedPalette.all {
            #expect(PaletteNames.byID[p.id] != nil, "Missing frozen name for \(p.id)")
            #expect(!p.name.isEmpty)
            #expect(p.name == PaletteNames.byID[p.id])
        }
    }

    @Test("Frozen names are unique")
    func uniqueNames() {
        let names = CategorizedPalette.all.map(\.name)
        #expect(Set(names).count == names.count)
    }

    // MARK: - Representative colors

    @Test("dominantContrastColor is black or white")
    func contrastColor() {
        for p in CategorizedPalette.all.prefix(50) {
            let c = p.dominantContrastColor
            #expect(c == .black || c == .white)
        }
    }

    // MARK: - Mood synonym labels

    @Test("Mood labels are displayed as synonyms")
    func moodSynonyms() {
        #expect(PaletteMood.powerful.label == "Strong")
        #expect(PaletteMood.rich.label == "Opulent")
        #expect(PaletteMood.graphic.label == "Bold")
        // rawValue (internal id) stays the source word
        #expect(PaletteMood.powerful.rawValue == "powerful")
    }

    // MARK: - Convenience filters

    @Test("palettes(mood:) returns only that mood")
    func moodConvenience() {
        let tropical = CategorizedPalette.palettes(mood: .tropical)
        #expect(!tropical.isEmpty)
        #expect(tropical.allSatisfy { $0.moods.contains(.tropical) })
    }
}
