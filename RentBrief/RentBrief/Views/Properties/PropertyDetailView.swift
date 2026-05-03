import SwiftUI
import SwiftData

struct PropertyDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let property: Property
    @State private var selectedTab = 0
    @State private var showingTransactionForm = false
    @State private var showingMaintenanceForm = false

    var body: some View {
        VStack(spacing: 0) {
            propertyHeader

            Picker("Section", selection: $selectedTab) {
                Text("Overview").tag(0)
                Text("Transactions").tag(1)
                Text("Maintenance").tag(2)
                Text("Tenants").tag(3)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            TabView(selection: $selectedTab) {
                overviewTab.tag(0)
                transactionsTab.tag(1)
                maintenanceTab.tag(2)
                tenantsTab.tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .navigationTitle(property.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingTransactionForm) {
            TransactionFormView(property: property)
        }
        .sheet(isPresented: $showingMaintenanceForm) {
            MaintenanceFormView(property: property)
        }
    }

    private var propertyHeader: some View {
        VStack(spacing: 8) {
            Text(property.fullAddress)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            HStack(spacing: 20) {
                VStack {
                    Text(property.monthlyRent.currencyString)
                        .font(.title3.bold())
                        .foregroundStyle(Color.incomeGreen)
                    Text("Monthly Rent")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                VStack {
                    Text("\(property.units)")
                        .font(.title3.bold())
                        .foregroundStyle(Color.primaryBlue)
                    Text("Units")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                VStack {
                    Text(property.managementFeePercent.percentString)
                        .font(.title3.bold())
                        .foregroundStyle(Color.warningOrange)
                    Text("Mgmt Fee")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(Color.cardBackground)
    }

    private var overviewTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                infoRow(label: "Owner", value: property.ownerName.isEmpty ? "Not set" : property.ownerName)
                infoRow(label: "Owner Email", value: property.ownerEmail.isEmpty ? "Not set" : property.ownerEmail)
                infoRow(label: "Purchase Price", value: property.purchasePrice.currencyString)
                infoRow(label: "Current Value", value: property.currentValue.currencyString)
                infoRow(label: "Type", value: property.propertyType.rawValue)
            }
            .padding()
        }
    }

    private var transactionsTab: some View {
        Group {
            if property.transactions.isEmpty {
                EmptyStateView(icon: "list.bullet.clipboard", title: "No Transactions", subtitle: "Add income or expenses")
            } else {
                List {
                    ForEach(property.transactions.sorted(by: { $0.date > $1.date })) { transaction in
                        transactionRow(transaction)
                    }
                    .onDelete { indexSet in
                        let sorted = property.transactions.sorted(by: { $0.date > $1.date })
                        for index in indexSet {
                            modelContext.delete(sorted[index])
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .overlay(alignment: .bottomTrailing) {
            Button { showingTransactionForm = true } label: {
                Image(systemName: "plus")
                    .font(.title2)
                    .padding()
                    .background(Color.primaryBlue)
                    .foregroundStyle(.white)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
            .padding()
        }
    }

    private var maintenanceTab: some View {
        Group {
            if property.maintenanceOrders.isEmpty {
                EmptyStateView(icon: "wrench.and.screwdriver", title: "No Work Orders", subtitle: "Track maintenance and repairs")
            } else {
                List {
                    ForEach(property.maintenanceOrders.sorted(by: { $0.createdAt > $1.createdAt })) { order in
                        maintenanceRow(order)
                    }
                    .onDelete { indexSet in
                        let sorted = property.maintenanceOrders.sorted(by: { $0.createdAt > $1.createdAt })
                        for index in indexSet {
                            modelContext.delete(sorted[index])
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .overlay(alignment: .bottomTrailing) {
            Button { showingMaintenanceForm = true } label: {
                Image(systemName: "plus")
                    .font(.title2)
                    .padding()
                    .background(Color.primaryBlue)
                    .foregroundStyle(.white)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
            .padding()
        }
    }

    private var tenantsTab: some View {
        Group {
            if property.tenants.isEmpty {
                EmptyStateView(icon: "person.2", title: "No Tenants", subtitle: "Add tenant information")
            } else {
                List {
                    ForEach(property.tenants) { tenant in
                        tenantRow(tenant)
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            modelContext.delete(property.tenants[index])
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }

    private func transactionRow(_ t: Transaction) -> some View {
        HStack {
            Image(systemName: t.transactionType == .income ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                .foregroundStyle(t.transactionType == .income ? Color.incomeGreen : Color.expenseRed)
            VStack(alignment: .leading, spacing: 2) {
                Text(t.category.rawValue)
                    .font(.subheadline.weight(.medium))
                Text(t.note)
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

    private func maintenanceRow(_ order: MaintenanceOrder) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(order.title)
                    .font(.subheadline.weight(.medium))
                Text(order.detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                StatusBadge(
                    text: order.status.rawValue,
                    color: order.status == .open ? .expenseRed : order.status == .inProgress ? .warningOrange : .incomeGreen
                )
                if order.cost > 0 {
                    Text(order.cost.currencyString)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func tenantRow(_ tenant: Tenant) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(tenant.name)
                    .font(.subheadline.weight(.medium))
                Text(tenant.email)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                StatusBadge(
                    text: tenant.paymentStatus.rawValue,
                    color: tenant.paymentStatus == .current ? .incomeGreen : tenant.paymentStatus == .late ? .warningOrange : .expenseRed
                )
                Text(tenant.monthlyRent.currencyString)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
