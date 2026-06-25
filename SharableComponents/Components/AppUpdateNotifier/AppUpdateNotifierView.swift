//
//  AppUpdateNotifierView.swift
//  SharableComponents
//

import SwiftUI
import UIKit

/// The update notifier sheet.
///
/// Typically presented automatically via `.appUpdateNotifier()`. Use directly
/// only when you need custom presentation logic.
public struct AppUpdateNotifierView: View {

    let config: AppUpdateNotifierConfig
    let accentColor: Color
    let backgroundColor: Color
    let onDismiss: () -> Void
    let onSuppressForVersion: () -> Void

    public init(
        config: AppUpdateNotifierConfig,
        accentColor: Color,
        backgroundColor: Color,
        onDismiss: @escaping () -> Void,
        onSuppressForVersion: @escaping () -> Void
    ) {
        self.config               = config
        self.accentColor          = accentColor
        self.backgroundColor      = backgroundColor
        self.onDismiss            = onDismiss
        self.onSuppressForVersion = onSuppressForVersion
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: 0) {
            header
            scrollContent
            footer
        }
        .background(Color(.systemBackground).ignoresSafeArea())
    }

    // MARK: - App icon

    private var appIcon: UIImage? {
        guard let icons = Bundle.main.object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any],
              let primary = icons["CFBundlePrimaryIcon"] as? [String: Any],
              let files = primary["CFBundleIconFiles"] as? [String],
              let name = files.last,
              let image = UIImage(named: name) else { return nil }
        return image
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 12) {
            Group {
                if let icon = appIcon {
                    Image(uiImage: icon)
                        .resizable()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                } else {
                    Image(systemName: "sparkles.rectangle.stack")
                        .font(.system(size: 48, weight: .light))
                        .foregroundStyle(accentColor)
                }
            }
            .padding(.top, 36)

            VStack(spacing: 4) {
                Text(config.appName)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(accentColor)

                HStack(spacing: 8) {
                    Text("Version \(config.version)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(accentColor.opacity(0.7))

                    Circle()
                        .fill(accentColor.opacity(0.4))
                        .frame(width: 3, height: 3)

                    Text(config.releaseDate)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(accentColor.opacity(0.55))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 28)
        .background(
            LinearGradient(
                colors: [backgroundColor, backgroundColor.opacity(0)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    // MARK: - Scroll content

    private var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 28) {
                Text("What's New In This Version")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.primary)

                if let message = config.message {
                    Text(message)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }

                if !config.enhancements.isEmpty {
                    bulletSection(
                        title: "Enhancements",
                        icon: "sparkle",
                        items: config.enhancements
                    )
                }

                if !config.bugFixes.isEmpty {
                    bulletSection(
                        title: "Bug Fixes",
                        icon: "ladybug.fill",
                        items: config.bugFixes
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 26)
            .padding(.top, 4)
            .padding(.bottom, 16)
        }
    }

    private func bulletSection(title: String, icon: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(accentColor)
                Text(title.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(accentColor)
                    .kerning(0.5)
            }

            VStack(alignment: .leading, spacing: 10) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 10) {
                        Circle()
                            .fill(accentColor)
                            .frame(width: 5, height: 5)
                            .padding(.top, 7)

                        Text(item)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(.leading, 2)
        }
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(spacing: 0) {
            Divider()

            VStack(spacing: 12) {
                Button(action: onDismiss) {
                    Text("Continue")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(continueButtonForeground)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(accentColor)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                Button(action: onSuppressForVersion) {
                    Text("Don't Show Again")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(accentColor.opacity(0.55))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 26)
            .padding(.top, 16)
            .padding(.bottom, 28)
            .background(Color(.systemBackground))
        }
    }

    // MARK: - Helpers

    private var continueButtonForeground: Color {
        accentColor.perceivedBrightness > 0.55
            ? Color.black.opacity(0.8)
            : .white
    }
}

// MARK: - Previews

#Preview("Enhancements + Bug Fixes") {
    let config = AppUpdateNotifierConfig(
        appName: "MyApp",
        version: "2.1",
        enhancements: [
            "Redesigned home screen for faster access to your most-used features",
            "New color palette selection with 51 presets",
            "Improved performance when loading large datasets"
        ],
        bugFixes: [
            "Fixed a crash that occurred when opening a notification while the app was backgrounded",
            "Corrected an alignment issue in the settings screen on iPhone SE"
        ]
    )

    AppUpdateNotifierView(
        config: config,
        accentColor: AppColorPreset.ocean.accentColor,
        backgroundColor: AppColorPreset.ocean.backgroundColor,
        onDismiss: {},
        onSuppressForVersion: {}
    )
}

#Preview("Enhancements only") {
    let config = AppUpdateNotifierConfig(
        appName: "MyApp",
        version: "3.0",
        enhancements: [
            "Complete app redesign with improved navigation",
            "Dark mode support"
        ]
    )

    AppUpdateNotifierView(
        config: config,
        accentColor: AppColorPreset.plum.accentColor,
        backgroundColor: AppColorPreset.plum.backgroundColor,
        onDismiss: {},
        onSuppressForVersion: {}
    )
}

#Preview("No palette (system accent)") {
    let config = AppUpdateNotifierConfig(
        appName: "MyApp",
        version: "1.2",
        bugFixes: ["Fixed sync issue with iCloud"]
    )

    AppUpdateNotifierView(
        config: config,
        accentColor: .accentColor,
        backgroundColor: Color(.systemBackground),
        onDismiss: {},
        onSuppressForVersion: {}
    )
}
