import Foundation
import Testing
@testable import SharableComponents

// PushSurveyManager is a @MainActor singleton; .serialized prevents parallel state bleed.
// Tests avoid network by driving state through showForTesting / dismiss / decline / reset
// rather than recordLaunch (which fetches).
@Suite(.serialized)
@MainActor
struct PushSurveyTests {

    // MARK: - Helpers

    private func sampleSurvey(guid: String = "guid-1") -> Survey {
        Survey(
            guid: guid,
            title: "Help shape what's next",
            subtitle: "30 seconds",
            minLaunches: 5,
            questions: [
                SurveyQuestion(id: "widgets", type: .likert,   prompt: "Home screen widgets"),
                SurveyQuestion(id: "other",   type: .freeText, prompt: "Anything else?")
            ]
        )
    }

    // MARK: - Model: Survey decoding

    @Test("Survey decodes from the documented server JSON and defaults the scale")
    func surveyDecodes() throws {
        let json = """
        {
          "guid": "a1b2",
          "title": "Title",
          "subtitle": "Sub",
          "minLaunches": 20,
          "scale": ["Critical", "Important", "Nice to have", "Not important", "Don't care"],
          "questions": [
            { "id": "widgets", "type": "likert",   "prompt": "Widgets" },
            { "id": "other",   "type": "freeText", "prompt": "Else?" }
          ]
        }
        """.data(using: .utf8)!

        let survey = try JSONDecoder().decode(Survey.self, from: json)
        #expect(survey.guid == "a1b2")
        #expect(survey.id == "a1b2")             // id mirrors guid
        #expect(survey.minLaunches == 20)
        #expect(survey.scale.count == 5)
        #expect(survey.questions.count == 2)
        #expect(survey.questions[0].type == .likert)
        #expect(survey.questions[1].type == .freeText)
    }

    // MARK: - Model: Response encoding

    @Test("SurveyResponse encodes guid, customer id, ISO-8601 date, and answers")
    func responseEncodes() throws {
        var response = SurveyResponse(surveyGuid: "g1", customerID: "C-123")
        response.responses = ["widgets": "Critical", "other": "Dark mode please"]

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(response)
        let obj = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(obj["surveyGuid"] as? String == "g1")
        #expect(obj["customerID"] as? String == "C-123")
        #expect(obj["submittedAt"] is String)    // iso8601 → string
        let answers = obj["responses"] as! [String: String]
        #expect(answers["widgets"] == "Critical")
        #expect(answers["other"] == "Dark mode please")
    }

    // MARK: - Manager state ownership

    @Test("showForTesting presents the survey")
    func showPresents() async {
        let m = PushSurveyManager.shared
        m.reset()
        await m.showForTesting(sampleSurvey())
        #expect(m.activeSurvey?.guid == "guid-1")
    }

    @Test("dismiss clears the active survey")
    func dismissClears() async {
        let m = PushSurveyManager.shared
        m.reset()
        await m.showForTesting(sampleSurvey())
        m.dismiss()
        #expect(m.activeSurvey == nil)
    }

    @Test("decline clears the active survey")
    func declineClears() async {
        let m = PushSurveyManager.shared
        m.reset()
        await m.showForTesting(sampleSurvey())
        m.decline()
        #expect(m.activeSurvey == nil)
    }

    @Test("reset clears any active survey")
    func resetClears() async {
        let m = PushSurveyManager.shared
        await m.showForTesting(sampleSurvey())
        m.reset()
        #expect(m.activeSurvey == nil)
    }

    @Test("configure updates the current config")
    func configureUpdates() {
        let m = PushSurveyManager.shared
        let url = URL(string: "https://example.test/survey.json")!
        let base = URL(string: "https://example.test/surveys")!
        var config = PushSurveyConfig(surveyURL: url, responseBaseURL: base)
        config.suiteName = "push.test.suite"
        m.configure(config)
        #expect(m.currentConfig.surveyURL == url)
        #expect(m.currentConfig.suiteName == "push.test.suite")
    }
}
