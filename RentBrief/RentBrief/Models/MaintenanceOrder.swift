import SwiftData
import Foundation

@Model
final class MaintenanceOrder {
    var id: UUID
    var property: Property?
    var title: String
    var detail: String
    var status: MaintenanceStatus
    var cost: Double
    var vendorName: String
    var createdAt: Date
    var completedAt: Date?
    var beforePhotoData: Data?
    var afterPhotoData: Data?

    init(title: String, detail: String, cost: Double = 0, vendorName: String = "") {
        self.id = UUID()
        self.title = title
        self.detail = detail
        self.status = .open
        self.cost = cost
        self.vendorName = vendorName
        self.createdAt = Date()
    }
}
