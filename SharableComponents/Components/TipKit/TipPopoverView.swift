import SwiftUI
import TipKit

/// Fixed-width popover content that prevents text truncation.
/// Not used directly — presented via the `.tipPopover()` modifier.
struct TipPopoverView<T: Tip>: View {

    let tip: T
    let config: TipKitConfig
    @Binding var isPresented: Bool

    private var style: TipKitStyle { config.style }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            messageText
            dismissButton
        }
        .padding(style.padding)
        .frame(width: style.popoverWidth, alignment: .leading)
        .background(style.backgroundColor)
    }

    // MARK: - Header

    @ViewBuilder
    private var header: some View {
        HStack(spacing: 8) {
            if let image = tip.image {
                image
                    .font(style.titleFont)
                    .foregroundStyle(style.iconColor)
                    .accessibilityHidden(true)
            }
            tip.title
                .font(style.titleFont)
                .foregroundStyle(style.titleColor)
        }
    }

    // MARK: - Message

    @ViewBuilder
    private var messageText: some View {
        if let message = tip.message {
            message
                .font(style.messageFont)
                .foregroundStyle(style.messageColor)
                // fixedSize lets text grow vertically rather than truncating
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(3)
        }
    }

    // MARK: - Dismiss button

    private var dismissButton: some View {
        Button {
            tip.invalidate(reason: .tipClosed)
            isPresented = false
        } label: {
            Text(config.dismissButtonTitle)
                .font(style.dismissButtonFont)
                .foregroundStyle(style.dismissButtonTextColor)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(style.dismissButtonBackgroundColor)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Dismiss tip")
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}
