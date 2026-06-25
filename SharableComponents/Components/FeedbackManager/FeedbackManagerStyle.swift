import SwiftUI

/// Visual styling for the FeedbackManager button and sheet.
/// All properties have sensible defaults — only override what you need.
public struct FeedbackManagerStyle {

    // MARK: - Trigger button

    /// SF Symbol name for the feedback button icon. Default: "bubble.left.and.text.bubble.right".
    public var buttonSymbol: String = "bubble.left.and.text.bubble.right"

    /// Optional label shown alongside the icon. Set to "" to show the icon only.
    public var buttonLabel: String = "Feedback"

    public var buttonFont: Font = .system(.callout, design: .rounded, weight: .semibold)
    public var buttonForegroundColor: Color = .accentColor
    public var buttonBackgroundColor: Color = Color(.secondarySystemBackground)
    public var buttonCornerRadius: CGFloat = 12
    public var buttonPadding: EdgeInsets = EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 14)

    // MARK: - Sheet card

    public var sheetBackgroundColor: Color = Color(.systemBackground)
    public var sheetCornerRadius: CGFloat = 20

    // MARK: - Sheet typography

    public var titleFont: Font = .system(.title3, design: .rounded, weight: .bold)
    public var messageFont: Font = .system(.subheadline, design: .rounded)
    public var labelFont: Font = .system(.footnote, design: .rounded, weight: .medium)

    // MARK: - Sheet buttons

    public var primaryButtonFont: Font = .system(.callout, design: .rounded, weight: .semibold)
    public var primaryButtonColor: Color = .accentColor
    public var primaryButtonTextColor: Color = .white
    public var primaryButtonCornerRadius: CGFloat = 12

    public var cancelButtonFont: Font = .system(.callout, design: .rounded)
    public var cancelButtonTextColor: Color = Color(.secondaryLabel)

    public init() {}
}
