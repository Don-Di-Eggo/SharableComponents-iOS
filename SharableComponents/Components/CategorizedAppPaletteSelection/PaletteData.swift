import Foundation

/// Transcribed three-color palettes from the source book, organized by mood.
///
/// Each palette records its **scheme** (the book's swatch grouping) and the three
/// **ProcessColor chart numbers** printed beneath the swatch, in book order. Hue and
/// aspect facets are derived from the colors, so they are not stored here.
///
/// Only three-color palettes are transcribed; the book's one- and two-color sets are
/// intentionally omitted.
enum PaletteData {

    /// All moods concatenated. Extend as each mood is transcribed.
    static var all: [CategorizedPalette] {
        powerful + rich + romantic + vital + earthy + friendly + soft
      + welcoming + moving + elegant + trendy + fresh + traditional
      + refreshing + tropical + classic + dependable + calm + regal
      + magical + nostalgic + energetic + subdued
      + pure + graphic
    }

    /// Compact builder: assigns a stable id (`<mood>-<scheme>-<n>`) per palette.
    private static func make(
        _ mood: PaletteMood,
        _ scheme: PaletteScheme,
        _ sets: [[Int]]
    ) -> [CategorizedPalette] {
        sets.enumerated().map { index, ids in
            CategorizedPalette(
                id: "\(mood.rawValue)-\(scheme.rawValue.replacingOccurrences(of: " ", with: "").lowercased())-\(index + 1)",
                colorIDs: ids,
                moods: [mood],
                scheme: scheme
            )
        }
    }

    /// Builder for palettes whose structural scheme isn't determinable from the source.
    private static func makeMixed(
        _ mood: PaletteMood,
        _ sets: [[Int]]
    ) -> [CategorizedPalette] {
        sets.enumerated().map { index, ids in
            CategorizedPalette(
                id: "\(mood.rawValue)-mixed-\(index + 1)",
                colorIDs: ids,
                moods: [mood],
                scheme: nil
            )
        }
    }

    // MARK: - Powerful (pp. 50–53)

    static let powerful: [CategorizedPalette] =
        make(.powerful, .monochromatic, [
            [7, 6, 4], [6, 2, 4], [1, 3, 4], [2, 7, 4],
        ])
      + make(.powerful, .primary, [
            [68, 36, 4], [66, 34, 2], [70, 38, 6], [67, 34, 4],
        ])
      + make(.powerful, .analogous, [
            [84, 92, 4], [84, 94, 4], [87, 93, 4], [86, 94, 3],
            [92, 4, 12], [92, 5, 12], [95, 6, 12], [94, 2, 14],
            [4, 12, 20], [3, 13, 20], [6, 16, 20], [7, 11, 22],
        ])
      + make(.powerful, .splitComplementary, [
            [44, 4, 60], [41, 4, 62], [47, 4, 63], [46, 2, 60],
            [1, 44, 60], [7, 45, 59], [2, 44, 57], [5, 44, 61],
            [57, 44, 6], [61, 46, 4], [58, 41, 1], [63, 42, 6],
        ])
      + make(.powerful, .neutral, [
            [98, 100, 4], [101, 4, 105], [4, 98, 104], [97, 102, 4],
        ])

    // MARK: - Rich (pp. 54–57)

    static let rich: [CategorizedPalette] =
        make(.rich, .monochromatic, [
            [3, 5, 2], [8, 5, 1], [6, 4, 3], [6, 8, 2],
        ])
      + make(.rich, .primary, [
            [33, 1, 64], [34, 2, 66], [33, 2, 67], [35, 3, 65],
        ])
      + make(.rich, .analogous, [
            [81, 89, 1], [82, 91, 2], [84, 90, 3], [88, 92, 1],
            [89, 1, 9], [90, 2, 11], [94, 2, 10], [3, 95, 10],
            [1, 9, 17], [2, 11, 17], [3, 10, 19], [1, 19, 9],
        ])
      + make(.rich, .splitComplementary, [
            [57, 1, 41], [58, 1, 42], [62, 1, 46], [64, 1, 45],
            [61, 2, 42], [58, 2, 43], [60, 3, 41], [63, 3, 45],
            [1, 41, 57], [2, 46, 63], [1, 42, 59], [3, 45, 62],
        ])
      + make(.rich, .neutral, [
            [98, 100, 1], [101, 2, 105], [1, 98, 104], [97, 102, 3],
        ])

