import SwiftUI

/// Visual styling for the InAppPurchase paywall.
/// All properties have sensible defaults — only override what you need.
public struct InAppPurchaseStyle {

    // MARK: - Background

    public var backgroundGradient: LinearGradient = LinearGradient(
        colors: [Color(.systemBackground), Color(.secondarySystemBackground)],
        startPoint: .top,
        endPoint: .bottom
    )

    // MARK: - App icon

    /// Show the app icon at the top of the paywall. Reads "AppIcon" from the asset catalog.
    public var showAppIcon: Bool = true
    public var appIconSize: CGFloat = 80
    public var appIconCornerRadius: CGFloat = 18

    // MARK: - Typography

    public var headlineFont: Font = .system(.title2, design: .rounded, weight: .bold)
    public var subtitleFont: Font = .system(.body, design: .rounded)
    public var priceFont: Font = .system(.title3, design: .rounded, weight: .semibold)
    public var buttonFont: Font = .system(.callout, design: .rounded, weight: .semibold)
    public var askLaterFont: Font = .system(.footnote, design: .rounded)
    public var restoreFont: Font = .system(.footnote, design: .rounded)

    // MARK: - Primary button

    public var primaryButtonColor: Color = .accentColor
    public var primaryButtonTextColor: Color = .white
    public var buttonCornerRadius: CGFloat = 14

    // MARK: - Secondary / tertiary

    public var askLaterTextColor: Color = Color(.secondaryLabel)
    public var restoreTextColor: Color = Color(.tertiaryLabel)

    // MARK: - Price badge

    public var priceBadgeBackgroundColor: Color = Color(.tertiarySystemFill)
    public var priceBadgeCornerRadius: CGFloat = 10

    public init() {}
}
