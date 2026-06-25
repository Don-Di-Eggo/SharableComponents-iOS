import SwiftUI

/// Full-screen paywall presented when the free trial expires.
/// Not presented directly — use the `.inAppPurchase()` view modifier instead.
struct InAppPurchasePaywallView: View {

    let config: InAppPurchaseConfig
    @ObservedObject var manager: InAppPurchaseManager

    private var style: InAppPurchaseStyle { config.style }

    var body: some View {
        ZStack {
            style.backgroundGradient
                .ignoresSafeArea()
                .accessibilityHidden(true)

            VStack(spacing: 0) {
                Spacer()
                content
                Spacer()
                footerButtons
                    .padding(.bottom, 32)
            }
            .padding(.horizontal, 32)
        }
        .accessibilityAddTraits(.isModal)
        .interactiveDismissDisabled(manager.isBlocked)
        .alert("Error", isPresented: .constant(manager.purchaseError != nil)) {
            Button("OK") { }
        } message: {
            Text(manager.purchaseError ?? "")
        }
    }

    // MARK: - Content

    private var content: some View {
        VStack(spacing: 24) {
            if style.showAppIcon {
                appIcon
            }

            VStack(spacing: 10) {
                Text(config.headline)
                    .font(style.headlineFont)
                    .multilineTextAlignment(.center)

                Text(config.subtitle)
                    .font(style.subtitleFont)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            if let price = manager.displayPrice {
                priceBadge(price)
            }

            purchaseButton
        }
    }

    // MARK: - App Icon

    private var appIcon: some View {
        Group {
            if let uiImage = UIImage(named: "AppIcon") {
                Image(uiImage: uiImage)
                    .resizable()
                    .frame(width: style.appIconSize, height: style.appIconSize)
                    .clipShape(RoundedRectangle(cornerRadius: style.appIconCornerRadius))
                    .accessibilityHidden(true)
            }
        }
    }

    // MARK: - Price badge

    private func priceBadge(_ price: String) -> some View {
        Text("One-time purchase · \(price)")
            .font(style.priceFont)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: style.priceBadgeCornerRadius)
                    .fill(style.priceBadgeBackgroundColor)
            )
    }

    // MARK: - Purchase button

    private var purchaseButton: some View {
        Button {
            Task { await manager.purchase() }
        } label: {
            Group {
                if manager.isPurchasing {
                    ProgressView()
                        .tint(style.primaryButtonTextColor)
                } else {
                    Text(config.purchaseButtonTitle)
                        .font(style.buttonFont)
                        .foregroundStyle(style.primaryButtonTextColor)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: style.buttonCornerRadius)
                    .fill(style.primaryButtonColor)
            )
        }
        .disabled(manager.isPurchasing)
        .accessibilityLabel(manager.isPurchasing ? "Purchasing" : config.purchaseButtonTitle)
    }

    // MARK: - Footer

    private var footerButtons: some View {
        VStack(spacing: 16) {
            if !manager.isBlocked, let launches = manager.nextDeferralLaunches {
                Button {
                    manager.recordAskLater()
                } label: {
                    Text(String(format: config.askLaterFormat, launches))
                        .font(style.askLaterFont)
                        .foregroundStyle(style.askLaterTextColor)
                }
            }

            Button {
                Task { await manager.restorePurchases() }
            } label: {
                Text(config.restoreButtonTitle)
                    .font(style.restoreFont)
                    .foregroundStyle(style.restoreTextColor)
            }
            .disabled(manager.isPurchasing)
        }
    }
}

// MARK: - Preview

#Preview("Paywall — deferrals available") {
    InAppPurchasePaywallView(
        config: {
            var c = InAppPurchaseConfig(productID: "com.example.app.unlock")
            c.headline = "Unlock the Full App"
            c.subtitle = "Get unlimited access to everything."
            return c
        }(),
        manager: InAppPurchaseManager.shared
    )
}

#Preview("Paywall — hard block") {
    let manager = InAppPurchaseManager.shared
    return InAppPurchasePaywallView(
        config: {
            var c = InAppPurchaseConfig(productID: "com.example.app.unlock")
            c.headline = "Your Free Trial Has Ended"
            c.subtitle = "Unlock the app to keep going."
            return c
        }(),
        manager: manager
    )
}
