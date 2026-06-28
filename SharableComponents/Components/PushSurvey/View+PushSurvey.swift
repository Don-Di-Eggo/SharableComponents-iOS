import SwiftUI

extension View {
    /// Attaches the PushSurvey sheet to this view. Place on your root view.
    /// Call `PushSurveyManager.shared.configure(_:)` and `recordLaunch()` at app startup.
    public func pushSurvey(config: PushSurveyConfig? = nil) -> some View {
        modifier(PushSurveyModifier(config: config))
    }
}

private struct PushSurveyModifier: ViewModifier {
    let config: PushSurveyConfig?
    @StateObject private var manager = PushSurveyManager.shared

    func body(content: Content) -> some View {
        content
            .sheet(item: Binding(
                get: { manager.activeSurvey },
                set: { if $0 == nil { manager.dismiss() } }
            )) { survey in
                let effectiveConfig = config ?? manager.currentConfig
                let customerID = CustomerIdentifier(suiteName: effectiveConfig.suiteName).id
                PushSurveyView(
                    survey: survey,
                    customerID: customerID,
                    onDismiss: { manager.dismiss() },
                    onDecline: { manager.decline() },
                    onSubmit: { response in await manager.submit(response) }
                )
            }
    }
}
