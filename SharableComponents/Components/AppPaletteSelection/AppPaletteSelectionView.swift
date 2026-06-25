//
//  AppPaletteSelectionView.swift
//  SharableComponents
//

import SwiftUI

// MARK: - Display mode

/// Controls how palette swatches are laid out inside `AppPaletteSelectionView`.
public enum AppPaletteDisplayMode: Equatable {
    /// Horizontally scrolling row of swatch strips (default).
    case band
    /// Vertically scrollable list: swatch strip + name + checkmark per row.
    case list
    /// Fixed-column grid of swatch strips.
    case grid(columns: Int)
}

// MARK: - View

/// A palette picker backed by an `AppPaletteStore`.
///
/// Each palette entry is rendered as a horizontal Coolors-style swatch strip
/// (one rectangle per color). Selecting a palette immediately updates the store
/// and persists the choice. Users can add their own palettes via the inline "+" button.
///
/// ```swift
/// AppPaletteSelectionView(
///     store: paletteStore,
///     displayMode: .grid(columns: 3),
///     message: "Sets the app's accent and surface colors."
/// )
/// ```
public struct AppPaletteSelectionView: View {

    var store: AppPaletteStore
    let displayMode: AppPaletteDisplayMode
    let title: String
    let message: String?

    @State private var showAddSheet    = false
    @State private var searchText      = ""
    @State private var showSearchHelp  = false

    public init(
        store: AppPaletteStore,
        displayMode: AppPaletteDisplayMode = .band,
        title: String = "APP PALETTE",
        message: String? = nil
    ) {
        self.store       = store
        self.displayMode = displayMode
        self.title       = title
        self.message     = message
    }

    private var tint: Color { store.accentColor }

    private var filteredCatalog: [AppPalettePreset] {
        let raw = searchText.trimmingCharacters(in: .whitespaces).lowercased()
        guard !raw.isEmpty else { return store.catalog }
        // "cold" is an alias for "cool"
        let q = raw == "cold" ? "cool" : raw
        return store.catalog.filter { palette in
            palette.paletteName.lowercased().contains(q) ||
            palette.tags.contains { $0.hasPrefix(q) }
        }
    }

    // MARK: - Body

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(tint.opacity(0.55))
                .padding(.horizontal, 18)

            if let message {
                Text(message)
                    .font(.system(size: 12))
                    .foregroundStyle(tint.opacity(0.6))
                    .padding(.horizontal, 18)
                    .padding(.bottom, 2)
            }

            searchField

            swatchArea
                .background(tint.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(tint.opacity(0.15), lineWidth: 1)
                )
                .padding(.horizontal, 18)

