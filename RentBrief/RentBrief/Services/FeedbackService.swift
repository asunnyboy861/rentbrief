import Foundation

actor FeedbackService {
    private let endpoint = URL(string: "https://rentbrief-feedback.vercel.app/api/feedback")!

    func submit(subject: String, body: String, email: String) async throws {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: String] = [
            "subject": subject,
            "body": body,
            "email": email,
            "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0",
            "platform": "iOS"
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: payload)

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw FeedbackError.serverError
        }
    }
}

enum FeedbackError: LocalizedError {
    case serverError

    var errorDescription: String? {
        switch self {
        case .serverError:
            return "Failed to submit feedback. Please try again later."
        }
    }
}
