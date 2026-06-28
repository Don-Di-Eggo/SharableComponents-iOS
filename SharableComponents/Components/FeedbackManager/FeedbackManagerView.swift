import SwiftUI

/// The in-app sheet presented when the user taps the feedback button.
/// Presents a category picker, then opens Mail with a pre-populated draft.
public struct FeedbackManagerView: View {

    let config: FeedbackManagerConfig
    @Binding var isPresented: Bool

    @State private var selectedCategory: String
    @State private var mailErrorAlertShown = false

    public init(config: FeedbackManagerConfig, isPresented: Binding<Bool>) {
        self.config = config
        self._isPresented = isPresented
        self._selectedCategory = State(initialValue: config.subjectCategories.first ?? "")
    }

    private var style: FeedbackManagerStyle { config.style }

    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            header
            categoryPicker
            Spacer()
            actionButtons
        }
        .padding(24)
        .background(style.sheetBackgroundColor)
        .alert("Mail Not Available", isPresented: $mailErrorAlertShown) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please set up a Mail account on this device to send feedback.")
        }
    }

    // MARK: - Subviews

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(config.sheetTitle)
                .font(style.titleFont)
            Text(config.sheetMessage)
                .font(style.messageFont)
                .foregroundStyle(Color(.secondaryLabel))
        }
    }

    private var categoryPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(config.categoryPickerLabel.uppercased())
                .font(style.labelFont)
                .foregroundStyle(Color(.secondaryLabel))
            Picker(config.categoryPickerLabel, selection: $selectedCategory) {
                ForEach(config.subjectCategories, id: \.self) { category in
                    Text(category).tag(category)
                }
            }
            .pickerStyle(.wheel)
            .frame(minHeight: 100, maxHeight: 160)
            .clipped()
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(config.sendButtonTitle) {
                openMail()
            }
            .font(style.primaryButtonFont)
            .foregroundStyle(style.primaryButtonTextColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(style.primaryButtonColor)
            .clipShape(RoundedRectangle(cornerRadius: style.primaryButtonCornerRadius))

            Button(config.cancelButtonTitle) {
                isPresented = false
            }
            .font(style.cancelButtonFont)
            .foregroundStyle(style.cancelButtonTextColor)
        }
    }

    // MARK: - Mail

    private func openMail() {
        let subject = mailSubject()
        let body = mailBody()

        var components = URLComponents()
        components.scheme = "mailto"
        components.path = config.recipientEmail
        components.queryItems = [
            URLQueryItem(name: "subject", value: subject),
            URLQueryItem(name: "body", value: body)
        ]

        guard let url = components.url else { return }

        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
            isPresented = false
        } else {
            mailErrorAlertShown = true
        }
    }

    private func mailSubject() -> String {
        let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
            ?? Bundle.main.infoDictionary?["CFBundleName"] as? String
            ?? "App"
        return "[\(appName)] \(selectedCategory)"
    }

    private func mailBody() -> String {
        var parts: [String] = []

        if !config.bodyIntro.isEmpty {
            parts.append(config.bodyIntro + "\n\n")
        }

        let categoryIndex = config.subjectCategories.firstIndex(of: selectedCategory) ?? -1
        let matchedPrompts = config.categoryPrompts.indices.contains(categoryIndex)
            ? config.categoryPrompts[categoryIndex]
            : []

        if matchedPrompts.isEmpty {
            parts.append("\n\n")
        } else {
            let promptBlock = matchedPrompts
                .map { "\($0)\n\n" }
                .joined()
            parts.append(promptBlock)
        }

        if config.includeSystemInfo {
            parts.append(systemInfoBlock())
        }

        return parts.joined()
    }

    private func systemInfoBlock() -> String {
        let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
            ?? Bundle.main.infoDictionary?["CFBundleName"] as? String
            ?? "Unknown"
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"

        #if targetEnvironment(macCatalyst)
        let osLabel = "macOS"
        let osVersion = ProcessInfo.processInfo.operatingSystemVersionString
        let model = "Mac"
        #else
        let osLabel = "iOS"
        let osVersion = UIDevice.current.systemVersion
        let model = UIDevice.current.model
        #endif

        let customerID = CustomerIdentifier(suiteName: config.suiteName).id

        return """
        ---
        App: \(appName) \(appVersion) (\(buildNumber))
        \(osLabel): \(osVersion)
        Device: \(model)
        ID: \(customerID)
        ---
        """
    }
}

// MARK: - Preview

#Preview("Feedback Sheet") {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            FeedbackManagerView(
                config: FeedbackManagerConfig(),
                isPresented: .constant(true)
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
}
