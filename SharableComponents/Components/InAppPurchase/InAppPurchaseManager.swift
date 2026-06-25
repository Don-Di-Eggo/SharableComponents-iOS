import SwiftUI
import Combine
import StoreKit

/// Tracks the free trial window, escalating deferral state, and StoreKit purchase flow.
/// Call `configure(_:)` once at app startup, then `recordLaunch()` on each launch.
/// Observe `shouldShowPaywall` and `isBlocked` to drive the `.inAppPurchase()` modifier.
///
/// Trial state is mirrored to the Keychain so it survives app deletion and reinstall.
@MainActor
public final class InAppPurchaseManager: ObservableObject {

    public static let shared = InAppPurchaseManager()

    // MARK: - Published state

    @Published public private(set) var shouldShowPaywall: Bool = false
    /// True when all deferrals are exhausted — paywall cannot be dismissed.
    @Published public private(set) var isBlocked: Bool = false
    @Published public private(set) var isPurchased: Bool = false
    @Published public private(set) var isPurchasing: Bool = false
    @Published public private(set) var purchaseError: String? = nil
    /// Auto-fetched localized price string from StoreKit (e.g. "$2.99"). Nil until product loads.
    @Published public private(set) var displayPrice: String? = nil
    /// Launches offered on the next "Ask Later" tap. Nil when no more deferrals remain.
    @Published public private(set) var nextDeferralLaunches: Int? = nil

    // MARK: - Config

    private(set) var config: InAppPurchaseConfig = InAppPurchaseConfig(productID: "")

    // MARK: - Private

    private var product: Product? = nil
    private var keychain: InAppPurchaseKeychain = InAppPurchaseKeychain(service: "InAppPurchase")

    // MARK: - Storage keys

    private enum Key {
        static let firstLaunchDate      = "iap_firstLaunchDate"
        static let launchCount          = "iap_launchCount"
        static let state                = "iap_state"
        static let deferralIndex        = "iap_deferralIndex"
        static let deferralTargetLaunch = "iap_deferralTargetLaunch"

        static let all = [firstLaunchDate, launchCount, state, deferralIndex, deferralTargetLaunch]
    }

    // MARK: - State machine

    private enum PurchaseState: String {
        case eligible   // Free trial — trigger conditions not yet met
        case deferred   // User tapped Ask Later; waiting for cooldown to pass
        case blocked    // All deferrals exhausted; hard block
        case purchased  // One-time purchase complete
    }

    // MARK: - Computed persisted values

    private var defaults: UserDefaults {
        if let suite = config.userDefaultsSuiteName {
            return UserDefaults(suiteName: suite) ?? .standard
        }
        return .standard
    }

    private var launchCount: Int          { defaults.integer(forKey: Key.launchCount) }
    private var deferralIndex: Int        { defaults.integer(forKey: Key.deferralIndex) }
    private var deferralTargetLaunch: Int { defaults.integer(forKey: Key.deferralTargetLaunch) }

    private var firstLaunchDate: Date? {
        defaults.object(forKey: Key.firstLaunchDate) as? Date
    }

    private var currentState: PurchaseState {
        guard let raw = defaults.string(forKey: Key.state),
              let state = PurchaseState(rawValue: raw) else { return .eligible }
        return state
    }

    private init() {}

    // MARK: - Public API

    /// Call once at app startup before `recordLaunch()`.
    public func configure(_ config: InAppPurchaseConfig) {
        self.config = config
        self.keychain = InAppPurchaseKeychain(
            service: config.userDefaultsSuiteName ?? Bundle.main.bundleIdentifier ?? "InAppPurchase"
        )
    }

    /// Call once per app launch (e.g., in your App's `init` or `onAppear` on the root view).
    public func recordLaunch() async {
        restoreFromKeychainIfNeeded()
        seedFirstLaunchDateIfNeeded()
        incrementLaunchCount()
        await fetchProductIfNeeded()
        await checkEntitlementIfNeeded()
        evaluate()
    }

    /// Call after the user taps the "Ask Later" button.
    public func recordAskLater() {
        let i = deferralIndex
        guard i < config.deferralSteps.count else { return }

        let target = launchCount + config.deferralSteps[i]
        persist(int: target, forKey: Key.deferralTargetLaunch)
        persist(int: i + 1,  forKey: Key.deferralIndex)
        persist(string: PurchaseState.deferred.rawValue, forKey: Key.state)
        evaluate()
    }

