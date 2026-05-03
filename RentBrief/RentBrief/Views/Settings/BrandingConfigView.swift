import SwiftUI

struct BrandingConfigView: View {
    @AppStorage("companyName") private var companyName = ""
    @AppStorage("primaryColorHex") private var primaryColorHex = "#2979FF"
    @AppStorage("footerText") private var footerText = ""
    @AppStorage("includePageNumbers") private var includePageNumbers = true

    var body: some View {
        Form {
            Section("Company Info") {
                TextField("Company Name", text: $companyName)
                TextField("Footer Text", text: $footerText)
            }

            Section("Report Options") {
                Toggle("Include Page Numbers", isOn: $includePageNumbers)
            }

            Section("Preview") {
                reportPreview
            }
        }
        .navigationTitle("Brand Customization")
    }

    private var reportPreview: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !companyName.isEmpty {
                Text(companyName)
                    .font(.headline)
                    .foregroundStyle(Color.primaryBlue)
            }
            Text("Property Report")
                .font(.title3.bold())
            Divider()
            HStack {
                Text("Sample KPI Card")
                    .font(.caption)
                Spacer()
                Text("$1,234")
                    .font(.caption.bold())
                    .foregroundStyle(Color.incomeGreen)
            }
            .padding(8)
            .background(Color.lightBlue)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            if !footerText.isEmpty {
                Text(footerText)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
