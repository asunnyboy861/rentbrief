import SwiftUI
import SwiftData

struct TransactionListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = TransactionListViewModel()
    @State private var showingAddForm = false

    var body: some View {
        Group {
            if viewModel.filteredTransactions.isEmpty {
                EmptyStateView(icon: "list.bullet.clipboard", title: "No Transactions", subtitle: "Record your first income or expense")
            } else {
                List {
                    ForEach(viewModel.filteredTransactions) { transaction in
                        transactionRow(transaction)
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            viewModel.deleteTransaction(viewModel.filteredTransactions[index], modelContext: modelContext)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .searchable(text: $viewModel.searchText, prompt: "Search transactions")
        .navigationTitle("Records")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { showingAddForm = true } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddForm) {
            TransactionFormView()
        }
        .onAppear { viewModel.loadTransactions(modelContext: modelContext) }
    }

    private func transactionRow(_ t: Transaction) -> some View {
        HStack {
            Image(systemName: t.transactionType == .income ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                .foregroundStyle(t.transactionType == .income ? Color.incomeGreen : Color.expenseRed)
                .font(.title3)
            VStack(alignment: .leading, spacing: 2) {
                Text(t.category.rawValue)
                    .font(.subheadline.weight(.medium))
                Text(t.property?.name ?? "Unassigned")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(t.amount.currencyString)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(t.transactionType == .income ? Color.incomeGreen : Color.expenseRed)
                Text(t.date.shortDateString)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 2)
    }
}
