//
//  View+AppPalette.swift
//  SharableComponents
//

import SwiftUI

public extension View {
    /// Injects an `AppPaletteStore` into the SwiftUI environment.
    ///
    /// ```swift
    /// // App.init:
    /// let paletteStore = AppPaletteStore(suiteName: "group.com.yourapp")
    ///
    /// // Root view:
    /// ContentView()
    ///     .appPaletteEnvironment(paletteStore)
    ///
    /// // Any child view:
    /// @Environment(AppPaletteStore.self) private var palette
    ///
    /// Text("Hello").foregroundStyle(palette.labelColor)
    /// TextField("Search", text: $q).background(palette.fillColor)
    /// List { }.listRowBackground(palette.groupedBackground)
    /// Button("OK") { }.tint(palette.accentColor)
    /// ```
    func appPaletteEnvironment(_ store: AppPaletteStore) -> some View {
        environment(store)
    }
}
