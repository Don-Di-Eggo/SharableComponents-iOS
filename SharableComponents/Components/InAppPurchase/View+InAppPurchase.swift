import SwiftUI

public extension View {

    /// Attaches the InAppPurchase paywall to this view.
    /// The paywall appears automatically when `InAppPurchaseManager.shared.shouldShowPaywall` becomes true.
    ///
    /// Usage:
    /// ```swift
    /// ContentView()
    ///     .inAppPurchase()
    /// ```
    func inAppPurchase(
        manager: InAppPurchaseManager = InAppPurchaseManager.shared
    ) -> some View {
        self.modifier(InAppPurchaseModifier(manager: manager))
    }
}

// MARK: - Modifier

private struct InAppPurchaseModifier: ViewModifier {

    @ObservedObject var manager: InAppPurchaseManager

    func body(content: Content) -> some View {
        content.fullScreenCover(isPresented: .constant(manager.shouldShowPaywall)) {
            InAppPurchasePaywallView(
                config: manager.config,
                manager: manager
            )
        }
    }
}
