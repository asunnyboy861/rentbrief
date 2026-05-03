import Foundation

struct MonthlyReport {
    let property: Property
    let period: DateInterval
    let income: [Transaction]
    let expenses: [Transaction]
    let maintenanceOrders: [MaintenanceOrder]
    let tenants: [Tenant]

    var totalIncome: Double {
        income.filter { $0.transactionType == .income }.reduce(0) { $0 + $1.amount }
    }

    var totalExpenses: Double {
        expenses.filter { $0.transactionType == .expense }.reduce(0) { $0 + $1.amount }
    }

    var managementFee: Double {
        totalIncome * (property.managementFeePercent / 100.0)
    }

    var netIncome: Double {
        totalIncome - totalExpenses - managementFee
    }

    var occupancyRate: Double {
        let totalUnits = Double(property.units)
        let occupiedUnits = Double(tenants.filter { $0.paymentStatus != .vacant }.count)
        return totalUnits > 0 ? (occupiedUnits / totalUnits) * 100 : 0
    }

    var expensesByCategory: [TransactionCategory: Double] {
        Dictionary(grouping: expenses.filter { $0.transactionType == .expense }, by: { $0.category })
            .mapValues { $0.reduce(0) { $0 + $1.amount } }
    }
}
