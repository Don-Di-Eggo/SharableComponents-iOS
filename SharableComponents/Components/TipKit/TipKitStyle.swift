import SwiftUI

/// Visual styling for the TipKit popover.
/// All properties have sensible defaults — only override what you need.
public struct TipKitStyle {

    // MARK: - Popover sizing

    /// Fixed width of the popover content. This is the key guard against text truncation.
    /// Default: 300 — wide enough for two lines of body text on all iPhone sizes.
    public var popoverWidth: CGFloat = 300

    /// Inner padding of the popover card.
    public var padding: CGFloat = 20

    // MARK: - Colors

    public var backgroundColor: Color = Color(.systemBackground)
    public var titleColor: Color = .primary
    public var messageColor: Color = .secondary
    public var iconColor: Color = .accentColor
    public var dismissButtonBackgroundColor: Color = .accentColor
    public var dismissButtonTextColor: Color = .white

    // MARK: - Typography

    public var titleFont: Font = .system(.subheadline, design: .rounded, weight: .bold)
    public var messageFont: Font = .system(.footnote, design: .rounded)
    public var dismissButtonFont: Font = .system(.footnote, design: .rounded, weight: .bold)

    public init() {}
}