    // MARK: - Romantic (pp. 58–61)

    static let romantic: [CategorizedPalette] =
        make(.romantic, .monochromatic, [
            [3, 8, 6], [8, 1, 6], [1, 3, 6], [1, 8, 6],
        ])
      + make(.romantic, .primary, [
            [70, 38, 5], [67, 37, 7], [72, 40, 8], [70, 39, 6],
        ])
      + make(.romantic, .analogous, [
            [86, 94, 6], [87, 95, 7], [87, 96, 8], [87, 94, 6],
            [94, 6, 15], [95, 7, 14], [93, 7, 16], [96, 5, 15],
            [6, 14, 22], [5, 16, 23], [7, 16, 22], [8, 12, 23],
        ])
      + make(.romantic, .splitComplementary, [
            [46, 6, 62], [45, 6, 63], [47, 7, 63], [46, 3, 64],
            [44, 8, 61], [47, 7, 59], [43, 6, 57], [47, 6, 60],
            [43, 64, 5], [47, 64, 7], [44, 63, 7], [48, 62, 8],
        ])
      + make(.romantic, .neutral, [
            [97, 98, 8], [100, 7, 99], [5, 98, 100], [99, 97, 6],
        ])

    // MARK: - Vital (pp. 62–65)

    static let vital: [CategorizedPalette] =
        make(.vital, .monochromatic, [
            [9, 15, 12], [14, 10, 12], [9, 11, 12], [10, 16, 12],
        ])
      + make(.vital, .tertiary, [
            [76, 44, 12], [73, 42, 10], [78, 46, 14], [79, 42, 12],
        ])
      + make(.vital, .analogous, [
            [92, 4, 12], [90, 6, 13], [93, 5, 12], [94, 5, 11],
            [4, 12, 20], [4, 15, 20], [7, 13, 20], [8, 10, 22],
            [12, 20, 28], [11, 23, 28], [15, 24, 28], [14, 18, 32],
        ])
      + make(.vital, .splitComplementary, [
            [52, 12, 68], [50, 12, 70], [54, 12, 71], [55, 10, 68],
            [9, 68, 52], [13, 70, 51], [11, 68, 50], [14, 68, 55],
            [65, 52, 5], [70, 56, 12], [66, 51, 11], [69, 54, 12],
        ])
      + make(.vital, .neutral, [
            [98, 100, 12], [101, 12, 106], [12, 98, 104], [98, 102, 12],
        ])

    // MARK: - Earthy (pp. 66–69)

    static let earthy: [CategorizedPalette] =
        make(.earthy, .monochromatic, [
            [9, 13, 10], [15, 11, 10], [9, 11, 14], [9, 14, 10],
        ])
      + make(.earthy, .tertiary, [
            [74, 10, 42], [9, 74, 41], [11, 43, 75], [43, 73, 11],
        ])
      + make(.earthy, .analogous, [
            [91, 3, 10], [90, 2, 11], [89, 3, 10], [91, 1, 13],
            [2, 18, 10], [1, 10, 21], [2, 11, 19], [3, 9, 19],
            [10, 20, 27], [11, 19, 26], [9, 21, 25], [13, 18, 28],
        ])
      + make(.earthy, .splitComplementary, [
            [10, 50, 66], [9, 51, 67], [11, 52, 67], [10, 49, 68],
            [50, 67, 10], [51, 67, 11], [49, 11, 66], [50, 68, 10],
            [70, 10, 51], [69, 11, 50], [68, 11, 53], [10, 54, 58],
        ])
      + make(.earthy, .neutral, [
            [97, 100, 9], [101, 98, 10], [100, 11, 102], [98, 10, 97],
        ])

    // MARK: - Friendly (pp. 70–73)

