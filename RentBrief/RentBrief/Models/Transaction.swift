import SwiftData
import Foundation

@Model
final class Transaction {
    var id: UUID
    var property: Property?
    var amount: Double
    var category: TransactionCategory
    var transactionType: TransactionType
    var note: String
    var vendorName: String
    var date: Date
    var receiptImageData: Data?
    var createdAt: Date

    init(amount: Double, category: TransactionCategory, transactionType: TransactionType, note: String, vendorName: String = "", date: Date = Date()) {
        self.id = UUID()
        self.amount = amount
        self.category = category
        self.transactionType = transactionType
        self.note = note
        self.vendorName = vendorName
        self.date = date
        self.createdAt = Date()
    }
}
