import SwiftUI

/// Centered card overlay that prompts the user to rate the app, then deep-links to the App Store.
/// Not presented directly — use the `.appReviewRequest()` view modifier instead.
struct AppReviewRequestView: View {

    let config: AppReviewRequestConfig
    let manager: AppReviewRequestManager

    private var style: AppReviewRequestStyle { config.style }

    var body: some View {
        ZStack {
            style.backdropColor
                .ignoresSafeArea()
                .accessibilityHidden(true)

            card
                .padding(.horizontal, 32)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
        .accessibilityAddTraits(.isModal)
    }

    // MARK: - Card

    private var card: some View {
        VStack(spacing: 20) {
            headerText
            actionButtons
        }
        .padding(style.padding)
        .background(
            RoundedRectangle(cornerRadius: style.cornerRadius)
                .fill(style.backgroundColor)
                .shadow(color: .black.opacity(style.shadowOpacity), radius: style.shadowRadius, y: 8)
        )
    }

    // MARK: - Header

    private var headerText: some View {
        VStack(spacing: 8) {
            Text(config.title)
                .font(style.titleFont)
                .multilineTextAlignment(.center)

            Text(config.message)
                .font(style.messageFont)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Buttons

    private var actionButtons: some View {
        VStack(spacing: 10) {
            Button {
                manager.openAppStorePage()
            } label: {
                Text(config.submitButtonTitle)
                    .font(style.buttonFont)
                    .foregroundStyle(style.primaryButtonTextColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: style.buttonCornerRadius)
                            .fill(style.primaryButtonColor)
                    )
            }

            Button {
                manager.recordAskLater()
            } label: {
                Text(config.maybeLaterButtonTitle)
                    .font(style.buttonFont)
                    .foregroundStyle(style.secondaryButtonTextColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    AppReviewRequestView(
        config: {
            var c = AppReviewRequestConfig(appStoreID: "915056765")
            c.title = "Enjoying the app?"
            c.message = "It only takes a moment and means a lot to us."
            return c
        }(),
        manager: AppReviewRequestManager.shared
    )
}
