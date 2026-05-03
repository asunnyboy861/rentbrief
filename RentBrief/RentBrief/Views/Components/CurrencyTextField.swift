import SwiftUI

struct CurrencyTextField: View {
    @Binding var value: Double
    let label: String

    @State private var text: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField("0.00", text: $text)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
                .onChange(of: text) { _, newValue in
                    let cleaned = newValue.replacingOccurrences(of: "$", with: "").replacingOccurrences(of: ",", with: "")
                    if let doubleValue = Double(cleaned) {
                        value = doubleValue
                    } else if newValue.isEmpty {
                        value = 0
                    }
                }
        }
        .onAppear {
            if value != 0 {
                text = String(format: "%.2f", value)
            }
        }
    }
}
