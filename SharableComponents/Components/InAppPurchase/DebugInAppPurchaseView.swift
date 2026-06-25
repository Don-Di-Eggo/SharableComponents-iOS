#if DEBUG
import SwiftUI

/// Drop this view into a hidden debug menu (long-press, shake, etc.) during development.
/// Never include it in a Release build — the #if DEBUG wrapper handles that automatically.
public struct DebugInAppPurchaseView: View {

    @ObservedObject private var manager = InAppPurchaseManager.shared
    @State private var launchCount = 0

    public init() {}

    public var body: some View {
        NavigationStack {
            List {
                stateSection
                actionsSection
                scenariosSection
            }
            .navigationTitle("IAP Debug")
            .navigationBarTitleDisplayMode(.inline)
        }
        .inAppPurchase(manager: manager)
    }

    // MARK: - State

    private var stateSection: some View {
        Section("Current State") {
            row("Paywall visible", value: manager.shouldShowPaywall ? "YES" : "no", highlight: manager.shouldShowPaywall)
            row("Hard blocked", value: manager.isBlocked ? "YES" : "no", highlight: manager.isBlocked)
            row("Purchased", value: manager.isPurchased ? "YES" : "no", highlight: manager.isPurchased)
            row("Price", value: manager.displayPrice ?? "loading…")
            if let next = manager.nextDeferralLaunches {
                row("Next deferral offer", value: "\(next) launches")
            }
        }
    }

    // MARK: - Actions

    private var actionsSection: some View {
        Section("Actions") {
            Button("Simulate launch") {
                launchCount += 1
                Task { await manager.recordLaunch() }
            }

            Button("Ask Later (if available)") {
                manager.recordAskLater()
            }
            .disabled(manager.nextDeferralLaunches == nil || manager.isBlocked)

            Button("Reset all state", role: .destructive) {
                launchCount = 0
                manager.reset()
            }
        }
    }

    // MARK: - Quick scenarios

    private var scenariosSection: some View {
        Section("Quick Scenarios") {
            Button("Show paywall immediately") {
                manager.reset()
                launchCount = 0
                var config = InAppPurchaseConfig(productID: "com.example.app.unlock")
                config.minLaunches = 1
                config.deferralSteps = [3, 2, 1]
                InAppPurchaseManager.shared.configure(config)
                Task { await manager.recordLaunch() }
            }

            Button("Jump to hard block") {
                manager.reset()
                launchCount = 0
                var config = InAppPurchaseConfig(productID: "com.example.app.unlock")
                config.minLaunches = 1
                config.deferralSteps = []   // no deferrals — immediate hard block
                InAppPurchaseManager.shared.configure(config)
                Task { await manager.recordLaunch() }
            }
        }
    }

    // MARK: - Helper

    private func row(_ label: String, value: String, highlight: Bool = false) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundStyle(highlight ? .orange : .secondary)
                .fontWeight(highlight ? .semibold : .regular)
        }
    }
}

#Preview {
    DebugInAppPurchaseView()
}
#endif
