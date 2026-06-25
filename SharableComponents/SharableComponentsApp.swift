import SwiftUI
import TipKit

@main
struct SharableComponentsApp: App {

    private let colorStore   = AppColorStore()
    private let paletteStore = AppPaletteStore()

    init() {
        var reviewConfig = AppReviewRequestConfig(appStoreID: "YOUR_APP_STORE_ID")
        reviewConfig.minLaunches = 10
        AppReviewRequestManager.shared.configure(reviewConfig)
        AppReviewRequestManager.shared.recordLaunch()

        // IAP is configured here so the IAP test tab works, but recordLaunch()
        // is NOT called globally — use the test tab to trigger the paywall manually.
        var iapConfig = InAppPurchaseConfig(productID: "com.example.app.unlock")
        iapConfig.minLaunches = 15
        iapConfig.deferralSteps = [5, 4, 3]
        InAppPurchaseManager.shared.configure(iapConfig)

        var updateConfig = AppUpdateNotifierConfig(
            appName: "SharableComponents",
            version: "1.0",
            releaseDate: "June 25, 2025",
            message: "Going forward, I'll only do bug fixes on this app. Use Charsi's Compendium and Charsi's Ledger if you'd like to continue to get new features.",
            enhancements: [
                "AppUpdateNotifier component — per-version release notes sheet",
                "AppPaletteSelection component — semantic color tokens and new display modes",
                "AppColorSelection component — 51 color presets with live preview"
            ],
            bugFixes: [
                "TipKit popovers no longer truncate long message text",
                "FeedbackManager subject line now correctly includes the app name"
            ]
        )
        AppUpdateNotifierManager.shared.configure(updateConfig)

        try? Tips.configure([.displayFrequency(.immediate)])
        TipKitGuard.isReady = true
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(colorStore)
                .environment(paletteStore)
                .appUpdateNotifier()
        }
    }
}
