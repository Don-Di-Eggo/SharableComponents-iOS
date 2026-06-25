import SwiftUI

/// All configuration for the AppReviewRequest component.
/// Create one instance, set your values, then pass it to `AppReviewRequestManager.shared.configure(_:)`.
public struct AppReviewRequestConfig {

    // MARK: - Required

    /// Your app's numeric App Store ID (e.g. "915056765").
    public var appStoreID: String

    // MARK: - Trigger conditions (either condition being true fires the prompt)

    /// Minimum number of app launches before the prompt can appear. Default: 10.
    public var minLaunches: Int = 10

    /// Minimum days since first launch before the prompt can appear.
    /// Default: 365 (effectively off — lower this to make days a meaningful trigger).
    public var minDaysSinceFirstLaunch: Int = 365

    // MARK: - Maybe Later cooldown (either condition being true re-enables the prompt)

    /// Launches that must occur after "Maybe Later" before prompting again. Default: 10.
    public var askLaterCooldownLaunches: Int = 10

    /// Days that must pass after "Maybe Later" before prompting again.
    /// Default: 365 (effectively off — lower this to make days a meaningful cooldown).
    public var askLaterCooldownDays: Int = 365

    /// Multiplier applied to both cooldowns on each successive deferral. Default: 1.5.
    /// e.g. with base 10 launches and multiplier 1.5: 10 → 15 → 23 → 34 → (capped)
    public var askLaterMultiplier: Double = 1.5

    /// Maximum launches cooldown after repeated deferrals. Default: 30.
    public var askLaterMaxCooldownLaunches: Int = 30

    /// Maximum days cooldown after repeated deferrals. Default: 90.
    public var askLaterMaxCooldownDays: Int = 90

    // MARK: - Presentation text

    public var title: String = "Enjoying the app?"
    public var message: String = "It only takes a moment and means a lot to us."
    public var submitButtonTitle: String = "Rate on App Store"
    public var maybeLaterButtonTitle: String = "Maybe Later"

    // MARK: - Styling

    public var style: AppReviewRequestStyle = AppReviewRequestStyle()

    // MARK: - UserDefaults

    /// Custom UserDefaults suite name. Use your app's bundle ID to avoid key collisions. Default: nil (uses standard).
    public var userDefaultsSuiteName: String? = nil

    // MARK: - Init

    public init(appStoreID: String) {
        self.appStoreID = appStoreID
    }
}
