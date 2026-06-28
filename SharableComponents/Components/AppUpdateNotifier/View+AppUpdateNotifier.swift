//
//  View+AppUpdateNotifier.swift
//  SharableComponents
//

import SwiftUI

public extension View {

    /// Attaches the update notifier sheet to this view.
    ///
    /// The sheet appears automatically when `AppUpdateNotifierManager.shared.shouldShow`
    /// is true — i.e. the first launch after a new app version is installed.
    ///
    /// Pass `accentColor` and `backgroundColor` from whichever color store the
    /// host app uses (`AppColorStore` or `AppPaletteStore`), or omit both to fall
    /// back to system accent colors.
    ///
    /// ```swift
    /// // Minimal — system accent colors
    /// ContentView()
    ///     .appUpdateNotifier()
    ///
    /// // With AppColorStore
    /// ContentView()
    ///     .appUpdateNotifier(
    ///         accentColor: colorStore.accentColor,
    ///         backgroundColor: colorStore.backgroundColor
    ///     )
    ///
    /// // With AppPaletteStore
    /// ContentView()
    ///     .appUpdateNotifier(
    ///         accentColor: paletteStore.accentColor,
    ///         backgroundColor: paletteStore.backgroundColor
    ///     )
    /// ```
    func appUpdateNotifier(
        manager: AppUpdateNotifierManager = .shared,
        accentColor: Color = .accentColor,
        backgroundColor: Color = Color(.systemBackground)
    ) -> some View {
        self.modifier(
            AppUpdateNotifierModifier(
                manager: manager,
                accentColor: accentColor,
                backgroundColor: backgroundColor
            )
        )
    }
}

// MARK: - Modifier

private struct AppUpdateNotifierModifier: ViewModifier {

    let manager: AppUpdateNotifierManager
    let accentColor: Color
    let backgroundColor: Color

    private var shouldPresent: Bool {
        manager.shouldShow
    }

    func body(content: Content) -> some View {
        content.sheet(isPresented: .constant(shouldPresent)) {
            AppUpdateNotifierView(
                config: manager.config,
                accentColor: accentColor,
                backgroundColor: backgroundColor,
                onDismiss: { manager.dismiss() },
                onSuppressForVersion: { manager.suppressForThisVersion() }
            )
            .interactiveDismissDisabled()
        }
    }
}
