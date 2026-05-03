import SwiftUI
import SwiftData

struct MaintenanceListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddForm = false
    @Query(sort: \MaintenanceOrder.createdAt, order: .reverse) private var orders: [MaintenanceOrder]

    var body: some View {
        Group {
            if orders.isEmpty {
                EmptyStateView(icon: "wrench.and.screwdriver", title: "No Work Orders", subtitle: "Track maintenance and repairs")
            } else {
                List {
                    ForEach(orders) { order in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(order.title)
                                    .font(.subheadline.weight(.medium))
                                Spacer()
                                StatusBadge(
                                    text: order.status.rawValue,
                                    color: order.status == .open ? .expenseRed : order.status == .inProgress ? .warningOrange : .incomeGreen
                                )
                            }
                            Text(order.detail)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                            HStack {
                                Text(order.property?.name ?? "Unassigned")
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                                Spacer()
                                if order.cost > 0 {
                                    Text(order.cost.currencyString)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding(.vertical, 2)
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            modelContext.delete(orders[index])
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Work Orders")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { showingAddForm = true } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddForm) {
            MaintenanceFormView()
        }
    }
}