    static let friendly: [CategorizedPalette] =
        make(.friendly, .monochromatic, [
            [19, 22, 20], [23, 18, 20], [17, 19, 20], [18, 23, 20],
        ])
      + make(.friendly, .secondary, [
            [84, 20, 52], [81, 17, 50], [86, 21, 53], [84, 18, 52],
        ])
      + make(.friendly, .analogous, [
            [4, 12, 20], [4, 14, 20], [7, 16, 20], [6, 15, 18],
            [12, 20, 27], [12, 22, 26], [14, 24, 26], [15, 18, 20],
            [20, 28, 36], [19, 29, 36], [22, 32, 36], [21, 27, 38],
        ])
      + make(.friendly, .splitComplementary, [
            [76, 20, 60], [74, 20, 62], [78, 20, 63], [79, 19, 60],
            [18, 76, 60], [22, 79, 58], [19, 76, 59], [21, 76, 61],
            [58, 76, 22], [61, 78, 20], [59, 75, 18], [62, 78, 21],
        ])
      + make(.friendly, .neutral, [
            [98, 100, 20], [101, 20, 106], [20, 98, 104], [97, 102, 20],
        ])

    // MARK: - Soft (pp. 74–77)

    static let soft: [CategorizedPalette] =
        make(.soft, .monochromatic, [
            [19, 24, 22], [23, 18, 22], [17, 19, 22], [18, 20, 22],
        ])
      + make(.soft, .secondary, [
            [54, 22, 86], [51, 23, 87], [55, 23, 87], [56, 22, 85],
        ])
      + make(.soft, .analogous, [
            [6, 14, 22], [7, 16, 22], [8, 14, 22], [7, 13, 22],
            [14, 22, 30], [15, 24, 29], [16, 23, 30], [15, 20, 31],
            [22, 30, 38], [23, 29, 38], [24, 30, 39], [23, 27, 39],
        ])
      + make(.soft, .splitComplementary, [
            [62, 22, 78], [61, 23, 79], [63, 22, 80], [64, 23, 78],
            [59, 19, 78], [63, 23, 76], [59, 22, 77], [61, 22, 79],
            [58, 80, 23], [62, 78, 22], [59, 76, 20], [62, 78, 23],
        ])
      + make(.soft, .neutral, [
            [98, 99, 22], [101, 22, 105], [22, 98, 101], [99, 98, 22],
        ])

    // MARK: - Welcoming (pp. 78–81)

    static let welcoming: [CategorizedPalette] =
        make(.welcoming, .monochromatic, [
            [26, 29, 28], [29, 27, 28], [25, 27, 28], [27, 31, 28],
        ])
      + make(.welcoming, .tertiary, [
            [92, 28, 60], [90, 26, 58], [94, 30, 62], [95, 27, 64],
        ])
      + make(.welcoming, .analogous, [
            [10, 20, 28], [12, 22, 28], [14, 22, 28], [16, 22, 27],
            [20, 28, 36], [19, 29, 37], [22, 29, 36], [23, 26, 38],
            [28, 36, 44], [26, 38, 44], [30, 39, 44], [31, 35, 47],
        ])
      + make(.welcoming, .splitComplementary, [
            [68, 28, 84], [66, 28, 87], [70, 28, 86], [69, 27, 84],
            [26, 68, 84], [29, 69, 83], [27, 68, 81], [30, 68, 87],
            [82, 69, 29], [86, 70, 28], [85, 78, 27], [87, 70, 28],
        ])
      + make(.welcoming, .neutral, [
            [98, 100, 28], [101, 28, 106], [28, 98, 104], [97, 102, 28],
        ])

    // MARK: - Moving (pp. 82–85)

    static let moving: [CategorizedPalette] =
        make(.moving, .monochromatic, [
            [34, 37, 39], [38, 40, 36], [35, 34, 36], [34, 40, 36],
        ])
      + make(.moving, .primary, [
            [4, 66, 36], [2, 66, 34], [6, 70, 38], [5, 65, 36],
        ])
      + make(.moving, .analogous, [
            [20, 28, 36], [20, 29, 36], [22, 31, 36], [23, 27, 35],
            [28, 36, 44], [28, 37, 44], [30, 38, 44], [31, 34, 46],
            [36, 44, 52], [35, 45, 52], [39, 46, 52], [38, 42, 53],
        ])
      + make(.moving, .splitComplementary, [
            [76, 36, 84], [75, 36, 94], [78, 36, 95], [77, 35, 92],
            [34, 76, 84], [38, 77, 91], [39, 76, 90], [38, 76, 94],
            [91, 76, 38], [94, 78, 36], [90, 75, 34], [94, 79, 40],
        ])
      + make(.moving, .neutral, [
            [98, 100, 36], [101, 36, 102], [36, 98, 104], [97, 102, 36],
        ])

