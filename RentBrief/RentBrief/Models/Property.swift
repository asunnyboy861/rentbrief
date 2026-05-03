import SwiftData
import Foundation

@Model
final class Property {
    var id: UUID
    var name: String
    var address: String
    var city: String
    var state: String
    var zipCode: String
    var propertyType: PropertyType
    var units: Int
    var purchasePrice: Double
    var currentValue: Double
    var monthlyRent: Double
    var managementFeePercent: Double
    var ownerName: String
    var ownerEmail: String
    var createdAt: Date
    var updatedAt: Date
    @Relationship(deleteRule: .cascade, inverse: \Transaction.property) var transactions: [Transaction]
    @Relationship(deleteRule: .cascade, inverse: \MaintenanceOrder.property) var maintenanceOrders: [MaintenanceOrder]
    @Relationship(deleteRule: .cascade, inverse: \Tenant.property) var tenants: [Tenant]

    init(name: String, address: String, city: String, state: String, zipCode: String, propertyType: PropertyType = .residential) {
        self.id = UUID()
        self.name = name
        self.address = address
        self.city = city
        self.state = state
        self.zipCode = zipCode
        self.propertyType = propertyType
        self.units = 1
        self.purchasePrice = 0
        self.currentValue = 0
        self.monthlyRent = 0
        self.managementFeePercent = 10.0
        self.ownerName = ""
        self.ownerEmail = ""
        self.createdAt = Date()
        self.updatedAt = Date()
        self.transactions = []
        self.maintenanceOrders = []
        self.tenants = []
    }

    var fullAddress: String {
        "\(address), \(city), \(state) \(zipCode)"
    }
}
