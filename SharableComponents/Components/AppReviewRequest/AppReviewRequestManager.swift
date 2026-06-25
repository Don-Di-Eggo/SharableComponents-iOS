import SwiftUI
import Combine

/// Tracks launch counts, install date, and Maybe Later state.
/// Call `configure(_:)` once at app startup, then `recordLaunch()` on each launch.
/// Observe `shouldPrompt` to know when to show the overlay.
@MainActor
public final class AppReviewRequestManager: ObservableObject {

    public static let shared = AppReviewRequestManager()

    // MARK: - Published state

    @Published public private(set) var shouldPrompt: Bool = false

    // MARK: - Config

    private(set) var config: AppReviewRequestConfig = AppReviewRequestConfig(appStoreID: "")

    // MARK: - UserDefaults keys

    private enum Key {
        static let firstLaunchDate     = "arr_firstLaunchDate"
        static let launchCount         = "arr_launchCount"
        static let state               = "arr_state"
        static let askLaterDate        = "arr_askLaterDate"
        static let askLaterLaunchCount = "arr_askLaterLaunchCount"
        static let deferCount          = "arr_deferCount"
    }

    // MARK: - Persistent state machine

    private enum PromptState: String {
        case eligible   // Not yet prompted
        case askLater   // User tapped Maybe Later
        case completed  // User opened the App Store review page
    }

    // MARK: - Private

    private var defaults: UserDefaults {
        if let suite = config.userDefaultsSuiteName {
            return UserDefaults(suiteName: suite) ?? .standard
        }
        return .standard
    }

    private init() {}

    // MARK: - Public API

    /// Call once at app startup before `recordLaunch()`.
    public func configure(_ config: AppReviewRequestConfig) {
        self.config = config
    }

    /// Call once per app launch (e.g., in your App's `init` or `onAppear` on the root view).
    public func recordLaunch() {
        seedFirstLaunchDateIfNeeded()
        incrementLaunchCount()
        evaluateShouldPrompt()
    }

    /// Call after the user taps "Maybe Later".
    public func recordAskLater() {
        defaults.set(PromptState.askLater.rawValue, forKey: Key.state)
        defaults.set(Date(), forKey: Key.askLaterDate)
        defaults.set(launchCount, forKey: Key.askLaterLaunchCount)
        defaults.set(deferCount + 1, forKey: Key.deferCount)
        shouldPrompt = false
    }

    /// Call after the user successfully opens the App Store review page.
    public func recordCompleted() {
        defaults.set(PromptState.completed.rawValue, forKey: Key.state)
        shouldPrompt = false
    }

    /// Resets all persisted state. Useful for testing — do not call in production.
    public func reset() {
        for key in [Key.firstLaunchDate, Key.launchCount, Key.state,
                    Key.askLaterDate, Key.askLaterLaunchCount, Key.deferCount] {
            defaults.removeObject(forKey: key)
        }
        shouldPrompt = false
    }

    /// Opens the App Store write-a-review page for the configured app ID.
    public func openAppStorePage() {
        #if targetEnvironment(macCatalyst)
        let urlString = "macappstore://itunes.apple.com/app/id\(config.appStoreID)?action=write-review"
        #else
        let urlString = "itms-apps://itunes.apple.com/app/id\(config.appStoreID)?action=write-review"
        #endif
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
        recordCompleted()
    }

    // MARK: - Private helpers

    private var launchCount: Int {
        defaults.integer(forKey: Key.launchCount)
    }

    private var deferCount: Int {
        defaults.integer(forKey: Key.deferCount)
    }

    private var firstLaunchDate: Date? {
        defaults.object(forKey: Key.firstLaunchDate) as? Date
    }

    private var currentState: PromptState {
        guard let raw = defaults.string(forKey: Key.state),
              let state = PromptState(rawValue: raw) else {
            return .eligible
        }
        return state
    }

    private func seedFirstLaunchDateIfNeeded() {
        guard defaults.object(forKey: Key.firstLaunchDate) == nil else { return }
        defaults.set(Date(), forKey: Key.firstLaunchDate)
    }

    private func incrementLaunchCount() {
        defaults.set(launchCount + 1, forKey: Key.launchCount)
    }

    private func evaluateShouldPrompt() {
        switch currentState {
        case .completed:
            shouldPrompt = false
        case .eligible:
            shouldPrompt = triggerConditionMet()
        case .askLater:
            shouldPrompt = askLaterCooldownExpired() && triggerConditionMet()
        }
    }

    private func triggerConditionMet() -> Bool {
        let launchesMet = launchCount >= config.minLaunches
        let daysMet: Bool = {
            guard let first = firstLaunchDate else { return false }
            let days = Calendar.current.dateComponents([.day], from: first, to: Date()).day ?? 0
            return days >= config.minDaysSinceFirstLaunch
        }()
        return launchesMet || daysMet
    }

    private func askLaterCooldownExpired() -> Bool {
        let launchCooldownMet: Bool = {
            let base = Double(config.askLaterCooldownLaunches)
            let scaled = base * pow(config.askLaterMultiplier, Double(deferCount - 1))
            let threshold = min(Int(scaled.rounded()), config.askLaterMaxCooldownLaunches)
            let launchesAtAskLater = defaults.integer(forKey: Key.askLaterLaunchCount)
            return (launchCount - launchesAtAskLater) >= threshold
        }()

        let dayCooldownMet: Bool = {
            guard let askDate = defaults.object(forKey: Key.askLaterDate) as? Date else { return false }
            let base = Double(config.askLaterCooldownDays)
            let scaled = base * pow(config.askLaterMultiplier, Double(deferCount - 1))
            let threshold = min(Int(scaled.rounded()), config.askLaterMaxCooldownDays)
            let days = Calendar.current.dateComponents([.day], from: askDate, to: Date()).day ?? 0
            return days >= threshold
        }()

        return launchCooldownMet || dayCooldownMet
    }
}
