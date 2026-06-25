//
//  AppColorStore.swift
//  SharableComponents
//

import SwiftUI

/// Persists the user's chosen palette to `UserDefaults` and makes it
/// observable so any SwiftUI view automatically re-renders on change.
///
/// ```swift
/// // In App.init:
/// let colorStore = AppColorStore(suiteName: "group.com.yourapp")
///
/// // On root view:
/// ContentView()
///     .environment(colorStore)
///
/// // In any view:
/// @Environment(AppColorStore.self) private var appColor
/// Rectangle().fill(palette.backgroundColor)
/// Text("Hello").foregroundStyle(palette.accentColor)
/// ```
@Observable
public final class AppColorStore {

    // MARK: - Public

    public private(set) var selectedPreset: AppColorPreset

    /// The deep accent colour for the selected palette.
    public var accentColor: Color     { selectedPreset.accentColor }

    /// The lightly tinted background colour for the selected palette.
    public var backgroundColor: Color { selectedPreset.backgroundColor }

    public func select(_ preset: AppColorPreset) {
        selectedPreset = preset
        defaults.set(preset.rawValue, forKey: Keys.selected)
    }

    // MARK: - Init

    public init(suiteName: String? = nil) {
        let ud = UserDefaults(suiteName: suiteName) ?? .standard
        self.defaults = ud
        let raw = ud.string(forKey: Keys.selected) ?? ""
        self.selectedPreset = AppColorPreset(rawValue: raw) ?? .forest
    }

    // MARK: - Private

    private let defaults: UserDefaults
    private enum Keys { static let selected = "appColor.selectedPreset" }
}
