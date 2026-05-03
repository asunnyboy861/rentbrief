import SwiftUI
import SwiftData

@MainActor
@Observable
final class DashboardViewModel {
    var selectedMonth = Date()
    var totalIncome: Double = 0
    var totalExpenses: Double = 0
    var netIncome: Double = 0
    var occupancyRate: Double = 0
    var propertyCount: Int = 0
    var activeMaintenanceCount: Int = 0
    var incomeByMonth: [(String, Double)] = []
    var expenseByMonth: [(String, Double)] = []
    var expenseByCategory: [(String, Double)] = []

    func loadData(modelContext: ModelContext) {
        let start = selectedMonth.startOfMonth
        let end = selectedMonth.endOfMonth

        let propertyDescriptor = FetchDescriptor<Property>()
        let allProperties = (try? modelContext.fetch(propertyDescriptor)) ?? []
        propertyCount = allProperties.count

        let transactionDescriptor = FetchDescriptor<Transaction>(sortBy: [SortDescriptor(\.date)])
        let allTransactions = (try? modelContext.fetch(transactionDescriptor)) ?? []
        let transactions = allTransactions.filter { $0.date >= start && $0.date <= end }

        totalIncome = transactions.filter { $0.transactionType == .income }.reduce(0) { $0 + $1.amount }
        totalExpenses = transactions.filter { $0.transactionType == .expense }.reduce(0) { $0 + $1.amount }
        netIncome = totalIncome - totalExpenses

        let maintenanceDescriptor = FetchDescriptor<MaintenanceOrder>(sortBy: [SortDescriptor(\.createdAt)])
        let allMaintenance = (try? modelContext.fetch(maintenanceDescriptor)) ?? []
        activeMaintenanceCount = allMaintenance.filter { $0.status != .completed }.count

        let allTenants = allProperties.flatMap { $0.tenants }
        let occupiedCount = allTenants.filter { $0.paymentStatus != .vacant }.count
        let totalUnits = allProperties.reduce(0) { $0 + $1.units }
        occupancyRate = totalUnits > 0 ? Double(occupiedCount) / Double(totalUnits) * 100 : 0

        loadChartData(modelContext: modelContext, allTransactions: allTransactions)
    }

    private func loadChartData(modelContext: ModelContext, allTransactions: [Transaction]) {
        let calendar = Calendar.current
        var incomeData: [(String, Double)] = []
        var expenseData: [(String, Double)] = []

        for i in (0..<6).reversed() {
            guard let monthDate = calendar.date(byAdding: .month, value: -i, to: selectedMonth) else { continue }
            let start = monthDate.startOfMonth
            let end = monthDate.endOfMonth
            let label = monthDate.monthYearString

            let transactions = allTransactions.filter { $0.date >= start && $0.date <= end }

            let income = transactions.filter { $0.transactionType == .income }.reduce(0) { $0 + $1.amount }
            let expense = transactions.filter { $0.transactionType == .expense }.reduce(0) { $0 + $1.amount }

            incomeData.append((label, income))
            expenseData.append((label, expense))
        }

        incomeByMonth = incomeData
        expenseByMonth = expenseData

        let start = selectedMonth.startOfMonth
        let end = selectedMonth.endOfMonth
        let expenses = allTransactions.filter { $0.transactionType == .expense && $0.date >= start && $0.date <= end }
        let grouped = Dictionary(grouping: expenses, by: { $0.category.rawValue })
        expenseByCategory = grouped.map { ($0.key, $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.1 > $1.1 }
    }
}
