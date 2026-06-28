import SwiftUI

/// A browsable, filterable picker over the book's three-color palettes.
///
/// Users narrow the catalog with up to four independent facets — **Hue**, **Aspect**,
/// **Scheme**, and **Mood** — then tap a palette to select it. All facets are optional
/// and combine; leaving them all unset shows the entire library.
///
/// The view is self-contained: it owns its filter state and reports the chosen palette
/// through `selection` and the `onSelect` closure.
@available(iOS 17.0, macOS 14.0, *)
public struct CategorizedAppPaletteSelectionView: View {

    /// The palettes to browse. Defaults to the full curated library.
    private let palettes: [CategorizedPalette]
    /// The currently selected palette id, if any.
    @Binding private var selection: String?
    /// Called when the user taps a palette.
    private let onSelect: (CategorizedPalette) -> Void

    @State private var hue: PaletteHue?
    @State private var aspect: PaletteAspect?
    @State private var scheme: PaletteScheme?
    @State private var moods: Set<PaletteMood> = []

    public init(
        palettes: [CategorizedPalette] = CategorizedPalette.all,
        selection: Binding<String?> = .constant(nil),
        onSelect: @escaping (CategorizedPalette) -> Void = { _ in }
    ) {
        self.palettes = palettes
        self._selection = selection
        self.onSelect = onSelect
    }

    private var filtered: [CategorizedPalette] {
        palettes.filter { $0.matches(hue: hue, aspect: aspect, scheme: scheme, moods: moods) }
    }

    /// Only schemes that actually have palettes (excludes e.g. Clash/Complementary,
    /// which the source only ever uses for two-color sets).
    private var availableSchemes: [PaletteScheme] {
        PaletteScheme.allCases.filter { s in palettes.contains { $0.scheme == s } }
    }

    public var body: some View {
        VStack(spacing: 0) {
            facetBar
            Divider()
            if filtered.isEmpty {
                ContentUnavailableViewCompat(
                    title: "No matching palettes",
                    message: "Try clearing a filter."
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(filtered) { palette in
                            PaletteRow(palette: palette, isSelected: palette.id == selection)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selection = palette.id
                                    onSelect(palette)
                                }
                        }
                    }
                    .padding()
                }
            }
        }
    }

    // MARK: Facet controls

    private var facetBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                facetMenu(title: "Hue", selection: $hue, options: PaletteHue.allCases) { $0.rawValue }
                facetMenu(title: "Aspect", selection: $aspect, options: PaletteAspect.allCases) { $0.rawValue }
                facetMenu(title: "Scheme", selection: $scheme, options: availableSchemes) { $0.rawValue }
                moodMenu
                if hue != nil || aspect != nil || scheme != nil || !moods.isEmpty {
                    Button("Clear") {
                        hue = nil; aspect = nil; scheme = nil; moods = []
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    private func facetMenu<Option: Hashable>(
        title: String,
        selection: Binding<Option?>,
        options: [Option],
        label: @escaping (Option) -> String
    ) -> some View {
        Menu {
            Button("All") { selection.wrappedValue = nil }
            Divider()
            ForEach(options, id: \.self) { option in
                Button {
                    selection.wrappedValue = option
                } label: {
                    if selection.wrappedValue == option {
                        Label(label(option), systemImage: "checkmark")
                    } else {
                        Text(label(option))
                    }
                }
            }
        } label: {
            FacetChip(
                title: title,
                value: selection.wrappedValue.map(label),
                isActive: selection.wrappedValue != nil
            )
        }
    }

    private var moodMenu: some View {
        Menu {
            ForEach(PaletteMood.allCases, id: \.self) { mood in
                Button {
                    if moods.contains(mood) { moods.remove(mood) } else { moods.insert(mood) }
                } label: {
                    if moods.contains(mood) {
                        Label(mood.label, systemImage: "checkmark")
                    } else {
                        Text(mood.label)
                    }
                }
            }
        } label: {
            FacetChip(
                title: "Mood",
                value: moods.isEmpty ? nil : (moods.count == 1 ? moods.first!.label : "\(moods.count) selected"),
                isActive: !moods.isEmpty
            )
        }
    }
}

// MARK: - Light / Dark preview pair

/// A side-by-side **light** and **dark** preview of a palette, mirroring the two-card
/// approach used by `AppPaletteSelection`. Each card renders the palette's three colors
/// as a swatch strip plus a sample title, caption, and action button so you can judge
/// how the palette reads on both a light and a dark surface.
@available(iOS 17.0, macOS 14.0, *)
public struct CategorizedPalettePreview: View {
    public let palette: CategorizedPalette

    public init(palette: CategorizedPalette) {
        self.palette = palette
    }

    public var body: some View {
        HStack(spacing: 12) {
            card(isDark: false)
            card(isDark: true)
        }
    }

    private func card(isDark: Bool) -> some View {
        let surface: Color = isDark ? Color(white: 0.11) : Color(white: 0.98)
        let textColor: Color = isDark ? palette.lightestByLuminance : palette.darkestByLuminance
        let secondary = textColor.opacity(0.6)

        return VStack(alignment: .leading, spacing: 8) {
            // Swatch strip
            HStack(spacing: 0) {
                ForEach(Array(palette.swiftUIColors.enumerated()), id: \.offset) { _, c in
                    Rectangle().fill(c)
                }
            }
            .frame(height: 28)
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))

            Text(isDark ? "Dark" : "Light")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(secondary)

            Text(palette.name)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(textColor)
                .lineLimit(1)

            Text("Sample caption text")
                .font(.system(size: 11))
                .foregroundStyle(secondary)

            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(palette.dominantColor)
                .frame(height: 28)
                .overlay(
                    Text("Action")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(palette.dominantContrastColor)
                )
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(surface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.10), lineWidth: 1)
        )
    }
}

