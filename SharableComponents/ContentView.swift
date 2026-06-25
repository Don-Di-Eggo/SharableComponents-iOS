import SwiftUI
import TipKit

struct ContentView: View {
    var body: some View {
        TabView {
            FeedbackManagerTestView()
                .tabItem {
                    Label("Feedback", systemImage: "bubble.left.and.text.bubble.right")
                }

            AppReviewRequestTestView()
                .tabItem {
                    Label("Review Request", systemImage: "star.circle")
                }

            InAppPurchaseTestView()
                .tabItem {
                    Label("IAP", systemImage: "cart.circle")
                }

            TipKitTestView()
                .tabItem {
                    Label("Tips", systemImage: "lightbulb")
                }

            AppColorTestView()
                .tabItem {
                    Label("Color", systemImage: "paintpalette")
                }

            AppPaletteTestView()
                .tabItem {
                    Label("Palette", systemImage: "swatchpalette")
                }

            AppUpdateNotifierTestView()
                .tabItem {
                    Label("Updates", systemImage: "sparkles.rectangle.stack")
                }
        }
    }
}

// MARK: - AppReviewRequest test harness

private struct AppReviewRequestTestView: View {

    @ObservedObject private var manager = AppReviewRequestManager.shared

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "star.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.tint)

                Text("AppReviewRequest")
                    .font(.title2.bold())

                Text("Test harness")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Divider()

                VStack(spacing: 12) {
                    Button("Show Review Prompt") {
                        manager.reset()
                        var config = AppReviewRequestConfig(appStoreID: "915056765")
                        config.minLaunches = 0
                        config.minDaysSinceFirstLaunch = 0
                        config.title = "Enjoying SharableComponents?"
                        config.message = "Your review helps us improve."
                        manager.configure(config)
                        manager.recordLaunch()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    Button("Reset State") {
                        manager.reset()
                    }
                    .buttonStyle(.bordered)
                    .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Review Request")
            .navigationBarTitleDisplayMode(.inline)
            .appReviewRequest(manager: manager)
        }
    }
}

// MARK: - FeedbackManager test harness

private struct FeedbackManagerTestView: View {

    @State private var isSheetPresented = false

    private let config = FeedbackManagerConfig()

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "bubble.left.and.text.bubble.right.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.tint)

                Text("FeedbackManager")
                    .font(.title2.bold())

                Text("Tap the toolbar button or the one below to open the feedback sheet.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Divider()

                FeedbackButtonView(config: config, isSheetPresented: $isSheetPresented)

                Spacer()
            }
            .padding()
            .navigationTitle("Feedback")
            .navigationBarTitleDisplayMode(.inline)
            .feedbackButton(config: config)
            .sheet(isPresented: $isSheetPresented) {
                FeedbackManagerView(config: config, isPresented: $isSheetPresented)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}

// MARK: - InAppPurchase test harness

private struct InAppPurchaseTestView: View {

    @ObservedObject private var manager = InAppPurchaseManager.shared

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "cart.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.tint)

                Text("InAppPurchase")
                    .font(.title2.bold())

                stateLabel

                Divider()

                VStack(spacing: 12) {
                    Button("Show Paywall Now") {
                        manager.reset()
                        var config = InAppPurchaseConfig(productID: "com.example.app.unlock")
                        config.minLaunches = 1
                        config.deferralSteps = [3, 2, 1]
                        InAppPurchaseManager.shared.configure(config)
                        Task { await manager.recordLaunch() }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    Button("Reset State") {
                        manager.reset()
                    }
                    .buttonStyle(.bordered)
                    .foregroundStyle(.secondary)
                    .controlSize(.large)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("In-App Purchase")
            .navigationBarTitleDisplayMode(.inline)
            .inAppPurchase(manager: manager)
        }
    }

