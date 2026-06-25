import SwiftUI
import TipKit

public extension View {

    /// Attaches a styled tip popover anchored to this view.
    ///
    /// Uses a custom `.popover()` presentation with a fixed content width to prevent
    /// text truncation. The arrow edge is auto-detected from the anchor's screen position
    /// so the popover stays within the visible area. Automatically suppressed on Mac Catalyst.
    /// Respects view visibility — the popover will not appear on inactive tabs.
    ///
    /// Usage:
    /// ```swift
    /// Image(systemName: "star")
    ///     .tipPopover(MyTip())
    ///
    /// // Override the auto-detected arrow edge:
    /// Image(systemName: "gear")
    ///     .tipPopover(MyTip(), config: {
    ///         var c = TipKitConfig()
    ///         c.arrowEdge = .top
    ///         return c
    ///     }())
    /// ```
    func tipPopover<T: Tip>(
        _ tip: T,
        config: TipKitConfig = TipKitConfig()
    ) -> some View {
        self.modifier(TipPopoverModifier(tip: tip, config: config))
    }
}

// MARK: - Modifier

private struct TipPopoverModifier<T: Tip>: ViewModifier {

    let tip: T
    let config: TipKitConfig

    @State private var isPresented = false
    @State private var isViewVisible = false
    @State private var anchorFrame: CGRect = .zero

    /// Auto-picks the arrow edge that keeps the popover on screen.
    /// If the caller explicitly set an edge in config, that wins.
    private var effectiveArrowEdge: Edge {
        if let explicit = config.arrowEdge { return explicit }
        let screenHeight = UIScreen.main.bounds.height
        // Anchor in top 40% of screen → popover opens below (arrow points up)
        return anchorFrame.midY < screenHeight * 0.4 ? .top : .bottom
    }

    func body(content: Content) -> some View {
        #if targetEnvironment(macCatalyst)
        content
        #else
        content
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            anchorFrame = geo.frame(in: .global)
                        }
                        .onChange(of: geo.frame(in: .global)) { _, frame in
                            anchorFrame = frame
                        }
                }
            )
            .popover(isPresented: $isPresented, arrowEdge: effectiveArrowEdge) {
                TipPopoverView(tip: tip, config: config, isPresented: $isPresented)
                    .presentationCompactAdaptation(.popover)
            }
            .onAppear {
                isViewVisible = true
                if case .available = tip.status { isPresented = true }
            }
            .onDisappear {
                isViewVisible = false
                isPresented = false
            }
            .task {
                for await shouldDisplay in tip.shouldDisplayUpdates {
                    guard isViewVisible else { continue }
                    isPresented = shouldDisplay
                }
            }
        #endif
    }
}
