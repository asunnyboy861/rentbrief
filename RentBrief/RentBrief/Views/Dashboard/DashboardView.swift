import SwiftUI
import SwiftData
import Charts

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = DashboardViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                MonthPickerView(selectedMonth: $viewModel.selectedMonth)
                    .onChange(of: viewModel.selectedMonth) { _, _ in viewModel.loadData(modelContext: modelContext) }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    KPICardView(title: "Total Income", value: viewModel.totalIncome.currencyString, color: .incomeGreen, icon: "arrow.up.circle.fill")
                    KPICardView(title: "Total Expenses", value: viewModel.totalExpenses.currencyString, color: .expenseRed, icon: "arrow.down.circle.fill")
                    KPICardView(title: "Net Income", value: viewModel.netIncome.currencyString, color: .primaryBlue, icon: "chart.line.uptrend.xyaxis")
                    KPICardView(title: "Occupancy", value: viewModel.occupancyRate.percentString, color: .warningOrange, icon: "building.2.fill")
                }

                if !viewModel.incomeByMonth.isEmpty {
                    incomeExpenseChart
                }

                if !viewModel.expenseByCategory.isEmpty {
                    expenseCategoryChart
                }

                HStack(spacing: 12) {
                    quickStatCard(title: "Properties", value: "\(viewModel.propertyCount)", icon: "building.2")
                    quickStatCard(title: "Active Work Orders", value: "\(viewModel.activeMaintenanceCount)", icon: "wrench.and.screwdriver")
                }
            }
            .padding()
        }
        .background(Color.backgroundLight)
        .navigationTitle("Dashboard")
        .onAppear { viewModel.loadData(modelContext: modelContext) }
    }

    private var incomeExpenseChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Income vs Expenses")
                .font(.headline)

            Chart {
                ForEach(viewModel.incomeByMonth, id: \.0) { item in
                    BarMark(
                        x: .value("Month", String(item.0.prefix(3))),
                        y: .value("Income", item.1)
                    )
                    .foregroundStyle(Color.incomeGreen)
                    .position(by: .value("Type", "Income"))
                }
                ForEach(viewModel.expenseByMonth, id: \.0) { item in
                    BarMark(
                        x: .value("Month", String(item.0.prefix(3))),
                        y: .value("Expenses", item.1)
                    )
                    .foregroundStyle(Color.expenseRed)
                    .position(by: .value("Type", "Expenses"))
                }
            }
            .frame(height: 200)
            .chartYAxisLabel("USD")
        }
        .padding()
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    private var expenseCategoryChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Expense Breakdown")
                .font(.headline)

            Chart(viewModel.expenseByCategory, id: \.0) { item in
                SectorMark(
                    angle: .value("Amount", item.1),
                    innerRadius: .ratio(0.5),
                    angularInset: 1.5
                )
                .foregroundStyle(Color.expenseRed.opacity(0.3 + 0.7 * Double(viewModel.expenseByCategory.firstIndex(where: { $0.0 == item.0 }) ?? 0) / max(Double(viewModel.expenseByCategory.count), 1)))
                .annotation(position: .overlay) {
                    if item.1 / viewModel.totalExpenses > 0.1 {
                        VStack {
                            Text(item.0.prefix(10))
                                .font(.caption2)
                            Text(item.1.currencyString)
                                .font(.caption2.bold())
                        }
                        .foregroundStyle(.white)
                    }
                }
            }
            .frame(height: 200)
        }
        .padding()
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    private func quickStatCard(title: String, value: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.primaryBlue)
            VStack(alignment: .leading) {
                Text(value)
                    .font(.title3.bold())
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}
