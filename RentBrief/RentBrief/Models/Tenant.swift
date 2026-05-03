import SwiftData
import Foundation

@Model
final class Tenant {
    var id: UUID
    var property: Property?
    var name: String
    var email: String
    var phone: String
    var leaseStartDate: Date
    var leaseEndDate: Date
    var monthlyRent: Double
    var securityDeposit: Double
    var paymentStatus: PaymentStatus
    var createdAt: Date

    init(name: String, email: String, monthlyRent: Double, leaseEndDate: Date) {
        self.id = UUID()
        self.name = name
        self.email = email
        self.phone = ""
        self.leaseStartDate = Date()
        self.leaseEndDate = leaseEndDate
        self.monthlyRent = monthlyRent
        self.securityDeposit = 0
        self.paymentStatus = .current
        self.createdAt = Date()
    }
}
