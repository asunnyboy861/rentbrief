import SwiftUI
import SwiftData

@MainActor
@Observable
final class TransactionListViewModel {
    var transactions: [Transaction] = []
    var searchText: String = ""
    var filterType: TransactionType?
    var selectedMonth = Date()

    var filteredTransactions: [Transaction] {
        var result = transactions
        if !searchText.isEmpty {
            result = result.filter {
                $0.note.localizedCaseInsensitiveContains(searchText) ||
                $0.vendorName.localizedCaseInsensitiveContains(searchText) ||
                $0.category.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }
        if let filterType {
            result = result.filter { $0.transactionType == filterType }
        }
        return result.sorted { $0.date > $1.date }
    }

    func loadTransactions(modelContext: ModelContext) {
        let start = selectedMonth.startOfMonth
        let end = selectedMonth.endOfMonth
        let descriptor = FetchDescriptor<Transaction>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        let all = (try? modelContext.fetch(descriptor)) ?? []
        transactions = all.filter { $0.date >= start && $0.date <= end }
    }

    func deleteTransaction(_ transaction: Transaction, modelContext: ModelContext) {
        modelContext.delete(transaction)
        try? modelContext.save()
        loadTransactions(modelContext: modelContext)
    }
}
