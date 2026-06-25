import Foundation
import Testing
@testable import SharableComponents

// Each test gets its own UserDefaults suite name so state never bleeds between tests.
// The manager is a singleton, so reset() + configure() is the isolation pattern.

// .serialized prevents parallel execution — required because InAppPurchaseManager is a singleton
// and tests mutate its in-memory state via configure() + reset().
@Suite(.serialized)
@MainActor
struct InAppPurchaseTests {

    // MARK: - Helpers

    private func makeConfig(suite: String, minLaunches: Int = 3, steps: [Int] = [2, 1]) -> InAppPurchaseConfig {
        var c = InAppPurchaseConfig(productID: "com.test.unlock")
        c.minLaunches = minLaunches
        c.minDaysSinceFirstLaunch = 9999    // effectively off — use launch count only in tests
        c.deferralSteps = steps
        c.userDefaultsSuiteName = suite
        return c
    }

    private func configured(suite: String, minLaunches: Int = 3, steps: [Int] = [2, 1]) -> InAppPurchaseManager {
        let m = InAppPurchaseManager.shared
        m.configure(makeConfig(suite: suite, minLaunches: minLaunches, steps: steps))
        m.reset()
        return m
    }

    // MARK: - Free trial

    @Test("Paywall does not appear before minLaunches")
    func noPaywallBeforeThreshold() async {
        let m = configured(suite: "test.before.threshold", minLaunches: 3)

        await m.recordLaunch()
        await m.recordLaunch()

        #expect(m.shouldShowPaywall == false)
        #expect(m.isBlocked == false)
    }

    @Test("Paywall appears exactly at minLaunches")
    func paywallAppearsAtThreshold() async {
        let m = configured(suite: "test.at.threshold", minLaunches: 3)

        await m.recordLaunch()
        await m.recordLaunch()
        #expect(m.shouldShowPaywall == false)

        await m.recordLaunch()
        #expect(m.shouldShowPaywall == true)
        #expect(m.isBlocked == false)
    }

    @Test("nextDeferralLaunches reflects first deferral step when paywall first appears")
    func firstDeferralStepShown() async {
        let m = configured(suite: "test.first.step", minLaunches: 2, steps: [5, 3, 1])

        await m.recordLaunch()
        await m.recordLaunch()

        #expect(m.shouldShowPaywall == true)
        #expect(m.nextDeferralLaunches == 5)
    }

    // MARK: - Deferral steps

    @Test("Paywall hides after Ask Later, reappears after cooldown launches")
    func deferralCooldown() async {
        let m = configured(suite: "test.deferral.cooldown", minLaunches: 2, steps: [3, 2])

        await m.recordLaunch()
        await m.recordLaunch()  // triggers
        #expect(m.shouldShowPaywall == true)

        m.recordAskLater()      // step[0] = 3 launches cooldown
        #expect(m.shouldShowPaywall == false)

        await m.recordLaunch()
        await m.recordLaunch()
        #expect(m.shouldShowPaywall == false)  // only 2 launches elapsed, need 3

        await m.recordLaunch()
        #expect(m.shouldShowPaywall == true)   // 3 launches elapsed — reappears
        #expect(m.isBlocked == false)
        #expect(m.nextDeferralLaunches == 2)   // step[1]
    }

    @Test("Second deferral uses next step size")
    func secondDeferralStep() async {
        let m = configured(suite: "test.second.step", minLaunches: 1, steps: [2, 1])

        await m.recordLaunch()  // triggers
        m.recordAskLater()      // step[0] = 2 launches

        await m.recordLaunch()
        await m.recordLaunch()  // cooldown passes
        #expect(m.shouldShowPaywall == true)
        #expect(m.nextDeferralLaunches == 1)  // step[1]

        m.recordAskLater()      // step[1] = 1 launch

        await m.recordLaunch()
        #expect(m.shouldShowPaywall == true)
        #expect(m.isBlocked == true)   // steps exhausted → hard block
        #expect(m.nextDeferralLaunches == nil)
    }

    // MARK: - Hard block

    @Test("Paywall becomes non-dismissable when all deferral steps exhausted")
    func hardBlock() async {
        let m = configured(suite: "test.hard.block", minLaunches: 1, steps: [1])

        await m.recordLaunch()  // triggers
        #expect(m.isBlocked == false)

        m.recordAskLater()      // one step available

        await m.recordLaunch()  // cooldown passes, steps now exhausted
        #expect(m.shouldShowPaywall == true)
        #expect(m.isBlocked == true)
        #expect(m.nextDeferralLaunches == nil)

        // Stays blocked on subsequent launches
        await m.recordLaunch()
        #expect(m.isBlocked == true)
    }

    // MARK: - Reset

    @Test("reset() clears all state")
    func resetClearsState() async {
        let m = configured(suite: "test.reset", minLaunches: 1, steps: [1])

        await m.recordLaunch()
        #expect(m.shouldShowPaywall == true)

        m.reset()
        #expect(m.shouldShowPaywall == false)
        #expect(m.isBlocked == false)
        #expect(m.isPurchased == false)

        // After reset, a fresh launch below threshold shows nothing
        var config = makeConfig(suite: "test.reset", minLaunches: 5)
        InAppPurchaseManager.shared.configure(config)
        await m.recordLaunch()
        #expect(m.shouldShowPaywall == false)
    }

    // MARK: - Keychain restore (reinstall simulation)

    @Test("State restores from Keychain after UserDefaults wipe")
    func keychainRestoreAfterReinstall() async {
        let suite = "test.keychain.restore"
        let m = configured(suite: suite, minLaunches: 2, steps: [3])

        // Build up state past the trigger
        await m.recordLaunch()
        await m.recordLaunch()
        #expect(m.shouldShowPaywall == true)

        // Simulate reinstall by wiping UserDefaults only (Keychain is untouched)
        let defaults = UserDefaults(suiteName: suite)!
        for key in ["iap_firstLaunchDate", "iap_launchCount", "iap_state",
                    "iap_deferralIndex", "iap_deferralTargetLaunch"] {
            defaults.removeObject(forKey: key)
        }

        // Next launch should restore from Keychain and still show the paywall
        await m.recordLaunch()
        #expect(m.shouldShowPaywall == true)
    }

    @Test("Fresh install (no Keychain data) starts a clean free trial")
    func freshInstallStartsCleanTrial() async {
        let m = configured(suite: "test.fresh.install", minLaunches: 5, steps: [3])
        // reset() already cleared both UserDefaults and Keychain
        await m.recordLaunch()
        #expect(m.shouldShowPaywall == false)
    }
}
