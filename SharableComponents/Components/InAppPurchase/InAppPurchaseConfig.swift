import SwiftUI

/// All configuration for the InAppPurchase component.
/// Create one instance, set your values, then pass it to `InAppPurchaseManager.shared.configure(_:)`.
public struct InAppPurchaseConfig {

    // MARK: - Required

    /// The App Store product ID for your one-time unlock IAP (e.g. "com.yourapp.unlock").
    public var productID: String

    // MARK: - Free trial trigger (either condition fires the paywall)

    /// Launches before the paywall first appears. Default: 15 (assumes review prompt at 10 + 5 buffer).
    public var minLaunches: Int = 15

    /// Days since first launch before the paywall first appears.
    /// Default: 365 (effectively off — lower this to make days a meaningful trigger).
    public var minDaysSinceFirstLaunch: Int = 365

    // MARK: - Deferral steps

    /// Launches the user gets between each "Ask Later" tap, in order.
    /// e.g. [5, 4, 3] → user gets 5 launches, then 4, then 3, then the paywall is a hard block.
    /// Once this array is exhausted, the paywall cannot be dismissed.
    public var deferralSteps: [Int] = [5, 4, 3]

    // MARK: - Presentation text

    public var headline: String = "Unlock the Full App"
    public var subtitle: String = "Get unlimited access to everything."
    public var purchaseButtonTitle: String = "Unlock Now"
    public var restoreButtonTitle: String = "Restore Purchase"

    /// Label for the "Ask Later" button. Use `%d` as a placeholder for the launch count.
    /// e.g. "Remind me in %d launches" → "Remind me in 5 launches"
    public var askLaterFormat: String = "Remind me in %d launches"

    // MARK: - Styling

    public var style: InAppPurchaseStyle = InAppPurchaseStyle()

    // MARK: - UserDefaults

    /// Custom UserDefaults suite name. Use your app's bundle ID to avoid key collisions. Default: nil (uses standard).
    public var userDefaultsSuiteName: String? = nil

    // MARK: - Init

    public init(productID: String) {
        self.productID = productID
    }
}
