//
//  AppPaletteStore.swift
//  SharableComponents
//

import SwiftUI

// MARK: - Store

/// Observable store that owns the palette catalog, the active selection,
/// and persistence to `UserDefaults`.
///
/// Inject it into the environment once at the root view; every child can
/// then read the semantic color tokens via `@Environment(AppPaletteStore.self)`.
///
/// ```swift
/// // App.init:
/// let paletteStore = AppPaletteStore()
///
/// // Root view:
/// ContentView()
///     .environment(paletteStore)
///
/// // Any child view:
/// @Environment(AppPaletteStore.self) private var palette
/// view.background(palette.backgroundColor)
/// ```
@Observable
public final class AppPaletteStore {

    // MARK: Public state

    public private(set) var catalog: [AppPalettePreset]
    public private(set) var selectedPreset: AppPalettePreset
    /// IDs of palettes added by the user at runtime (not part of the initial catalog).
    public private(set) var userAddedIDs: Set<String> = []

    // MARK: Semantic token accessors

    public var accentColor: Color         { selectedPreset.accentColor }
    public var backgroundColor: Color     { selectedPreset.backgroundColor }
    public var groupedBackground: Color   { selectedPreset.groupedBackground }
    public var fillColor: Color           { selectedPreset.fillColor }
    public var labelColor: Color          { selectedPreset.labelColor }
    public var secondaryLabelColor: Color { selectedPreset.secondaryLabelColor }

    // MARK: Private

    private let defaults: UserDefaults
    private let selectedKey  = "appPalette.selectedID"
    private let userKey      = "appPalette.userPresets"

    // MARK: Init

    /// - Parameters:
    ///   - catalog: Initial palette list. Defaults to `AppPalettePreset.builtIn`.
    ///   - suiteName: Optional `UserDefaults` suite (e.g. an App Group identifier).
    public init(catalog: [AppPalettePreset] = AppPalettePreset.builtIn, suiteName: String? = nil) {
        let ud = suiteName.flatMap { UserDefaults(suiteName: $0) } ?? .standard
        self.defaults = ud

        var full = catalog

        // Restore user-added palettes
        if let data   = ud.data(forKey: "appPalette.userPresets"),
           let stored = try? JSONDecoder().decode([Persisted].self, from: data) {
            let added = stored.map { AppPalettePreset(name: $0.name, hexColors: $0.hexCodes) }
            full.append(contentsOf: added)
            userAddedIDs = Set(added.map(\.id))
        }

        self.catalog = full

        // Restore selection (fall back to first entry)
        let savedID = ud.string(forKey: "appPalette.selectedID")
        self.selectedPreset = full.first { $0.id == savedID } ?? full[0]
    }

    // MARK: Public API

    public func select(_ preset: AppPalettePreset) {
        selectedPreset = preset
        defaults.set(preset.id, forKey: selectedKey)
    }

    /// Add a palette from a Coolors URL (e.g. `https://coolors.co/264653-2a9d8f-e9c46a-f4a261-e76f51`).
    /// Returns `true` on success, `false` if the URL could not be parsed or the palette already exists.
    @discardableResult
    public func add(name: String, coolorsURL: String) -> Bool {
        guard let preset = AppPalettePreset(name: name, coolorsURL: coolorsURL) else { return false }
        return insert(preset)
    }

    /// Add a palette from a raw hex slug (e.g. `"264653-2a9d8f-e9c46a-f4a261-e76f51"`).
    @discardableResult
    public func add(name: String, hexSlug: String) -> Bool {
        guard let preset = AppPalettePreset(name: name, hexSlug: hexSlug) else { return false }
        return insert(preset)
    }

    /// Remove a user-added palette. Built-in palettes cannot be removed.
    public func remove(_ preset: AppPalettePreset) {
        guard userAddedIDs.contains(preset.id) else { return }
        catalog.removeAll { $0.id == preset.id }
        userAddedIDs.remove(preset.id)
        if selectedPreset.id == preset.id {
            select(catalog.first ?? AppPalettePreset.builtIn[0])
        }
        persistUserAdded()
    }

    public func isUserAdded(_ preset: AppPalettePreset) -> Bool {
        userAddedIDs.contains(preset.id)
    }

    // MARK: Private helpers

    @discardableResult
    private func insert(_ preset: AppPalettePreset) -> Bool {
        guard !catalog.contains(where: { $0.id == preset.id }) else { return false }
        catalog.append(preset)
        userAddedIDs.insert(preset.id)
        persistUserAdded()
        return true
    }

    private func persistUserAdded() {
        let items = catalog
            .filter { userAddedIDs.contains($0.id) }
            .map { Persisted(name: $0.paletteName, hexCodes: $0.hexCodes) }
        if let data = try? JSONEncoder().encode(items) {
            defaults.set(data, forKey: userKey)
        }
    }

    private struct Persisted: Codable {
        let name: String
        let hexCodes: [String]
    }
}