    // MARK: - Elegant (pp. 86–89)

    static let elegant: [CategorizedPalette] =
        make(.elegant, .monochromatic, [
            [40, 37, 39], [40, 35, 39], [38, 34, 39], [35, 38, 39],
        ])
      + make(.elegant, .primary, [
            [71, 39, 7], [70, 38, 6], [72, 40, 8], [72, 39, 8],
        ])
      + make(.elegant, .analogous, [
            [23, 31, 39], [22, 32, 39], [24, 32, 40], [24, 30, 38],
            [31, 39, 46], [30, 40, 47], [32, 40, 47], [32, 38, 48],
            [39, 47, 55], [38, 48, 54], [40, 48, 56], [40, 46, 55],
        ])
      + make(.elegant, .splitComplementary, [
            [79, 39, 95], [78, 39, 93], [80, 39, 96], [80, 38, 95],
            [78, 39, 95], [80, 40, 94], [75, 39, 93], [80, 37, 94],
            [77, 96, 40], [80, 96, 39], [78, 93, 38], [80, 94, 39],
        ])
      + make(.elegant, .neutral, [
            [98, 97, 39], [101, 39, 100], [39, 101, 97], [98, 99, 39],
        ])

    // MARK: - Trendy (pp. 90–93)

    static let trendy: [CategorizedPalette] =
        make(.trendy, .monochromatic, [
            [42, 46, 44], [47, 41, 44], [43, 41, 44], [42, 46, 44],
        ])
      + make(.trendy, .tertiary, [
            [76, 12, 44], [74, 10, 43], [78, 14, 46], [79, 9, 44],
        ])
      + make(.trendy, .analogous, [
            [28, 36, 44], [28, 39, 44], [25, 39, 44], [25, 37, 44],
            [36, 44, 52], [36, 45, 52], [39, 47, 52], [40, 43, 54],
            [44, 52, 60], [41, 53, 60], [45, 55, 60], [47, 50, 60],
        ])
      + make(.trendy, .splitComplementary, [
            [84, 44, 4], [82, 44, 6], [86, 44, 7], [87, 42, 4],
            [43, 84, 4], [45, 86, 2], [42, 84, 1], [48, 84, 6],
            [1, 84, 45], [6, 86, 44], [2, 82, 42], [8, 87, 44],
        ])
      + make(.trendy, .neutral, [
            [98, 100, 44], [101, 44, 102], [44, 98, 104], [41, 102, 104],
        ])

    // MARK: - Fresh (pp. 94–97)

    static let fresh: [CategorizedPalette] =
        make(.fresh, .monochromatic, [
            [50, 54, 52], [55, 51, 52], [49, 51, 52], [56, 53, 52],
        ])
      + make(.fresh, .secondary, [
            [20, 52, 84], [18, 50, 82], [21, 53, 85], [22, 49, 87],
        ])
      + make(.fresh, .analogous, [
            [36, 44, 52], [36, 45, 52], [38, 45, 52], [39, 46, 51],
            [44, 52, 60], [44, 54, 60], [46, 52, 60], [46, 50, 62],
            [52, 60, 68], [51, 62, 68], [54, 62, 68], [55, 58, 70],
        ])
      + make(.fresh, .splitComplementary, [
            [92, 52, 12], [91, 52, 14], [95, 52, 7], [94, 50, 12],
            [52, 92, 12], [55, 95, 11], [51, 92, 10], [54, 92, 14],
            [10, 92, 55], [6, 94, 52], [1, 90, 50], [5, 93, 52],
        ])
      + make(.fresh, .neutral, [
            [98, 100, 52], [101, 52, 102], [52, 98, 104], [97, 102, 52],
        ])

