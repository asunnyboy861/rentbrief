import Foundation
import SwiftData

enum PropertyType: String, Codable, CaseIterable {
    case residential = "Residential"
    case commercial = "Commercial"
    case multiFamily = "Multi-Family"
    case condo = "Condo"
}

enum TransactionCategory: String, Codable, CaseIterable {
    case rentIncome = "Rent Income"
    case lateFees = "Late Fees"
    case otherIncome = "Other Income"
    case maintenance = "Maintenance & Repairs"
    case propertyTax = "Property Tax"
    case insurance = "Insurance"
    case utilities = "Utilities"
    case managementFee = "Management Fee"
    case marketing = "Marketing"
    case supplies = "Supplies"
    case legal = "Legal & Professional"
    case mortgage = "Mortgage"
    case other = "Other"

    var isIncome: Bool {
        switch self {
        case .rentIncome, .lateFees, .otherIncome:
            return true
        default:
            return false
        }
    }
}

enum TransactionType: String, Codable {
    case income = "Income"
    case expense = "Expense"
}

enum MaintenanceStatus: String, Codable, CaseIterable {
    case open = "Open"
    case inProgress = "In Progress"
    case completed = "Completed"
}

enum PaymentStatus: String, Codable, CaseIterable {
    case current = "Current"
    case late = "Late"
    case delinquent = "Delinquent"
    case vacant = "Vacant"
}

enum ReportTemplate: String, Codable, CaseIterable {
    case simplePL = "Simple P&L"
    case detailed = "Detailed Financial"
    case detailedMaintenance = "Detailed + Maintenance"
    case fullPackage = "Full Package"

    var description: String {
        switch self {
        case .simplePL:
            return "One-page summary"
        case .detailed:
            return "Full financial breakdown"
        case .detailedMaintenance:
            return "Financials + maintenance photos"
        case .fullPackage:
            return "Everything included"
        }
    }
}
