import SwiftUI
import SwiftData

struct ReportGeneratorView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ReportGeneratorViewModel()
    @Query private var properties: [Property]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                templatePicker
                propertyPicker
                monthPicker
                generateButton

                if viewModel.isGenerating {
                    ProgressView("Generating report...")
                        .padding()
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(Color.expenseRed)
                        .padding()
                }

                if let url = viewModel.generatedPDFURL {
                    reportActions(url)
                }
            }
            .padding()
        }
        .background(Color.backgroundLight)
        .navigationTitle("Reports")
    }

    private var templatePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Report Template")
                .font(.headline)
            ForEach(ReportTemplate.allCases, id: \.self) { template in
                templateCard(template)
            }
        }
    }

    private func templateCard(_ template: ReportTemplate) -> some View {
        Button {
            viewModel.selectedTemplate = template
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.rawValue)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                    Text(template.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if viewModel.selectedTemplate == template {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.primaryBlue)
                }
            }
            .padding()
            .background(viewModel.selectedTemplate == template ? Color.lightBlue : Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(viewModel.selectedTemplate == template ? Color.primaryBlue : Color.clear, lineWidth: 2)
            )
        }
    }

    private var propertyPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Property")
                .font(.headline)
            Picker("Select Property", selection: $viewModel.selectedProperty) {
                Text("Choose a property").tag(nil as Property?)
                ForEach(properties) { property in
                    Text(property.name).tag(property as Property?)
                }
            }
            .pickerStyle(.menu)
        }
    }

    private var monthPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Report Period")
                .font(.headline)
            DatePicker("Month", selection: $viewModel.selectedMonth, displayedComponents: .date)
        }
    }

    private var generateButton: some View {
        Button {
            Task {
                await viewModel.generateReport(modelContext: modelContext, brandConfig: BrandConfig())
            }
        } label: {
            HStack {
                Image(systemName: "doc.text.fill")
                Text("Generate Report")
            }
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(viewModel.selectedProperty == nil ? Color.gray : Color.primaryBlue)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(viewModel.selectedProperty == nil || viewModel.isGenerating)
    }

    private func reportActions(_ url: URL) -> some View {
        VStack(spacing: 12) {
            Text("Report Ready!")
                .font(.headline)
                .foregroundStyle(Color.incomeGreen)

            NavigationLink(destination: ReportPreviewView(url: url)) {
                HStack {
                    Image(systemName: "eye.fill")
                    Text("Preview PDF")
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.primaryBlue)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.lightBlue)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            ShareLink(item: url) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share Report")
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.primaryBlue)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding()
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
