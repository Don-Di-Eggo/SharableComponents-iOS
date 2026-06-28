import Foundation

/// All configuration for the PushSurvey component.
/// Create one instance and pass it to the `.pushSurvey()` modifier.
public struct PushSurveyConfig {

    // MARK: - URLs

    /// Where the current survey JSON is hosted.
    /// e.g. https://chainbreaker.app/surveys/current.json
    public var surveyURL: URL

    /// Base URL for posting responses. The component appends /{surveyGuid}/{customerID}.json
    /// e.g. https://chainbreaker.app/surveys  →  PUT …/surveys/{guid}/{customerID}.json
    public var responseBaseURL: URL

    // MARK: - Storage

    /// UserDefaults suite name — share this with your other components for a consistent CustomerIdentifier.
    public var suiteName: String? = nil

    // MARK: - Init

    public init(surveyURL: URL, responseBaseURL: URL) {
        self.surveyURL = surveyURL
        self.responseBaseURL = responseBaseURL
    }
}
