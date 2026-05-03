import SwiftUI
import SwiftData

struct SettingsView: View {
    @AppStorage("companyName") private var companyName = ""
    @AppStorage("primaryColorHex") private var primaryColorHex = "#2979FF"
    @AppStorage("footerText") private var footerText = ""
    @AppStorage("includePageNumbers") private var includePageNumbers = true
    @State private var showPaywall = false
    @State private var purchaseManager = PurchaseManager()

    var body: some View {
        NavigationStack {
            List {
                subscriptionSection
                brandingSection
                reportSection
                aboutSection
            }
            .navigationTitle("Settings")
        }
    }

    private var subscriptionSection: some View {
        Section("Subscription") {
            if purchaseManager.isProUser {
                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundStyle(Color.warningOrange)
                    Text(purchaseManager.isPortfolioUser ? "Portfolio Plan" : "Pro Plan")
                        .font(.subheadline.weight(.medium))
                    Spacer()
                    Text("Active")
                        .font(.caption)
                        .foregroundStyle(Color.incomeGreen)
                }
            } else {
                Button {
                    showPaywall = true
                } label: {
                    HStack {
                        Image(systemName: "crown")
                            .foregroundStyle(Color.warningOrange)
                        Text("Upgrade to Pro")
                            .font(.subheadline.weight(.medium))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }

            Button {
                Task { await purchaseManager.restorePurchases() }
            } label: {
                Text("Restore Purchases")
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(purchaseManager: purchaseManager)
        }
    }

    private var brandingSection: some View {
        Section("Brand Customization") {
            if purchaseManager.canUseBrandCustomization {
                TextField("Company Name", text: $companyName)
                TextField("Footer Text", text: $footerText)
                Toggle("Include Page Numbers", isOn: $includePageNumbers)
            } else {
                Button {
                    showPaywall = true
                } label: {
                    HStack {
                        Text("Company Name & Logo")
                        Spacer()
                        Image(systemName: "lock.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private var reportSection: some View {
        Section("Reports") {
            NavigationLink {
                CSVExportView()
            } label: {
                Label("Export CSV Data", systemImage: "tablecells")
            }
        }
    }

    private var aboutSection: some View {
        Section("About") {
            HStack {
                Text("Version")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                    .foregroundStyle(.secondary)
            }
            NavigationLink {
                ContactSupportView()
            } label: {
                Label("Contact Support", systemImage: "envelope")
            }
            Link(destination: URL(string: "https://zzoutuo.github.io/RentBrief/privacy")!) {
                Label("Privacy Policy", systemImage: "hand.raised")
            }
            Link(destination: URL(string: "https://zzoutuo.github.io/RentBrief/terms")!) {
                Label("Terms of Use", systemImage: "doc.text")
            }
            Link(destination: URL(string: "https://zzoutuo.github.io/RentBrief/support")!) {
                Label("Support Page", systemImage: "questionmark.circle")
            }
        }
    }
}

struct CSVExportView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var exportedURL: URL?
    @State private var showShare = false

    var body: some View {
        VStack(spacing: 20) {
            if let url = exportedURL {
                Text("CSV exported successfully!")
                    .foregroundStyle(Color.incomeGreen)
                ShareLink(item: url) {
                    Label("Share CSV File", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button("Export All Transactions") {
                    let descriptor = FetchDescriptor<Transaction>(sortBy: [SortDescriptor(\.date, order: .reverse)])
                    let transactions = (try? modelContext.fetch(descriptor)) ?? []
                    exportedURL = CSVExporter.exportTransactions(transactions)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .navigationTitle("Export CSV")
    }
}