    // MARK: - Traditional (pp. 98–101)

    static let traditional: [CategorizedPalette] =
        make(.traditional, .monochromatic, [
            [51, 54, 49], [55, 53, 49], [53, 51, 49], [54, 56, 49],
        ])
      + make(.traditional, .secondary, [
            [49, 17, 81], [50, 18, 86], [49, 19, 83], [49, 23, 84],
        ])
      + make(.traditional, .analogous, [
            [33, 41, 49], [34, 42, 49], [38, 43, 50], [34, 47, 48],
            [41, 49, 57], [42, 50, 58], [47, 49, 58], [48, 50, 63],
            [49, 57, 65], [50, 58, 66], [49, 59, 66], [49, 61, 71],
        ])
      + make(.traditional, .splitComplementary, [
            [9, 49, 89], [10, 50, 90], [13, 49, 91], [14, 51, 90],
            [14, 50, 95], [16, 49, 90], [15, 50, 89], [13, 51, 89],
            [9, 89, 50], [13, 90, 49], [15, 91, 50], [16, 94, 49],
        ])
      + make(.traditional, .neutral, [
            [98, 100, 49], [101, 49, 102], [49, 98, 104], [97, 98, 49],
        ])

    // MARK: - Refreshing (pp. 102–105)

    static let refreshing: [CategorizedPalette] =
        make(.refreshing, .monochromatic, [
            [59, 61, 60], [62, 57, 60], [58, 57, 60], [59, 63, 60],
        ])
      + make(.refreshing, .tertiary, [
            [60, 28, 92], [59, 27, 91], [61, 29, 93], [62, 27, 92],
        ])
      + make(.refreshing, .analogous, [
            [44, 52, 60], [44, 53, 60], [45, 54, 60], [46, 53, 59],
            [52, 60, 68], [52, 61, 68], [54, 61, 71], [54, 59, 69],
            [60, 68, 76], [59, 70, 76], [62, 71, 79], [62, 66, 78],
        ])
      + make(.refreshing, .splitComplementary, [
            [4, 60, 20], [3, 60, 28], [5, 60, 22], [6, 59, 20],
            [60, 4, 22], [61, 2, 22], [63, 7, 19], [62, 6, 23],
            [20, 52, 61], [22, 5, 60], [23, 3, 59], [19, 6, 60],
        ])
      + make(.refreshing, .neutral, [
            [98, 100, 60], [101, 60, 106], [60, 98, 104], [97, 102, 60],
        ])

    // MARK: - Tropical (pp. 106–109)

    static let tropical: [CategorizedPalette] =
        make(.tropical, .monochromatic, [
            [59, 64, 62], [63, 58, 62], [64, 63, 62], [58, 60, 62],
        ])
      + make(.tropical, .tertiary, [
            [62, 30, 94], [64, 29, 93], [63, 31, 95], [63, 32, 96],
        ])
      + make(.tropical, .analogous, [
            [46, 54, 62], [45, 55, 62], [48, 55, 64], [47, 53, 62],
            [54, 62, 70], [53, 63, 69], [56, 63, 72], [55, 61, 71],
            [62, 70, 78], [61, 71, 79], [64, 72, 80], [63, 69, 79],
        ])
      + make(.tropical, .splitComplementary, [
            [6, 62, 22], [5, 62, 23], [7, 62, 24], [8, 63, 22],
            [21, 62, 6], [20, 63, 7], [22, 64, 6], [24, 64, 8],
            [5, 22, 63], [8, 23, 62], [5, 21, 61], [6, 20, 64],
        ])
      + make(.tropical, .neutral, [
            [98, 100, 62], [101, 63, 105], [62, 98, 104], [97, 102, 61],
        ])

    // MARK: - Classic (pp. 110–113)