    private var stateLabel: some View {
        VStack(spacing: 6) {
            if manager.isPurchased {
                Label("Purchased", systemImage: "checkmark.seal.fill")
                    .foregroundStyle(.green)
            } else if manager.isBlocked {
                Label("Hard blocked", systemImage: "lock.fill")
                    .foregroundStyle(.red)
            } else if manager.shouldShowPaywall {
                Label("Paywall visible", systemImage: "eye.fill")
                    .foregroundStyle(.orange)
            } else {
                Label("Free trial active", systemImage: "clock")
                    .foregroundStyle(.secondary)
            }

            if let price = manager.displayPrice {
                Text("Price: \(price)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .font(.subheadline)
    }
}

// MARK: - TipKit demo tips

/// Short tip — arrow points up from a toolbar button.
private struct FavoriteTip: Tip {
    var title:   Text  { Text("Add to Favorites") }
    var message: Text? { Text("Tap the star to save this item for quick access later.") }
    var image:   Image? { Image(systemName: "star") }
    var options: [any TipOption] { [Tips.MaxDisplayCount(1)] }
    var rules:   [Rule] {
        [#Rule(TipKitGuard.$isReady)   { $0 },
         #Rule(TipKitGuard.$isAllowed) { $0 }]
    }
}

/// Long-text tip — deliberately verbose to demonstrate no truncation.
private struct LongTextTip: Tip {
    var title:   Text  { Text("Share with Your Team") }
    var message: Text? { Text("Tap Share to send this item via Messages, Mail, AirDrop, or any app that accepts links. Recipients don't need an account to view shared content — the link works in any browser.") }
    var image:   Image? { Image(systemName: "square.and.arrow.up") }
    var options: [any TipOption] { [Tips.MaxDisplayCount(1)] }
    var rules:   [Rule] {
        [#Rule(TipKitGuard.$isReady)   { $0 },
         #Rule(TipKitGuard.$isAllowed) { $0 }]
    }
}

/// Tip with arrow pointing down, no icon.
private struct FilterTip: Tip {
    var title:   Text  { Text("Filter Results") }
    var message: Text? { Text("Narrow the list by category, date, or tag.") }
    var options: [any TipOption] { [Tips.MaxDisplayCount(1)] }
    var rules:   [Rule] {
        [#Rule(TipKitGuard.$isReady)   { $0 },
         #Rule(TipKitGuard.$isAllowed) { $0 }]
    }
}

// MARK: - TipKit test harness

private struct TipKitTestView: View {

    @State private var sheetGuardEnabled = false

    private let favoriteTip  = FavoriteTip()
    private let longTextTip  = LongTextTip()
    private let filterTip    = FilterTip()

    var body: some View {
        NavigationStack {
            List {
                tipsSection
                guardSection
                resetSection
            }
            .navigationTitle("TipKit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                    } label: {
                        Image(systemName: "star")
                    }
                    .tipPopover(favoriteTip, config: {
                        var c = TipKitConfig()
                        c.arrowEdge = .top
                        return c
                    }())
                }
            }
        }
    }

    // MARK: - Sections

    private var tipsSection: some View {
        Section {
            // Long-text tip — popover appears below the row icon
            HStack {
                Image(systemName: "square.and.arrow.up")
                    .foregroundStyle(.tint)
                    .frame(width: 28)
                    .tipPopover(longTextTip)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Share")
                        .font(.body)
                    Text("Long-text tip — tap the icon")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)

            // No-icon tip with arrow pointing down
            HStack {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .foregroundStyle(.tint)
                    .frame(width: 28)
                    .tipPopover(filterTip, config: {
                        var c = TipKitConfig()
                        c.arrowEdge = .bottom
                        return c
                    }())
                VStack(alignment: .leading, spacing: 2) {
                    Text("Filter")
                        .font(.body)
                    Text("No-icon tip, arrow points down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)

            Text("Star button in toolbar shows a third tip with arrow pointing up.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.vertical, 4)

        } header: {
            Text("Live Popovers")
        } footer: {
            Text("Tips show once. Use Reset below to see them again.")
        }
    }

    private var guardSection: some View {
        Section {
            Toggle("Block tips (TipKitGuard.isAllowed)", isOn: $sheetGuardEnabled)
                .onChange(of: sheetGuardEnabled) {
                    TipKitGuard.isAllowed = !sheetGuardEnabled
                }
        } header: {
            Text("Global Guard")
        } footer: {
            Text("Toggle off to suppress all participating tips immediately. Simulates presenting a sheet over tip-bearing views.")
        }
    }

    private var resetSection: some View {
        Section {
            Button("Reset All Tips") {
                try? Tips.resetDatastore()
                try? Tips.configure([.displayFrequency(.immediate)])
                TipKitGuard.isReady = true
            }
            .foregroundStyle(.red)
        } footer: {
            Text("Resets display counts so all tips become eligible again.")
        }
    }
}

// MARK: - AppColorSelection test harness

private enum ColorUIMode: String, CaseIterable, Identifiable {
    case band   = "Band"
    case picker = "Picker"
    case matrix = "Matrix"
    var id: String { rawValue }
}

private struct AppColorTestView: View {

    @Environment(AppColorStore.self) private var appColor
    @State private var uiMode: ColorUIMode = .band
    @State private var matrixColumns = 6

    private var displayMode: AppColorDisplayMode {
        switch uiMode {
        case .band:   return .band
        case .picker: return .picker
        case .matrix: return .matrix(columns: matrixColumns)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {

                    sampleBanner

                    VStack(alignment: .leading, spacing: 12) {

                        // Mode picker
                        VStack(alignment: .leading, spacing: 6) {
                            Text("DISPLAY MODE")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(appColor.accentColor.opacity(0.55))
                                .padding(.horizontal, 18)

                            Picker("Display mode", selection: $uiMode) {
                                ForEach(ColorUIMode.allCases) { mode in
                                    Text(mode.rawValue).tag(mode)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal, 18)
                        }

                        // Column control (matrix only)
                        if uiMode == .matrix {
                            Stepper("Columns: \(matrixColumns)", value: $matrixColumns, in: 2...10)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 10)
                                .font(.system(size: 14))
                                .foregroundStyle(appColor.accentColor)
                                .background(appColor.accentColor.opacity(0.04))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .strokeBorder(appColor.accentColor.opacity(0.15), lineWidth: 1)
                                )
                                .padding(.horizontal, 18)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                        AppColorSelectionView(
                            displayMode: displayMode,
                            message: "Changes the accent and background tint throughout the entire app.",
                            options: AppColorPreset.all,
                            selectedOption: appColor.selectedPreset,
                            tintColor: appColor.accentColor
                        ) { appColor.select($0) }
                    }
                    .padding(.vertical)
                    .animation(.easeInOut(duration: 0.2), value: uiMode)
                }
            }
            .background(appColor.backgroundColor)
            .navigationTitle("Color")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var sampleBanner: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sample Content")
                .font(.title2.bold())
                .foregroundStyle(appColor.accentColor)

            Text("This banner previews your palette selection live. Background and text colours update immediately as you pick a new preset below.")
                .font(.subheadline)
                .foregroundStyle(appColor.accentColor.opacity(0.7))
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 10) {
                Capsule()
                    .fill(appColor.accentColor)
                    .frame(width: 60, height: 28)
                    .overlay(
                        Text("Button")
                            .font(.caption.bold())
                            .foregroundStyle(appColor.backgroundColor)
                    )

                Text(appColor.selectedPreset.colorName)
                    .font(.caption)
                    .foregroundStyle(appColor.accentColor.opacity(0.55))
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(appColor.backgroundColor)
        .overlay(alignment: .bottom) {
            Divider().opacity(0.4)
        }
    }
}

// MARK: - AppPaletteSelection test harness

private enum PaletteUIMode: String, CaseIterable, Identifiable {
    case band  = "Band"
    case list  = "List"
    case grid  = "Grid"
    var id: String { rawValue }
}

private struct AppPaletteTestView: View {

    @Environment(AppPaletteStore.self) private var palette
    @State private var uiMode: PaletteUIMode = .band
    @State private var gridColumns = 3

    private var displayMode: AppPaletteDisplayMode {
        switch uiMode {
        case .band: return .band
        case .list: return .list
        case .grid: return .grid(columns: gridColumns)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    tokenSwatches

                    Divider().padding(.horizontal, 18)

                    // Display-mode picker
                    VStack(alignment: .leading, spacing: 6) {
                        Text("DISPLAY MODE")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(palette.accentColor.opacity(0.55))
                            .padding(.horizontal, 18)

                        Picker("Display mode", selection: $uiMode) {
                            ForEach(PaletteUIMode.allCases) { Text($0.rawValue).tag($0) }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, 18)
                    }

                    if uiMode == .grid {
                        Stepper("Columns: \(gridColumns)", value: $gridColumns, in: 2...5)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 10)
                            .font(.system(size: 14))
                            .foregroundStyle(palette.accentColor)
                            .background(palette.accentColor.opacity(0.04))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .strokeBorder(palette.accentColor.opacity(0.15), lineWidth: 1)
                            )
                            .padding(.horizontal, 18)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    AppPaletteSelectionView(
                        store: palette,
                        displayMode: displayMode,
                        message: "Sets the app's accent and surface colors."
                    )

                    Spacer(minLength: 20)
                }
                .padding(.vertical)
                .animation(.easeInOut(duration: 0.2), value: uiMode)
            }
            .background(palette.backgroundColor)
            .navigationTitle("Palette")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Token swatches

    private var tokenSwatches: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SEMANTIC TOKENS")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(palette.accentColor.opacity(0.55))
                .padding(.horizontal, 18)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    tokenSwatch(color: palette.accentColor,          label: "Accent")
                    tokenSwatch(color: palette.backgroundColor,      label: "Background")
                    tokenSwatch(color: palette.groupedBackground,    label: "Grouped BG")
                    tokenSwatch(color: palette.fillColor,            label: "Fill")
                    tokenSwatch(color: palette.labelColor,           label: "Label")
                    tokenSwatch(color: palette.secondaryLabelColor,  label: "2nd Label")
                }
                .padding(.horizontal, 18)
            }
        }
    }

    private func tokenSwatch(color: Color, label: String) -> some View {
        VStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(color)
                .frame(width: 56, height: 56)
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(palette.labelColor.opacity(0.12), lineWidth: 1)
                )
                .shadow(color: color.opacity(0.25), radius: 4, y: 2)

            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(palette.labelColor.opacity(0.6))
                .multilineTextAlignment(.center)
                .frame(width: 56)
        }
    }
}

// MARK: - AppUpdateNotifier test harness

private struct AppUpdateNotifierTestView: View {

