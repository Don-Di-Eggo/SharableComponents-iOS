import SwiftUI

public struct PushSurveyView: View {

    let survey: Survey
    let customerID: String
    let onDismiss: () -> Void
    let onDecline: () -> Void
    let onSubmit: (SurveyResponse) async -> Void

    @State private var likertSelections: [String: String] = [:]
    @State private var freeTextResponses: [String: String] = [:]
    @State private var isSubmitting = false

    private var likertQuestions: [SurveyQuestion] {
        survey.questions.filter { $0.type == .likert }
    }
    private var freeTextQuestions: [SurveyQuestion] {
        survey.questions.filter { $0.type == .freeText }
    }
    private var canSubmit: Bool {
        likertQuestions.allSatisfy { likertSelections[$0.id] != nil }
    }

    public init(
        survey: Survey,
        customerID: String,
        onDismiss: @escaping () -> Void,
        onDecline: @escaping () -> Void,
        onSubmit: @escaping (SurveyResponse) async -> Void
    ) {
        self.survey = survey
        self.customerID = customerID
        self.onDismiss = onDismiss
        self.onDecline = onDecline
        self.onSubmit = onSubmit
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {

                    // Header
                    VStack(alignment: .leading, spacing: 6) {
                        Text(survey.title)
                            .font(.title2.bold())
                        Text(survey.subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 8)

                    // Scale legend
                    scaleLegend

                    // Likert questions
                    if !likertQuestions.isEmpty {
                        VStack(alignment: .leading, spacing: 20) {
                            ForEach(likertQuestions, id: \.id) { question in
                                LikertRowView(
                                    question: question,
                                    scale: survey.scale,
                                    selection: Binding(
                                        get: { likertSelections[question.id] },
                                        set: { likertSelections[question.id] = $0 }
                                    )
                                )
                            }
                        }
                    }

                    // Free-text questions
                    if !freeTextQuestions.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(freeTextQuestions, id: \.id) { question in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(question.prompt)
                                        .font(.subheadline.weight(.medium))
                                    TextField("Optional", text: Binding(
                                        get: { freeTextResponses[question.id] ?? "" },
                                        set: { freeTextResponses[question.id] = $0.isEmpty ? nil : $0 }
                                    ), axis: .vertical)
                                    .lineLimit(3...6)
                                    .textFieldStyle(.roundedBorder)
                                }
                            }
                        }
                    }

                    // Footer
                    VStack(spacing: 12) {
                        Button {
                            Task { await submitSurvey() }
                        } label: {
                            Group {
                                if isSubmitting {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Submit")
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!canSubmit || isSubmitting)

                        Button("Don't show again", role: .destructive) {
                            onDecline()
                        }
                        .font(.footnote)
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.secondary)
                            .font(.title3)
                    }
                }
            }
        }
    }

    // MARK: - Scale legend

    private var scaleLegend: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(Array(survey.scale.enumerated()), id: \.offset) { index, label in
                    HStack(spacing: 4) {
                        Circle()
                            .fill(scaleColor(index: index, total: survey.scale.count))
                            .frame(width: 8, height: 8)
                        Text(label)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    if index < survey.scale.count - 1 {
                        Text(" · ")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func submitSurvey() async {
        isSubmitting = true
        var response = SurveyResponse(surveyGuid: survey.guid, customerID: customerID)
        for (id, value) in likertSelections { response.responses[id] = value }
        for (id, value) in freeTextResponses { response.responses[id] = value }
        await onSubmit(response)
    }

    private func scaleColor(index: Int, total: Int) -> Color {
        let colors: [Color] = [.red, .orange, .yellow, .green, .gray]
        guard total > 0 else { return .gray }
        let i = min(index, colors.count - 1)
        return colors[i]
    }
}

// MARK: - Likert row

private struct LikertRowView: View {
    let question: SurveyQuestion
    let scale: [String]
    @Binding var selection: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(question.prompt)
                .font(.subheadline.weight(.medium))

            HStack(spacing: 6) {
                ForEach(Array(scale.enumerated()), id: \.offset) { index, label in
                    Button {
                        selection = label
                    } label: {
                        VStack(spacing: 4) {
                            Circle()
                                .fill(selection == label ? scaleColor(index: index, total: scale.count) : Color(.systemGray5))
                                .frame(width: 28, height: 28)
                                .overlay {
                                    if selection == label {
                                        Image(systemName: "checkmark")
                                            .font(.caption.bold())
                                            .foregroundStyle(.white)
                                    }
                                }
                            Text(label)
                                .font(.system(size: 8))
                                .foregroundStyle(selection == label ? .primary : .secondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(14)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }

    private func scaleColor(index: Int, total: Int) -> Color {
        let colors: [Color] = [.red, .orange, .yellow, .green, .gray]
        guard total > 0 else { return .gray }
        return colors[min(index, colors.count - 1)]
    }
}

// MARK: - Preview

#Preview("Survey Sheet") {
    let survey = Survey(
        guid: "preview-001",
        title: "Help shape what's next",
        subtitle: "Takes about 30 seconds. Your input directly drives our roadmap.",
        minLaunches: 1,
        questions: [
            SurveyQuestion(id: "widgets",   type: .likert,   prompt: "Home screen widgets"),
            SurveyQuestion(id: "shortcuts", type: .likert,   prompt: "Shortcuts integration"),
            SurveyQuestion(id: "icloud",    type: .likert,   prompt: "iCloud sync"),
            SurveyQuestion(id: "other",     type: .freeText, prompt: "Anything else you'd like to see?")
        ]
    )

    Color.clear
        .sheet(isPresented: .constant(true)) {
            PushSurveyView(
                survey: survey,
                customerID: "PREVIEW-ID",
                onDismiss: {},
                onDecline: {},
                onSubmit: { _ in }
            )
        }
}
