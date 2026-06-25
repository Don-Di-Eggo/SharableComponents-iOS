import SwiftUI

/// Visual styling for the App Review Request overlay.
/// All properties have sensible defaults — only override what you need.
public struct AppReviewRequestStyle {

    // MARK: - Card

    public var backgroundColor: Color = Color(.systemBackground)
    public var cornerRadius: CGFloat = 20
    public var shadowRadius: CGFloat = 24
    public var shadowOpacity: Double = 0.15
    public var padding: CGFloat = 24

    // MARK: - Typography

    public var titleFont: Font = .system(.title3, design: .rounded, weight: .bold)
    public var messageFont: Font = .system(.subheadline, design: .rounded)
    public var buttonFont: Font = .system(.callout, design: .rounded, weight: .semibold)

    // MARK: - Buttons

    public var primaryButtonColor: Color = .accentColor
    public var primaryButtonTextColor: Color = .white
    public var secondaryButtonTextColor: Color = Color(.label)
    public var buttonCornerRadius: CGFloat = 12

    // MARK: - Overlay backdrop

    public var backdropColor: Color = Color(.black).opacity(0.4)

    public init() {}
}
