import SwiftUI

struct ContactSupportView: View {
    @State private var subject = ""
    @State private var messageBody = ""
    @State private var email = ""
    @State private var isSending = false
    @State private var showSuccess = false
    @State private var errorMessage: String?

    var body: some View {
        Form {
            Section("Your Info") {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
            }

            Section("Message") {
                TextField("Subject", text: $subject)
                TextField("Describe your issue or feedback", text: $messageBody, axis: .vertical)
                    .lineLimit(5...10)
            }

            Section {
                Button {
                    sendMessage()
                } label: {
                    HStack {
                        if isSending {
                            ProgressView()
                        }
                        Text(isSending ? "Sending..." : "Send Message")
                    }
                }
                .disabled(subject.isEmpty || messageBody.isEmpty || email.isEmpty || isSending)
            }

            if let error = errorMessage {
                Section {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(Color.expenseRed)
                }
            }
        }
        .navigationTitle("Contact Support")
        .alert("Message Sent!", isPresented: $showSuccess) {
            Button("OK") {
                subject = ""
                messageBody = ""
            }
        } message: {
            Text("We'll get back to you within 24 hours.")
        }
    }

    private func sendMessage() {
        isSending = true
        errorMessage = nil
        Task {
            do {
                let service = FeedbackService()
                try await service.submit(subject: subject, body: messageBody, email: email)
                isSending = false
                showSuccess = true
            } catch {
                isSending = false
                errorMessage = error.localizedDescription
            }
        }
    }
}