    static let classic: [CategorizedPalette] =
        make(.classic, .monochromatic, [
            [67, 70, 68], [71, 69, 68], [65, 67, 69], [66, 69, 68],
        ])
      + make(.classic, .primary, [
            [4, 36, 68], [2, 34, 66], [5, 37, 69], [6, 35, 68],
        ])
      + make(.classic, .analogous, [
            [52, 60, 68], [52, 61, 68], [54, 62, 68], [53, 62, 66],
            [60, 68, 76], [60, 69, 76], [62, 70, 76], [61, 67, 78],
            [68, 76, 84], [67, 77, 84], [71, 78, 84], [72, 75, 87],
        ])
      + make(.classic, .splitComplementary, [
            [12, 68, 28], [10, 68, 29], [14, 68, 29], [15, 67, 28],
            [66, 28, 12], [69, 29, 11], [67, 28, 10], [70, 28, 14],
            [10, 28, 69], [13, 29, 68], [11, 27, 67], [14, 30, 68],
        ])
      + make(.classic, .neutral, [
            [98, 100, 68], [101, 68, 106], [68, 98, 104], [97, 102, 68],
        ])

    // MARK: - Dependable (pp. 114–117)

    static let dependable: [CategorizedPalette] =
        make(.dependable, .monochromatic, [
            [67, 70, 65], [71, 68, 65], [72, 69, 66], [67, 72, 65],
        ])
      + make(.dependable, .primary, [
            [33, 1, 65], [34, 2, 66], [3, 35, 66], [34, 2, 67],
        ])
      + make(.dependable, .analogous, [
            [49, 57, 65], [50, 59, 65], [51, 61, 66], [50, 62, 67],
            [57, 66, 78], [58, 69, 76], [61, 67, 74], [63, 65, 78],
            [66, 75, 82], [65, 77, 83], [66, 76, 86], [65, 79, 84],
        ])
      + make(.dependable, .splitComplementary, [
            [10, 65, 26], [9, 66, 27], [11, 65, 26], [10, 66, 25],
            [14, 65, 26], [14, 65, 32], [15, 66, 31], [9, 65, 32],
            [10, 26, 65], [14, 26, 65], [9, 31, 66], [14, 31, 65],
        ])
      + make(.dependable, .neutral, [
            [98, 97, 65], [101, 66, 105], [67, 98, 104], [97, 102, 65],
        ])

    // MARK: - Calm (pp. 118–121)

    static let calm: [CategorizedPalette] =
        make(.calm, .monochromatic, [
            [67, 72, 70], [71, 65, 70], [67, 65, 72], [72, 68, 71],
        ])
      + make(.calm, .primary, [
            [6, 38, 70], [7, 39, 69], [8, 40, 71], [5, 37, 71],
        ])
      + make(.calm, .analogous, [
            [54, 62, 70], [53, 63, 71], [56, 63, 70], [55, 61, 72],
            [62, 70, 78], [64, 71, 78], [61, 70, 79], [64, 72, 80],
            [70, 78, 86], [69, 79, 88], [71, 78, 88], [70, 80, 87],
        ])
      + make(.calm, .splitComplementary, [
            [30, 70, 14], [31, 71, 15], [32, 72, 16], [29, 70, 13],
            [31, 71, 14], [29, 71, 15], [32, 72, 14], [30, 70, 14],
            [10, 28, 69], [15, 30, 70], [16, 29, 71], [11, 31, 72],
        ])
      + make(.calm, .neutral, [
            [97, 99, 71], [72, 97, 100], [100, 67, 97], [97, 68, 99],
        ])

    // MARK: - Regal (pp. 122–125)

    static let regal: [CategorizedPalette] =
        make(.regal, .monochromatic, [
            [74, 77, 76], [79, 75, 76], [77, 73, 79], [73, 80, 76],
        ])
      + make(.regal, .tertiary, [
            [12, 44, 76], [11, 43, 75], [12, 45, 78], [14, 75, 76],
        ])
      + make(.regal, .analogous, [
            [60, 68, 76], [60, 69, 76], [61, 69, 76], [62, 70, 75],
            [68, 76, 84], [68, 78, 84], [70, 79, 84], [72, 74, 86],
            [76, 84, 92], [74, 86, 92], [79, 87, 92], [80, 82, 95],
        ])
      + make(.regal, .splitComplementary, [
            [36, 75, 20], [35, 76, 21], [37, 76, 22], [39, 74, 20],
            [75, 36, 20], [78, 39, 19], [74, 36, 18], [85, 36, 21],
            [19, 36, 78], [22, 38, 76], [19, 34, 75], [21, 38, 76],
        ])
      + make(.regal, .neutral, [
            [98, 100, 76], [99, 76, 97], [76, 98, 101], [99, 98, 76],
        ])

