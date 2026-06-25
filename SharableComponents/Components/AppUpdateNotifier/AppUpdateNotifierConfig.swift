//
//  AppUpdateNotifierConfig.swift
//  SharableComponents
//

import Foundation

/// Configuration for the update notifier sheet shown once per app version.
///
/// Bundle with the release notes at build time. The sheet appears automatically
/// on first launch after a new version is installed and can be permanently
/// suppressed by the user for that version.
///
/// ```swift
/// var config = AppUpdateNotifierConfig(
///     appName: "MyApp",
///     version: "2.1",
///     releaseDate: "June 2025",
///     enhancements: ["Faster search", "New color themes"],
///     bugFixes: ["Fixed crash on startup"]
/// )
/// AppUpdateNotifierManager.shared.configure(config)
/// ```
public struct AppUpdateNotifierConfig {

    /// Display name shown in the sheet header.
    public var appName: String

    /// Version label shown in the sheet header (e.g. "2.1" or "2.1.0").
    /// Used for display only — the manager compares `CFBundleShortVersionString`
    /// against UserDefaults to determine whether the sheet should appear.
    public var version: String

    /// Human-readable release date shown beneath the version (e.g. "June 25, 2025").
    public var releaseDate: String

    /// Optional freeform message displayed centered above the Enhancements list.
    /// Use it for a personal note, release highlight, or anything that doesn't
    /// fit a bullet point. Pass `nil` to suppress it entirely.
    public var message: String?

    /// Bullet-point list of new features and improvements. Pass an empty array
    /// to suppress the Enhancements section entirely.
    public var enhancements: [String]

    /// Bullet-point list of bug fixes. Pass an empty array to suppress the
    /// Bug Fixes section entirely.
    public var bugFixes: [String]

    /// UserDefaults suite name used to store the dismissed-version flag.
    /// Use an App Group suite (e.g. "group.com.yourapp") when sharing state
    /// across extensions, or `nil` to use `UserDefaults.standard`.
    public var suiteName: String?

    public init(
        appName: String,
        version: String,
        releaseDate: String = "",
        message: String? = nil,
        enhancements: [String] = [],
        bugFixes: [String] = [],
        suiteName: String? = nil
    ) {
        self.appName      = appName
        self.version      = version
        self.releaseDate  = releaseDate
        self.message      = message
        self.enhancements = enhancements
        self.bugFixes     = bugFixes
        self.suiteName    = suiteName
    }
}
