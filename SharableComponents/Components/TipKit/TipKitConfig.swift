import SwiftUI
import TipKit

/// All configuration for the TipKit component.
/// Create one instance and pass it to `.tipPopover(_:config:)`.
public struct TipKitConfig {

    // MARK: - Popover

    /// Which edge the popover arrow emerges from.
    /// `nil` (default) — auto-detected from the anchor's screen position so the popover
    /// stays on screen. Set explicitly to override auto-detection.
    public var arrowEdge: Edge? = nil

    /// Label for the dismiss button. Default: "Got It".
    public var dismissButtonTitle: String = "Got It"

    // MARK: - Styling

    public var style: TipKitStyle = TipKitStyle()

    // MARK: - Init

    public init() {}
}