    // MARK: - Magical (pp. 126–129)

    static let magical: [CategorizedPalette] =
        make(.magical, .monochromatic, [
            [81, 87, 84], [86, 82, 84], [87, 86, 84], [82, 88, 84],
        ])
      + make(.magical, .secondary, [
            [52, 84, 20], [49, 83, 18], [53, 87, 22], [55, 82, 20],
        ])
      + make(.magical, .analogous, [
            [68, 76, 84], [68, 79, 84], [70, 78, 84], [71, 78, 83],
            [76, 84, 92], [76, 87, 92], [79, 86, 92], [78, 81, 93],
            [84, 92, 4], [83, 94, 4], [86, 95, 4], [85, 91, 5],
        ])
      + make(.magical, .splitComplementary, [
            [28, 84, 44], [27, 84, 45], [29, 84, 45], [30, 83, 44],
            [81, 28, 44], [86, 31, 42], [83, 28, 42], [85, 28, 46],
            [42, 28, 86], [46, 29, 84], [42, 27, 82], [45, 29, 84],
        ])
      + make(.magical, .neutral, [
            [98, 100, 84], [99, 84, 97], [84, 98, 101], [99, 98, 84],
        ])

    // MARK: - Nostalgic (pp. 130–133)

    static let nostalgic: [CategorizedPalette] =
        make(.nostalgic, .monochromatic, [
            [83, 88, 86], [87, 83, 85], [81, 83, 86], [88, 81, 86],
        ])
      + make(.nostalgic, .secondary, [
            [22, 54, 86], [19, 51, 87], [24, 55, 88], [22, 50, 86],
        ])
      + make(.nostalgic, .analogous, [
            [70, 78, 86], [69, 79, 86], [72, 79, 88], [71, 77, 83],
            [78, 86, 94], [77, 86, 95], [80, 85, 92], [79, 88, 94],
            [86, 94, 6], [85, 95, 8], [87, 93, 5], [88, 95, 7],
        ])
      + make(.nostalgic, .splitComplementary, [
            [46, 86, 30], [48, 87, 31], [42, 86, 31], [47, 86, 27],
            [41, 83, 27], [42, 85, 32], [46, 87, 31], [43, 85, 26],
            [26, 43, 86], [30, 45, 82], [32, 47, 86], [27, 43, 87],
        ])
      + make(.nostalgic, .neutral, [
            [96, 100, 87], [97, 101, 86], [98, 88, 102], [96, 85, 103],
        ])

    // MARK: - Energetic (pp. 134–137)

    static let energetic: [CategorizedPalette] =
        make(.energetic, .monochromatic, [
            [90, 96, 92], [96, 90, 92], [89, 91, 93], [91, 95, 92],
        ])
      + make(.energetic, .tertiary, [
            [28, 92, 60], [26, 94, 59], [29, 94, 61], [31, 91, 60],
        ])
      + make(.energetic, .analogous, [
            [76, 84, 92], [76, 85, 92], [78, 88, 92], [79, 87, 91],
            [84, 92, 4], [84, 93, 4], [86, 95, 4], [87, 90, 5],
            [92, 4, 12], [91, 7, 12], [94, 6, 12], [95, 2, 13],
        ])
      + make(.energetic, .splitComplementary, [
            [36, 92, 52], [35, 92, 54], [39, 92, 55], [37, 90, 52],
            [89, 36, 52], [96, 40, 50], [90, 36, 49], [93, 36, 54],
            [49, 36, 93], [55, 37, 92], [49, 33, 90], [53, 37, 92],
        ])
      + make(.energetic, .neutral, [
            [98, 100, 92], [99, 92, 102], [92, 98, 101], [99, 98, 92],
        ])

    // MARK: - Subdued (pp. 138–141)

