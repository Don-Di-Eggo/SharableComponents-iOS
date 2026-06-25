import SwiftUI

/// All configuration for the FeedbackManager component.
/// Create one instance and pass it to the `.feedbackButton()` modifier or `FeedbackButtonView`.
public struct FeedbackManagerConfig {

    // MARK: - Routing

    /// Email address that receives feedback. Default: "support@chainbreaker.app".
    public var recipientEmail: String = "support@chainbreaker.app"

    // MARK: - Subject categories & guided prompts

    /// Options presented to the user in the category picker.
    /// The selected item becomes the email subject line prefixed with the app name.
    /// e.g. "[MyApp] I've found a bug!"
    public var subjectCategories: [String] = [
        "I've found a bug!",
        "I have a feature request",
        "I have a question",
        "Something else"
    ]

    /// Guided prompts inserted into the email body, indexed to match `subjectCategories`.
    /// Index 0's prompts appear when category 0 is selected, and so on.
    /// An empty inner array (or a missing index) produces no prompts for that category.
    public var categoryPrompts: [[String]] = [
        [
            "Steps to reproduce:",
            "What did you expect to happen:",
            "What actually happened:"
        ],
        [
            "Describe the feature:",
            "Why is it important to you:"
        ],
        [
            "My question:"
        ],
        []
    ]

    // MARK: - Sheet text

    public var sheetTitle: String = "Send Feedback"
    public var sheetMessage: String = "We read every message. What's on your mind?"
    public var categoryPickerLabel: String = "Type of Feedback"
    public var sendButtonTitle: String = "Open Mail"
    public var cancelButtonTitle: String = "Cancel"

    // MARK: - Email body

    /// Free-form intro text inserted at the top of the email body above the prompts.
    /// Leave empty to start the body with the prompts directly.
    public var bodyIntro: String = ""

    /// When true, appends app + device info to the bottom of every email body.
    public var includeSystemInfo: Bool = true

    // MARK: - Styling

    public var style: FeedbackManagerStyle = FeedbackManagerStyle()

    // MARK: - Init

    public init() {}
}
