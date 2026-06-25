import TipKit

/// Shared TipKit `@Parameter` properties for global tip suppression.
///
/// Include whichever guards are relevant in each tip's `rules` array:
///
/// ```swift
/// struct MyTip: Tip {
///     var rules: [Rule] {
///         [
///             #Rule(TipKitGuard.$isEnabled)  { $0 },
///             #Rule(TipKitGuard.$isReady)    { $0 },
///             #Rule(TipKitGuard.$isAllowed)  { $0 },
///         ]
///     }
/// }
/// ```
///
/// Then drive the parameters from your app:
///
/// ```swift
/// // In App.init — tips won't fire until you set this:
/// TipKitGuard.isReady = true
///
/// // When presenting a sheet over tip-bearing views:
/// .onChange(of: isSheetPresented) { TipKitGuard.isAllowed = !$0 }
///
/// // Master kill switch (e.g. user setting):
/// TipKitGuard.isEnabled = userPreferences.showTips
/// ```
public enum TipKitGuard {

    /// Master on/off switch. Set to `false` to suppress all participating tips immediately.
    /// Default: `true`.
    @Parameter public static var isEnabled: Bool = true

    /// Guards against tips firing during app startup (splash screens, loading states).
    /// Set to `true` once the app's root UI is fully visible.
    /// Default: `false` — you must opt in by setting this to `true`.
    @Parameter public static var isReady: Bool = false

    /// Guards against tips firing when a sheet or modal covers the anchor view.
    /// Set to `false` before presenting a sheet, `true` when it dismisses.
    /// Default: `true`.
    @Parameter public static var isAllowed: Bool = true
}
