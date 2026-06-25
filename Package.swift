// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SharableComponents",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "AppColorSelection",  targets: ["AppColorSelection"]),
        .library(name: "AppPaletteSelection", targets: ["AppPaletteSelection"]),
        .library(name: "AppReviewRequest",   targets: ["AppReviewRequest"]),
        .library(name: "AppUpdateNotifier",  targets: ["AppUpdateNotifier"]),
        .library(name: "FeedbackManager",    targets: ["FeedbackManager"]),
        .library(name: "InAppPurchase",      targets: ["InAppPurchase"]),
        .library(name: "TipKit",             targets: ["TipKit"]),
    ],
    targets: [
        .target(
            name: "AppColorSelection",
            path: "SharableComponents/Components/AppColorSelection"
        ),
        .target(
            name: "AppPaletteSelection",
            path: "SharableComponents/Components/AppPaletteSelection"
        ),
        .target(
            name: "AppReviewRequest",
            path: "SharableComponents/Components/AppReviewRequest"
        ),
        .target(
            name: "AppUpdateNotifier",
            path: "SharableComponents/Components/AppUpdateNotifier",
            dependencies: ["InAppPurchase"]
        ),
        .target(
            name: "FeedbackManager",
            path: "SharableComponents/Components/FeedbackManager"
        ),
        .target(
            name: "InAppPurchase",
            path: "SharableComponents/Components/InAppPurchase"
        ),
        .target(
            name: "TipKit",
            path: "SharableComponents/Components/TipKit"
        ),
    ]
)
