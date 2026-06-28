import Foundation

// MARK: - Survey (fetched from server)

public struct Survey: Codable, Equatable, Identifiable {
    public var id: String { guid }
    public let guid: String
    public let title: String
    public let subtitle: String
    public let minLaunches: Int
    public let scale: [String]
    public let questions: [SurveyQuestion]

    public init(
        guid: String,
        title: String,
        subtitle: String,
        minLaunches: Int,
        scale: [String] = ["Critical", "Important", "Nice to have", "Not important", "Don't care"],
        questions: [SurveyQuestion]
    ) {
        self.guid = guid
        self.title = title
        self.subtitle = subtitle
        self.minLaunches = minLaunches
        self.scale = scale
        self.questions = questions
    }
}

public struct SurveyQuestion: Codable, Equatable {
    public enum QuestionType: String, Codable {
        case likert
        case freeText
    }

    public let id: String
    public let type: QuestionType
    public let prompt: String
}

// MARK: - Survey Response (posted to server)

public struct SurveyResponse: Codable {
    public let surveyGuid: String
    public let customerID: String
    public let submittedAt: Date
    public var responses: [String: String]

    public init(surveyGuid: String, customerID: String) {
        self.surveyGuid = surveyGuid
        self.customerID = customerID
        self.submittedAt = Date()
        self.responses = [:]
    }
}

// MARK: - Per-survey state stored in UserDefaults

enum SurveyState: String, Codable {
    case unseen
    case dismissed
    case declined
    case completed
}
