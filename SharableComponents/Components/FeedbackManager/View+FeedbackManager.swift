import SwiftUI

public extension View {

    /// Attaches a feedback button to this view using the provided configuration.
    ///
    /// The button opens an in-app sheet where the user picks a feedback category,
    /// then hands off to the Mail app with a pre-populated draft.
    ///
    /// Usage:
    /// ```swift
    /// var config = FeedbackManagerConfig()
    /// config.recipientEmail = "you@example.com"
    ///
    /// ContentView()
    ///     .feedbackButton(config: config)
    /// ```
    func feedbackButton(config: FeedbackManagerConfig = FeedbackManagerConfig()) -> some View {
        self.modifier(FeedbackButtonModifier(config: config))
    }
}

// MARK: - Modifier

private struct FeedbackButtonModifier: ViewModifier {
    let config: FeedbackManagerConfig
    @State private var isSheetPresented = false

    func body(content: Content) -> some View {
        content.toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                FeedbackButtonView(config: config, isSheetPresented: $isSheetPresented)
            }
        }
        .sheet(isPresented: $isSheetPresented) {
            FeedbackManagerView(config: config, isPresented: $isSheetPresented)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Standalone button

/// A standalone feedback button you can place anywhere in your layout.
/// Use this when `.feedbackButton()` toolbar placement doesn't suit your design.
public struct FeedbackButtonView: View {

    let config: FeedbackManagerConfig
    @Binding var isSheetPresented: Bool

    private var style: FeedbackManagerStyle { config.style }

    public init(config: FeedbackManagerConfig = FeedbackManagerConfig(), isSheetPresented: Binding<Bool>) {
        self.config = config
        self._isSheetPresented = isSheetPresented
    }

    public var body: some View {
        Button {
            isSheetPresented = true
        } label: {
            HStack(spacing: 6) {
                Image(systemName: style.buttonSymbol)
                    .accessibilityHidden(true)
                if !style.buttonLabel.isEmpty {
                    Text(style.buttonLabel)
                }
            }
            .font(style.buttonFont)
            .foregroundStyle(style.buttonForegroundColor)
            .padding(style.buttonPadding)
            .background(style.buttonBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: style.buttonCornerRadius))
        }
        .accessibilityLabel(style.buttonLabel.isEmpty ? "Feedback" : style.buttonLabel)
    }
}

// MARK: - Previews

#Preview("Toolbar Button") {
    NavigationStack {
        List {
            Text("Settings")
            Text("Profile")
        }
        .navigationTitle("My App")
        .feedbackButton()
    }
}

#Preview("Standalone Button") {
    @Previewable @State var isPresented = false

    VStack {
        FeedbackButtonView(config: FeedbackManagerConfig(), isSheetPresented: $isPresented)
    }
    .sheet(isPresented: $isPresented) {
        FeedbackManagerView(config: FeedbackManagerConfig(), isPresented: $isPresented)
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
    }
}