    static let subdued: [CategorizedPalette] =
        make(.subdued, .monochromatic, [
            [96, 92, 94], [89, 92, 95], [90, 96, 94], [96, 95, 94],
        ])
      + make(.subdued, .tertiary, [
            [62, 30, 94], [63, 32, 95], [26, 59, 94], [29, 60, 93],
        ])
      + make(.subdued, .analogous, [
            [78, 86, 94], [77, 87, 94], [80, 85, 95], [75, 86, 94],
            [86, 94, 6], [85, 95, 8], [88, 95, 5], [86, 92, 7],
            [94, 6, 13], [93, 7, 15], [96, 6, 14], [95, 7, 16],
        ])
      + make(.subdued, .splitComplementary, [
            [55, 95, 39], [54, 95, 40], [56, 94, 38], [54, 93, 38],
            [51, 91, 38], [54, 93, 34], [55, 95, 35], [50, 96, 34],
            [35, 50, 94], [39, 54, 94], [35, 54, 96], [40, 55, 95],
        ])
      + make(.subdued, .neutral, [
            [98, 99, 94], [100, 94, 98], [94, 98, 101], [99, 98, 94],
        ])

    // MARK: - Pure (pp. 146–149)
    // Built around white (token 107) with pale tints. Row-group scheme labels were
    // not legible, so these carry no scheme tag. (Review pending.)

    static let pure: [CategorizedPalette] =
        makeMixed(.pure, [
            // p.147
            [107, 7, 8], [107, 15, 16], [107, 23, 24], [107, 31, 32],
            [8, 32, 107], [13, 29, 107], [61, 53, 107], [77, 85, 107],
            [107, 96, 48], [107, 8, 56], [107, 16, 67], [107, 24, 72],
            [107, 32, 80], [107, 40, 88], [107, 96, 47], [107, 8, 55],
            // p.148
            [107, 31, 39], [22, 32, 107], [107, 24, 32], [107, 24, 30],
            [31, 39, 107], [107, 40, 47], [32, 107, 47], [32, 38, 107],
            [107, 47, 55], [38, 107, 54], [107, 48, 46], [107, 46, 45],
            [107, 39, 95], [107, 39, 93], [80, 39, 107], [80, 107, 95],
            [78, 39, 107], [80, 40, 107], [75, 39, 107], [107, 37, 94],
            // p.149
            [107, 96, 40], [80, 96, 107], [78, 93, 107], [80, 94, 107],
            [70, 78, 107], [69, 79, 107], [71, 78, 107], [70, 80, 107],
            [107, 99, 71], [72, 107, 100], [100, 67, 107], [107, 68, 99],
        ])

    // MARK: - Graphic (pp. 150–153)
    // Built around black (token 106), often paired with white (107) and one vivid
    // accent. Pure black/white/gray triplets are `.achromatic`; the rest carry no
    // scheme tag. (Review pending.)

    static let graphic: [CategorizedPalette] =
        make(.graphic, .achromatic, [
            [106, 105, 103], [103, 104, 106], [106, 107, 98],
        ])
      + makeMixed(.graphic, [
            // p.151 — black + hue pairs across the spectrum
            [106, 1, 7], [106, 9, 15], [106, 17, 23], [106, 25, 31],
            [106, 33, 37], [106, 41, 45], [106, 49, 53], [106, 57, 61],
            [106, 65, 69], [106, 73, 77], [106, 81, 85], [106, 89, 93],
            // p.152
            [106, 4, 52], [106, 12, 60], [106, 20, 68], [106, 28, 76],
            [106, 36, 84], [106, 44, 92], [106, 12, 68], [106, 12, 52],
            [106, 20, 76], [106, 20, 60], [106, 28, 84], [106, 28, 68],
            [106, 36, 92], [106, 36, 76], [106, 44, 84], [106, 44, 4],
            [106, 52, 92], [106, 60, 4], [106, 60, 20], [106, 68, 12],
            // p.153 — black + white + accent
            [106, 68, 92], [106, 107, 76], [106, 107, 84], [106, 107, 92],
            [106, 107, 4], [106, 107, 12], [106, 107, 20], [106, 107, 28],
        ])
}