    @State private var manager = AppUpdateNotifierManager.shared

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "sparkles.rectangle.stack")
                    .font(.system(size: 60))
                    .foregroundStyle(.tint)

                Text("AppUpdateNotifier")
                    .font(.title2.bold())

                stateLabel

                Divider()

                VStack(spacing: 12) {
                    Button("Show Update Sheet") {
                        var config = AppUpdateNotifierConfig(
                            appName: "SharableComponents",
                            version: "1.0",
                            releaseDate: "June 25, 2025",
                            enhancements: [
                                "AppUpdateNotifier component — per-version release notes sheet",
                                "AppPaletteSelection — semantic tokens and new display modes"
                            ],
                            bugFixes: [
                                "TipKit popovers no longer truncate long message text"
                            ]
                        )
                        AppUpdateNotifierManager.shared.configure(config)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    Button("Reset (show again next configure)") {
                        UserDefaults.standard.removeObject(forKey: "appUpdateNotifier.dismissedVersion")
                    }
                    .buttonStyle(.bordered)
                    .foregroundStyle(.secondary)
                    .controlSize(.large)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Update Notifier")
            .navigationBarTitleDisplayMode(.inline)
            .appUpdateNotifier()
        }
    }

    private var stateLabel: some View {
        Group {
            if manager.shouldShow {
                Label("Sheet is visible", systemImage: "eye.fill")
                    .foregroundStyle(.orange)
            } else {
                Label("Suppressed for this version", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        }
        .font(.subheadline)
    }
}

#Preview {
    ContentView()
}
