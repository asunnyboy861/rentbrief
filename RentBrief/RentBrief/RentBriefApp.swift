import SwiftUI
import SwiftData

@main
struct RentBriefApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Property.self, Transaction.self, MaintenanceOrder.self, Tenant.self])
    }
}