            previewSection
                .padding(.top, 4)
        }
        .sheet(isPresented: $showAddSheet) {
            AddPaletteSheet { name, hexSlug in
                store.add(name: name, hexSlug: hexSlug)
            }
        }
        .accessibilityIdentifier("appPaletteSelectionView")
    }

    // MARK: - Swatch area dispatch

    @ViewBuilder
    private var swatchArea: some View {
        switch displayMode {
        case .band:             bandLayout
        case .list:             listLayout
        case .grid(let cols):   gridLayout(columns: cols)
        }
    }

    // MARK: Band

    private var bandLayout: some View {
        Group {
            if filteredCatalog.isEmpty {
                emptySearchState
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(filteredCatalog) { paletteCell($0, style: .band) }
                        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
                            addButton(style: .band)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
        }
    }

    // MARK: List

    private var listLayout: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                if filteredCatalog.isEmpty {
                    emptySearchState
                } else {
                    ForEach(filteredCatalog) { palette in
                        paletteRow(palette)
                        if palette.id != filteredCatalog.last?.id {
                            Divider().padding(.leading, 16)
                        }
                    }
                    if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
                        Divider().padding(.leading, 16)
                        addButton(style: .list)
                    }
                }
            }
        }
        .frame(maxHeight: 320)
    }

    // MARK: Grid

    private func gridLayout(columns: Int) -> some View {
        let cols = Array(repeating: GridItem(.flexible(), spacing: 10), count: columns)
        return Group {
            if filteredCatalog.isEmpty {
                emptySearchState
                    .padding(14)
            } else {
                LazyVGrid(columns: cols, spacing: 10) {
                    ForEach(filteredCatalog) { paletteCell($0, style: .grid) }
                    if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
                        addButton(style: .grid)
                    }
                }
                .padding(14)
            }
        }
    }

    // MARK: - Cell (band / grid)

    private enum CellStyle { case band, grid, list }

    private func paletteCell(_ palette: AppPalettePreset, style: CellStyle) -> some View {
        let isSelected  = store.selectedPreset == palette
        let stripHeight: CGFloat = style == .grid ? 30 : 38

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { store.select(palette) }
        } label: {
            VStack(spacing: 5) {
                PaletteSwatchStrip(colors: palette.swatchColors, height: stripHeight)
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .strokeBorder(isSelected ? tint : Color.clear, lineWidth: 2)
                    )
                    .frame(width: style == .band ? 84 : nil)

                Text(palette.paletteName)
                    .font(.system(size: 9, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? tint : tint.opacity(0.5))
                    .lineLimit(1)
                    .frame(width: style == .band ? 84 : nil)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(palette.paletteName)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    // MARK: - Row (list)

    private func paletteRow(_ palette: AppPalettePreset) -> some View {
        let isSelected = store.selectedPreset == palette

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { store.select(palette) }
        } label: {
            HStack(spacing: 12) {
                PaletteSwatchStrip(colors: palette.swatchColors, height: 26)
                    .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                    .frame(width: 80)

                Text(palette.paletteName)
                    .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? tint : tint.opacity(0.75))

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(tint)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            if store.isUserAdded(palette) {
                Button(role: .destructive) { store.remove(palette) } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
        .accessibilityLabel(palette.paletteName)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    // MARK: - Search field

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 13))
                .foregroundStyle(tint.opacity(0.4))

            TextField("e.g. blue, warm, pastel, vibrant, earth…", text: $searchText)
                .font(.system(size: 13))
                .foregroundStyle(tint)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            if !searchText.isEmpty {
                Button {
                    withAnimation(.easeOut(duration: 0.15)) { searchText = "" }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(tint.opacity(0.35))
                }
                .buttonStyle(.plain)
            }

            Button {
                showSearchHelp.toggle()
            } label: {
                Image(systemName: "info.circle")
                    .font(.system(size: 15))
                    .foregroundStyle(tint.opacity(0.45))
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showSearchHelp, arrowEdge: .top) {
                searchHelpPopover
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(tint.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .padding(.horizontal, 18)
        .padding(.bottom, 2)
    }

    // MARK: - Search help popover

    private var searchHelpPopover: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                Text("Search Tips")
                    .font(.system(size: 15, weight: .semibold))

                searchHelpGroup(heading: "By Color", items: [
                    ("red, orange, yellow", "Palettes with warm hues in that range"),
                    ("green, teal, blue",   "Mid-spectrum and cool hues"),
                    ("purple, pink",        "Violet and rose family"),
                ])

                searchHelpGroup(heading: "By Temperature", items: [
                    ("warm",      "Reds, oranges, and yellows dominate"),
                    ("cool / cold", "Blues, greens, and purples dominate"),
                ])

                searchHelpGroup(heading: "By Character", items: [
                    ("pastel",   "Soft, light, low-saturation colors"),
                    ("vibrant",  "Rich, highly saturated colors — opposite of pastel"),
                    ("neutral",  "Near-gray, low-saturation palette"),
                    ("dark",     "Overall low brightness"),
                    ("light",    "Overall high brightness"),
                ])

                searchHelpGroup(heading: "By Feel", items: [
                    ("earth",  "Warm, mid-tone naturalistic hues"),
                ])

                searchHelpGroup(heading: "By Name", items: [
                    ("ocean, berry, autumn…", "Any word from the palette name"),
                ])
            }
            .padding(18)
        }
        .frame(minWidth: 280, maxWidth: 320)
        .presentationCompactAdaptation(.popover)
    }

    private func searchHelpGroup(heading: String, items: [(String, String)]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(heading)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(tint.opacity(0.55))
                .textCase(.uppercase)

            ForEach(items, id: \.0) { term, description in
                HStack(alignment: .top, spacing: 8) {
                    Text(term)
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .foregroundStyle(tint)
                        .frame(width: 110, alignment: .leading)
                    Text(description)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    // MARK: - Empty search state

    private var emptySearchState: some View {
        VStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 22))
                .foregroundStyle(tint.opacity(0.25))
            Text("No palettes match \"\(searchText)\"")
                .font(.system(size: 12))
                .foregroundStyle(tint.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    // MARK: - Add button

    private func addButton(style: CellStyle) -> some View {
        Button { showAddSheet = true } label: {
            switch style {
            case .band:
                VStack(spacing: 5) {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .strokeBorder(
                            tint.opacity(0.35),
                            style: StrokeStyle(lineWidth: 1.5, dash: [4])
                        )
                        .frame(width: 84, height: 38)
                        .overlay(
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(tint.opacity(0.5))
                        )
                    Text("Add")
                        .font(.system(size: 9))
                        .foregroundStyle(tint.opacity(0.5))
                }

            case .grid:
                VStack(spacing: 5) {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .strokeBorder(
                            tint.opacity(0.35),
                            style: StrokeStyle(lineWidth: 1.5, dash: [4])
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: 30)
                        .overlay(
                            Image(systemName: "plus")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(tint.opacity(0.5))
                        )
                    Text("Add")
                        .font(.system(size: 9))
                        .foregroundStyle(tint.opacity(0.5))
                }

            case .list:
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .strokeBorder(
                            tint.opacity(0.35),
                            style: StrokeStyle(lineWidth: 1.5, dash: [4])
                        )
                        .frame(width: 80, height: 26)
                        .overlay(
                            Image(systemName: "plus")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(tint.opacity(0.5))
                        )
                    Text("Add Palette")
                        .font(.system(size: 14))
                        .foregroundStyle(tint.opacity(0.6))
                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .contentShape(Rectangle())
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Add palette")
    }

    // MARK: - Preview section

    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("PREVIEW")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(tint.opacity(0.55))
                .padding(.horizontal, 18)

            miniAppPreview
                .padding(.horizontal, 18)
        }
    }

    private var miniAppPreview: some View {
        let p = store.selectedPreset
        let buttonFg: Color = p.accentColor.paletteLuminance > 0.55 ? .black : .white

        return VStack(alignment: .leading, spacing: 0) {

            // Nav bar
            HStack {
                Text("My App")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(p.labelColor)
                Spacer()
                Circle()
                    .fill(p.accentColor)
                    .frame(width: 22, height: 22)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)

            // Card
            VStack(alignment: .leading, spacing: 7) {
                Text("Primary Text")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(p.labelColor)

                Text("Secondary caption text")
                    .font(.system(size: 10))
                    .foregroundStyle(p.secondaryLabelColor)

                // Input field
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(p.fillColor)
                    .frame(height: 24)
                    .overlay(
                        Text("Search…")
                            .font(.system(size: 9))
                            .foregroundStyle(p.secondaryLabelColor)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 8)
                    )

                // Action button
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .fill(p.accentColor)
                    .frame(height: 28)
                    .overlay(
                        Text("Confirm")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(buttonFg)
                    )
            }
            .padding(12)
            .background(p.groupedBackground)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .padding(.horizontal, 10)
            .padding(.bottom, 10)
        }
        .background(p.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(tint.opacity(0.12), lineWidth: 1)
        )
    }
}

// MARK: - Swatch strip

/// A horizontal row of equal-width color rectangles — the Coolors visual style.
public struct PaletteSwatchStrip: View {
    public let colors: [Color]
    public let height: CGFloat

    public init(colors: [Color], height: CGFloat) {
        self.colors = colors
        self.height = height
    }

    public var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                ForEach(Array(colors.enumerated()), id: \.offset) { _, color in
                    color.frame(
                        width: geo.size.width / CGFloat(colors.count),
                        height: height
                    )
                }
            }
        }
        .frame(height: height)
    }
}

