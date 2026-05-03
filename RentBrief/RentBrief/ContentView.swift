import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                DashboardView()
            }
            .tabItem {
                Label("Dashboard", systemImage: "chart.bar.fill")
            }
            .tag(0)

            NavigationStack {
                PropertyListView()
            }
            .tabItem {
                Label("Properties", systemImage: "building.2.fill")
            }
            .tag(1)

            NavigationStack {
                TransactionListView()
            }
            .tabItem {
                Label("Records", systemImage: "list.bullet.clipboard")
            }
            .tag(2)

            NavigationStack {
                ReportGeneratorView()
            }
            .tabItem {
                Label("Reports", systemImage: "doc.text.fill")
            }
            .tag(3)
        }
        .tint(.primaryBlue)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Property.self, Transaction.self, MaintenanceOrder.self, Tenant.self])
}
