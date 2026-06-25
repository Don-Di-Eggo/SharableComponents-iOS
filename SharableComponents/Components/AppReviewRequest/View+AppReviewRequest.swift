import SwiftUI

public extension View {

    /// Attaches the App Review Request overlay to this view.
    /// The overlay appears automatically when `AppReviewRequestManager.shared.shouldPrompt` becomes true.
    ///
    /// Usage:
    /// ```swift
    /// ContentView()
    ///     .appReviewRequest()
    /// ```
    func appReviewRequest(
        manager: AppReviewRequestManager = .shared
    ) -> some View {
        self.modifier(AppReviewRequestModifier(manager: manager))
    }
}

// MARK: - Modifier

private struct AppReviewRequestModifier: ViewModifier {

    @ObservedObject var manager: AppReviewRequestManager

    func body(content: Content) -> some View {
        content.overlay {
            if manager.shouldPrompt {
                AppReviewRequestView(
                    config: manager.config,
                    manager: manager
                )
                .animation(.easeInOut(duration: 0.25), value: manager.shouldPrompt)
            }
        }
    }
}