// MARK: - Subviews

@available(iOS 17.0, macOS 14.0, *)
private struct FacetChip: View {
    let title: String
    let value: String?
    let isActive: Bool

    var body: some View {
        HStack(spacing: 4) {
            Text(value ?? title)
            Image(systemName: "chevron.down").font(.caption2)
        }
        .font(.subheadline.weight(isActive ? .semibold : .regular))
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule().fill(isActive ? Color.accentColor.opacity(0.18) : Color.gray.opacity(0.12))
        )
        .foregroundStyle(isActive ? Color.accentColor : Color.primary)
    }
}

@available(iOS 17.0, macOS 14.0, *)
private struct PaletteRow: View {
    let palette: CategorizedPalette
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 0) {
                ForEach(Array(palette.swiftUIColors.enumerated()), id: \.offset) { _, color in
                    Rectangle().fill(color)
                }
            }
            .frame(width: 96, height: 48)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.primary.opacity(0.08)))

            VStack(alignment: .leading, spacing: 2) {
                Text(palette.name).font(.headline)
                if let scheme = palette.scheme {
                    Text(scheme.rawValue).font(.caption).foregroundStyle(.secondary)
                }
            }
            Spacer()
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.accentColor)
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isSelected ? Color.accentColor.opacity(0.10) : Color.clear)
        )
    }
}

/// Minimal stand-in so the component compiles on the stated minimums without
/// depending on newer `ContentUnavailableView` availability.
@available(iOS 17.0, macOS 14.0, *)
private struct ContentUnavailableViewCompat: View {
    let title: String
    let message: String
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: "paintpalette").font(.largeTitle).foregroundStyle(.secondary)
            Text(title).font(.headline)
            Text(message).font(.subheadline).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Previews

@available(iOS 17.0, macOS 14.0, *)
#Preview("Full library") {
    CategorizedAppPaletteSelectionView()
}

@available(iOS 17.0, macOS 14.0, *)
#Preview("Single mood") {
    CategorizedAppPaletteSelectionView(palettes: CategorizedPalette.palettes(mood: .tropical))
}