// MARK: - Add Palette Sheet

private struct AddPaletteSheet: View {

    /// Called with (name, hexSlug) on Save. Returns true on success.
    let onAdd: (String, String) -> Bool

    @Environment(\.dismiss) private var dismiss
    @State private var name    = ""
    @State private var slots   = Array(repeating: "", count: 5)
    @State private var showError = false

    // MARK: Derived

    private var parsedSlots: [String?] {
        slots.map { raw -> String? in
            let clean = raw.trimmingCharacters(in: .whitespacesAndNewlines)
                          .replacingOccurrences(of: "#", with: "")
                          .lowercased()
            return clean.count == 6 && Int(clean, radix: 16) != nil ? clean : nil
        }
    }

    private var validColors: [Color] {
        parsedSlots.compactMap { $0.map { Color(paletteHex: $0) } }
    }

    private var hexSlug: String {
        parsedSlots.compactMap { $0 }.joined(separator: "-")
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && validColors.count >= 2
    }

    // MARK: Body

    var body: some View {
        NavigationStack {
            Form {

                Section {
                    TextField("e.g. Summer Vibes", text: $name)
                } header: {
                    Text("Palette Name")
                }

                Section {
                    ForEach(0..<5, id: \.self) { i in
                        hexRow(index: i)
                    }

                    if validColors.count >= 2 {
                        PaletteSwatchStrip(colors: validColors, height: 40)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            .listRowInsets(EdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12))
                    }
                } header: {
                    Text("Colors")
                } footer: {
                    if showError {
                        Label("Could not save. Check that at least 2 colors are valid 6-digit hex codes.",
                              systemImage: "exclamationmark.circle")
                            .foregroundStyle(.red)
                            .font(.caption)
                    } else {
                        Text("Enter each color as a 6-digit hex code (e.g. \(Text("ff6b6b").bold()) or \(Text("#ff6b6b").bold())). At least 2 colors are required; unused slots are ignored.")
                    }
                }
            }
            .navigationTitle("Add Palette")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if onAdd(name.trimmingCharacters(in: .whitespaces), hexSlug) {
                            dismiss()
                        } else {
                            showError = true
                        }
                    }
                    .disabled(!isValid)
                }
            }
        }
    }

    // MARK: Hex row

    private func hexRow(index: Int) -> some View {
        HStack(spacing: 12) {
            Text("Color \(index + 1)")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .frame(width: 60, alignment: .leading)

            TextField("#rrggbb", text: $slots[index])
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .font(.system(size: 14, design: .monospaced))
                .onChange(of: slots[index]) { _, _ in showError = false }

            // Live swatch — shows parsed color or a placeholder
            if let hex = parsedSlots[index] {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(Color(paletteHex: hex))
                    .frame(width: 28, height: 28)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .strokeBorder(.primary.opacity(0.12), lineWidth: 1)
                    )
            } else {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .strokeBorder(.secondary.opacity(0.3),
                                  style: StrokeStyle(lineWidth: 1.5, dash: [4]))
                    .frame(width: 28, height: 28)
            }
        }
    }
}

// MARK: - Previews

#Preview("Band") {
    ScrollView {
        AppPaletteSelectionView(
            store: AppPaletteStore(),
            displayMode: .band,
            message: "Sets the app's accent and surface colors throughout the interface."
        )
        .padding(.vertical)
    }
}

#Preview("List") {
    ScrollView {
        AppPaletteSelectionView(
            store: AppPaletteStore(),
            displayMode: .list
        )
        .padding(.vertical)
    }
}

#Preview("Grid 3 columns") {
    ScrollView {
        AppPaletteSelectionView(
            store: AppPaletteStore(),
            displayMode: .grid(columns: 3)
        )
        .padding(.vertical)
    }
}
