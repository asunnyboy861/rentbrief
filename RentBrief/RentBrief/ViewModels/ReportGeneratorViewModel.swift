import SwiftUI
import SwiftData

@MainActor
@Observable
final class ReportGeneratorViewModel {
    var selectedTemplate: ReportTemplate = .simplePL
    var selectedProperty: Property?
    var selectedMonth = Date()
    var isGenerating: Bool = false
    var generatedPDFURL: URL?
    var errorMessage: String?

    func generateReport(modelContext: ModelContext, brandConfig: BrandConfig) async {
        isGenerating = true
        errorMessage = nil
        defer { isGenerating = false }

        guard let property = selectedProperty else {
            errorMessage = "Please select a property"
            return
        }

        let start = selectedMonth.startOfMonth
        let end = selectedMonth.endOfMonth

        let transactionDescriptor = FetchDescriptor<Transaction>(sortBy: [SortDescriptor(\.date)])
        let allTransactions = (try? modelContext.fetch(transactionDescriptor)) ?? []
        let propertyTransactions = allTransactions.filter { $0.property?.id == property.id && $0.date >= start && $0.date <= end }

        let maintenanceDescriptor = FetchDescriptor<MaintenanceOrder>(sortBy: [SortDescriptor(\.createdAt)])
        let allMaintenance = (try? modelContext.fetch(maintenanceDescriptor)) ?? []
        let propertyMaintenance = allMaintenance.filter { $0.property?.id == property.id && $0.createdAt >= start && $0.createdAt <= end }

        let report = MonthlyReport(
            property: property,
            period: DateInterval(start: start, end: end),
            income: propertyTransactions.filter { $0.transactionType == .income },
            expenses: propertyTransactions.filter { $0.transactionType == .expense },
            maintenanceOrders: propertyMaintenance,
            tenants: property.tenants
        )

        let generator = PDFReportGenerator()
        do {
            generatedPDFURL = try generator.generate(
                report: report,
                template: selectedTemplate,
                brandConfig: brandConfig
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct BrandConfig {
    var companyName: String = ""
    var logoData: Data?
    var primaryColorHex: String = "#2979FF"
    var accentColorHex: String = "#1565C0"
    var includePageNumbers: Bool = true
    var includeFooter: Bool = true
    var footerText: String = ""
}