    /// Initiates the StoreKit purchase flow.
    public func purchase() async {
        guard let product else { return }
        isPurchasing = true
        purchaseError = nil
        defer { isPurchasing = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try verification.payloadValue
                await transaction.finish()
                markPurchased()
            case .userCancelled:
                break
            case .pending:
                break
            @unknown default:
                break
            }
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    /// Restores previous purchases. Call when the user taps "Restore Purchase".
    public func restorePurchases() async {
        isPurchasing = true
        purchaseError = nil
        defer { isPurchasing = false }

        do {
            try await AppStore.sync()
            await checkEntitlementIfNeeded()
            evaluate()
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    /// Resets all persisted state — UserDefaults and Keychain. Useful for testing; do not call in production.
    public func reset() {
        Key.all.forEach { defaults.removeObject(forKey: $0) }
        keychain.removeAll(keys: Key.all)
        shouldShowPaywall = false
        isBlocked = false
        isPurchased = false
        nextDeferralLaunches = nil
    }

    // MARK: - Persistence helpers

    /// Writes to both UserDefaults and the Keychain so state survives reinstall.
    private func persist(int value: Int, forKey key: String) {
        defaults.set(value, forKey: key)
        keychain.setInt(value, forKey: key)
    }

    private func persist(string value: String, forKey key: String) {
        defaults.set(value, forKey: key)
        keychain.setString(value, forKey: key)
    }

    private func persist(date value: Date, forKey key: String) {
        defaults.set(value, forKey: key)
        keychain.setDate(value, forKey: key)
    }

    /// On a fresh install UserDefaults is empty but Keychain may still hold prior state.
    /// Restore so returning users don't get a new free trial.
    private func restoreFromKeychainIfNeeded() {
        guard defaults.object(forKey: Key.firstLaunchDate) == nil,
              let savedDate = keychain.date(forKey: Key.firstLaunchDate) else { return }

        defaults.set(savedDate, forKey: Key.firstLaunchDate)

        if let v = keychain.int(forKey: Key.launchCount)          { defaults.set(v, forKey: Key.launchCount) }
        if let v = keychain.string(forKey: Key.state)             { defaults.set(v, forKey: Key.state) }
        if let v = keychain.int(forKey: Key.deferralIndex)        { defaults.set(v, forKey: Key.deferralIndex) }
        if let v = keychain.int(forKey: Key.deferralTargetLaunch) { defaults.set(v, forKey: Key.deferralTargetLaunch) }
    }

    // MARK: - Private helpers

    private func seedFirstLaunchDateIfNeeded() {
        guard defaults.object(forKey: Key.firstLaunchDate) == nil else { return }
        persist(date: Date(), forKey: Key.firstLaunchDate)
    }

    private func incrementLaunchCount() {
        persist(int: launchCount + 1, forKey: Key.launchCount)
    }

    private func fetchProductIfNeeded() async {
        guard product == nil, !config.productID.isEmpty else { return }
        do {
            let products = try await Product.products(for: [config.productID])
            if let p = products.first {
                product = p
                displayPrice = p.displayPrice
            }
        } catch {
            // Non-fatal; displayPrice remains nil until next successful fetch
        }
    }

    private func checkEntitlementIfNeeded() async {
        guard !isPurchased else { return }
        for await result in Transaction.currentEntitlements {
            if let transaction = try? result.payloadValue,
               transaction.productID == config.productID {
                markPurchased()
                return
            }
        }
    }

    private func markPurchased() {
        persist(string: PurchaseState.purchased.rawValue, forKey: Key.state)
        isPurchased = true
        shouldShowPaywall = false
        isBlocked = false
        nextDeferralLaunches = nil
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

    private func evaluate() {
        guard !isPurchased else {
            shouldShowPaywall = false
            isBlocked = false
            return
        }

        switch currentState {
        case .purchased:
            markPurchased()

        case .eligible:
            let triggered = triggerConditionMet()
            shouldShowPaywall = triggered
            isBlocked = false
            nextDeferralLaunches = triggered ? config.deferralSteps.first : nil

        case .deferred:
            guard triggerConditionMet() else {
                shouldShowPaywall = false
                isBlocked = false
                return
            }
            if launchCount >= deferralTargetLaunch {
                let i = deferralIndex
                let exhausted = i >= config.deferralSteps.count
                shouldShowPaywall = true
                isBlocked = exhausted
                if exhausted {
                    persist(string: PurchaseState.blocked.rawValue, forKey: Key.state)
                    nextDeferralLaunches = nil
                } else {
                    nextDeferralLaunches = config.deferralSteps[i]
                }
            } else {
                shouldShowPaywall = false
                isBlocked = false
            }

        case .blocked:
            shouldShowPaywall = true
            isBlocked = true
            nextDeferralLaunches = nil
        }
    }
}
