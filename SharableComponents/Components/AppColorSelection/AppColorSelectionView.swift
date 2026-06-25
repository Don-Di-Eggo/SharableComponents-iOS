//
//  AppColorSelectionView.swift
//  SharableComponents
//

import SwiftUI

// MARK: - Display mode

/// Controls how the swatch picker is rendered inside `AppColorSelectionView`.
public enum AppColorDisplayMode {
    /// A single horizontally scrolling row of swatches (default).
    case band
    /// A scrollable list showing each option as a colour swatch + name row.
    case picker
    /// A fixed-column grid. `columns` sets how many swatches per row;
    /// the number of rows is determined automatically by the option count.
    case matrix(columns: Int)
}

// MARK: - View

/// A reusable color picker with a live light/dark preview.
///
/// Choose a display style via `displayMode`:
/// - `.band` — horizontal scroll row (default)
/// - `.picker` — scrollable swatch + name list
/// - `.matrix(columns:)` — fixed-column grid
///
/// ```swift
/// AppColorSelectionView(
///     options: AppColorPreset.all,
///     selectedOption: store.selectedPreset,
///     tintColor: store.accentColor
/// ) { store.select($0) }
/// ```
public struct AppColorSelectionView<Option: AppColorSelectable>: View {

    let displayMode: AppColorDisplayMode
    let title: String
    let message: String?
    let options: [Option]
    let selectedOption: Option
    let tintColor: Color
    let onSelect: (Option) -> Void

    public init(
        displayMode: AppColorDisplayMode = .band,
        title: String = "APP PALETTE",
        message: String? = nil,
        options: [Option],
        selectedOption: Option,
        tintColor: Color = .primary,
        onSelect: @escaping (Option) -> Void
    ) {
        self.displayMode = displayMode
        self.title       = title
        self.message     = message
        self.options     = options
        self.selectedOption = selectedOption
        self.tintColor   = tintColor
        self.onSelect    = onSelect
    }

    // MARK: - Body

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(tintColor.opacity(0.55))
                .padding(.horizontal, 18)

            if let message {
                Text(message)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(tintColor.opacity(0.6))
                    .padding(.horizontal, 18)
                    .padding(.bottom, 6)
            }

            swatchArea
                .background(tintColor.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(tintColor.opacity(0.15), lineWidth: 1)
                )
                .padding(.horizontal, 18)

            previewSection
                .padding(.top, 4)
        }
        .accessibilityIdentifier("appColorSelectionView")
    }

    // MARK: - Swatch area

    @ViewBuilder
    private var swatchArea: some View {
        switch displayMode {
        case .band:             bandLayout
        case .picker:           pickerLayout
        case .matrix(let cols): matrixLayout(columns: cols)
        }
    }

    // MARK: Band

    private var bandLayout: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .bottom, spacing: 14) {
                ForEach(options) { swatchButton(for: $0) }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 6)
        }
    }

    // MARK: Picker

    private var pickerLayout: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                ForEach(options) { option in
                    pickerRow(for: option)
                    if option != options.last {
                        Divider().padding(.leading, 52)
                    }
                }
            }
        }
        .frame(maxHeight: 260)
    }

    private func pickerRow(for option: Option) -> some View {
        let isSelected = selectedOption == option

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                onSelect(option)
            }
        } label: {
            HStack(spacing: 12) {
                Circle()
                    .fill(option.accentColor)
                    .frame(width: 26, height: 26)
                    .overlay(Circle().strokeBorder(Color.white.opacity(0.2), lineWidth: 1))
                    .shadow(color: option.accentColor.opacity(isSelected ? 0.4 : 0), radius: 4, y: 2)

                Text(option.colorName)
                    .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? tintColor : tintColor.opacity(0.75))

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(tintColor)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(option.colorName)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    // MARK: Matrix

    private func matrixLayout(columns: Int) -> some View {
        let size: CGFloat = 44
        let spacing: CGFloat = 14
        let cols = Array(repeating: GridItem(.fixed(size), spacing: spacing), count: columns)

        return LazyVGrid(columns: cols, alignment: .leading, spacing: spacing) {
            ForEach(options) { swatchButton(for: $0) }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
    }

    // MARK: - Swatch button

    private func swatchButton(for option: Option) -> some View {
        let isSelected = selectedOption == option

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                onSelect(option)
            }
        } label: {
            VStack(spacing: 5) {
                ZStack {
                    Circle()
                        .strokeBorder(option.accentColor, lineWidth: 2)
                        .frame(width: 44, height: 44)
                        .opacity(isSelected ? 1 : 0)

                    Circle()
                        .fill(option.accentColor)
                        .frame(width: 34, height: 34)
                        .shadow(color: isSelected ? option.accentColor.opacity(0.4) : .clear,
                                radius: 5, y: 2)
                        .overlay(
                            Circle().strokeBorder(
                                Color.white.opacity(isSelected ? 0.35 : 0.2),
                                lineWidth: 1.5
                            )
                        )

                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(option.accentColor.perceivedBrightness > 0.5
                                         ? Color.black.opacity(0.6) : .white)
                        .opacity(isSelected ? 1 : 0)
                }
                .frame(width: 44, height: 44)

                Text(option.colorName)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(isSelected ? tintColor : tintColor.opacity(0.45))
                    .lineLimit(1)
                    .frame(width: 44)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(option.colorName)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    // MARK: - Preview section

    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("PREVIEW")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(tintColor.opacity(0.55))
                .padding(.horizontal, 18)

            HStack(spacing: 12) {
                previewCard(label: "Light", accent: selectedOption.accentColor, isDark: false)
                previewCard(label: "Dark",  accent: selectedOption.accentColor, isDark: true)
            }
            .padding(.horizontal, 18)
        }
    }

    private func previewCard(label: String, accent: Color, isDark: Bool) -> some View {
        let (surface, foreground) = accent.previewPair(onDark: isDark)

        return VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Circle()
                    .fill(foreground)
                    .frame(width: 8, height: 8)
                Text(label)
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(foreground.opacity(0.6))
            }

            Text("Aa")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(foreground)

            Capsule()
                .fill(foreground)
                .frame(width: 36, height: 6)

            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(foreground)
                .frame(maxWidth: .infinity)
                .frame(height: 20)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(surface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(
                    isDark ? Color.white.opacity(0.08) : tintColor.opacity(0.12),
                    lineWidth: 1
                )
        )
    }
}

// MARK: - Previews

#Preview("Band") {
    ScrollView {
        AppColorSelectionView(
            message: "Changes the accent and background tint throughout the entire app.",
            options: AppColorPreset.all,
            selectedOption: AppColorPreset.forest,
            tintColor: AppColorPreset.forest.accentColor
        ) { _ in }
        .padding(.vertical)
    }
}

#Preview("Matrix 6 columns") {
    ScrollView {
        AppColorSelectionView(
            displayMode: .matrix(columns: 6),
            options: AppColorPreset.all,
            selectedOption: AppColorPreset.midnight,
            tintColor: AppColorPreset.midnight.accentColor
        ) { _ in }
        .padding(.vertical)
    }
}

#Preview("Picker list") {
    ScrollView {
        AppColorSelectionView(
            displayMode: .picker,
            options: AppColorPreset.all,
            selectedOption: AppColorPreset.forest,
            tintColor: AppColorPreset.forest.accentColor
        ) { _ in }
        .padding(.vertical)
    }
}
