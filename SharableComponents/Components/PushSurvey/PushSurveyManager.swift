import SwiftUI
import Combine

/// Fetches the survey JSON, tracks launch counts, manages per-survey state,
/// and submits responses. Call `configure(_:)` once at app startup, then
/// `recordLaunch()` on each launch. Observe `activeSurvey` to know when to show the sheet.
@MainActor
public final class PushSurveyManager: ObservableObject {

    public static let shared = PushSurveyManager()

    // MARK: - Published state

    @Published public private(set) var activeSurvey: Survey? = nil

    // MARK: - Private state

    public private(set) var currentConfig = PushSurveyConfig(
        surveyURL: URL(string: "https://example.com/surveys/current.json")!,
        responseBaseURL: URL(string: "https://example.com/surveys")!
    )
    private var defaults: UserDefaults { UserDefaults(suiteName: currentConfig.suiteName) ?? .standard }

    // MARK: - UserDefaults keys

    private enum Key {
        static let launchCount  = "ps_launchCount"
        static let cachedSurvey = "ps_cachedSurvey"
        static func state(for guid: String) -> String { "ps_state_\(guid)" }
    }

    // MARK: - Public API

    public func configure(_ config: PushSurveyConfig) {
        self.currentConfig = config
    }

    /// Call once per app launch, after `configure(_:)`.
    public func recordLaunch() async {
        let count = defaults.integer(forKey: Key.launchCount) + 1
        defaults.set(count, forKey: Key.launchCount)
        await fetchAndEvaluate(launchCount: count)
    }

    /// Call when the user taps X — dismisses for this session, will re-appear next time.
    public func dismiss() {
        guard let survey = activeSurvey else { return }
        setState(.dismissed, for: survey.guid)
        activeSurvey = nil
    }

    /// Clears all stored state so the survey can re-present. Useful for testing.
    public func reset() {
        if let data = defaults.data(forKey: Key.cachedSurvey),
           let survey = try? JSONDecoder().decode(Survey.self, from: data) {
            defaults.removeObject(forKey: Key.state(for: survey.guid))
        }
        defaults.removeObject(forKey: Key.launchCount)
        defaults.removeObject(forKey: Key.cachedSurvey)
        activeSurvey = nil
    }

    /// Immediately presents the cached or provided survey, bypassing launch count. For testing only.
    public func showForTesting(_ survey: Survey? = nil) async {
        if let survey {
            activeSurvey = survey
            return
        }
        if let cached = cachedSurvey() {
            activeSurvey = cached
        }
    }

    /// Call when the user taps "Don't show again" — suppresses this survey GUID permanently.
    public func decline() {
        guard let survey = activeSurvey else { return }
        setState(.declined, for: survey.guid)
        activeSurvey = nil
    }

    /// Call when the user submits a response. Posts to the server and suppresses until a new GUID appears.
    public func submit(_ response: SurveyResponse) async {
        guard let survey = activeSurvey else { return }
        setState(.completed, for: survey.guid)
        activeSurvey = nil
        await post(response)
    }

    // MARK: - Fetch & evaluate

    private func fetchAndEvaluate(launchCount: Int) async {
        let survey = await fetchSurvey()
        guard let survey else { return }

        let state = getState(for: survey.guid)
        guard state != .declined, state != .completed else { return }
        guard launchCount >= survey.minLaunches else { return }

        activeSurvey = survey
    }

    private func fetchSurvey() async -> Survey? {
        do {
            let (data, response) = try await URLSession.shared.data(from: currentConfig.surveyURL)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { return cachedSurvey() }
            let decoder = JSONDecoder()
            let survey = try decoder.decode(Survey.self, from: data)
            defaults.set(data, forKey: Key.cachedSurvey)
            return survey
        } catch {
            return cachedSurvey()
        }
    }

    private func cachedSurvey() -> Survey? {
        guard let data = defaults.data(forKey: Key.cachedSurvey) else { return nil }
        return try? JSONDecoder().decode(Survey.self, from: data)
    }

    // MARK: - State helpers

    private func getState(for guid: String) -> SurveyState {
        guard let raw = defaults.string(forKey: Key.state(for: guid)),
              let state = SurveyState(rawValue: raw) else { return .unseen }
        return state
    }

    private func setState(_ state: SurveyState, for guid: String) {
        defaults.set(state.rawValue, forKey: Key.state(for: guid))
    }

    // MARK: - Submit

    private func post(_ response: SurveyResponse) async {
        let url = currentConfig.responseBaseURL
            .appendingPathComponent(response.surveyGuid)
            .appendingPathComponent(response.customerID)
            .appendingPathExtension("json")

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let body = try? encoder.encode(response) else { return }
        request.httpBody = body

        _ = try? await URLSession.shared.data(for: request)
    }
}
