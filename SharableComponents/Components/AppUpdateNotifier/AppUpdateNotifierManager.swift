//
//  AppUpdateNotifierManager.swift
//  SharableComponents
//

import Foundation
import Observation

/// Manages the show/suppress state for the update notifier sheet.
///
/// Call `configure(_:)` once at app startup.
///
/// ```swift
/// // In App.init:
/// var config = AppUpdateNotifierConfig(
///     appName: "MyApp",
///     version: "2.1",
///     releaseDate: "June 2025",
///     enhancements: ["Faster search"],
///     bugFixes: ["Fixed crash on startup"]
/// )
/// AppUpdateNotifierManager.shared.configure(config)
///
/// // On root view:
/// ContentView()
///     .appUpdateNotifier()
/// ```
@Observable
public final class AppUpdateNotifierManager {

    // MARK: - Singleton

    public static let shared = AppUpdateNotifierManager()

    // MARK: - Public state

    /// True when the sheet should be presented.
    ///
    /// Becomes false immediately after `dismiss()` or `suppressForThisVersion()`.
    /// Resets to true on the next launch after a new app version is installed,
    /// unless `suppressForThisVersion()` was called for that version.
    public private(set) var shouldShow: Bool = false

    /// The active configuration. Set by `configure(_:)`.
    public private(set) var config: AppUpdateNotifierConfig = AppUpdateNotifierConfig(
        appName: "", version: "", releaseDate: ""
    )

    // MARK: - Configuration

    /// Evaluates whether the sheet should appear and arms `shouldShow`.
    ///
    /// Comparison is against `CFBundleShortVersionString`, not `config.version`.
    /// A mismatch between the stored dismissed version and the current bundle
    /// version is treated as a new release.
    public func configure(_ config: AppUpdateNotifierConfig) {
        self.config   = config
        self.defaults = UserDefaults(suiteName: config.suiteName) ?? .standard

        let currentVersion = bundleShortVersion
        let dismissed      = defaults.string(forKey: Keys.dismissedVersion)
        shouldShow = dismissed != currentVersion
    }

    // MARK: - Actions

    /// Hides the sheet for this session. It will re-appear on the next launch.
    public func dismiss() {
        shouldShow = false
    }

    /// Hides the sheet and prevents it from appearing again for this app version.
    /// The sheet will re-appear automatically when a future version is installed.
    public func suppressForThisVersion() {
        defaults.set(bundleShortVersion, forKey: Keys.dismissedVersion)
        shouldShow = false
    }

    // MARK: - Private

    @ObservationIgnored
    private var defaults: UserDefaults = .standard

    private var bundleShortVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    }

    private enum Keys {
        static let dismissedVersion = "appUpdateNotifier.dismissedVersion"
    }
}
