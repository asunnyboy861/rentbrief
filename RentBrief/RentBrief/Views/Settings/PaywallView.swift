import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    let purchaseManager: PurchaseManager
    @State private var selectedProduct: Product?
    @State private var isPurchasing = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    header
                    featureComparison
                    productPicker
                    purchaseButton
                    restoreButton
                    legalLinks
                }
                .padding()
            }
            .background(Color.backgroundLight)
            .navigationTitle("Upgrade")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .onAppear {
                selectedProduct = purchaseManager.products.first { $0.id.contains("pro.yearly") }
            }
        }
    }

    private var header: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.doc.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.primaryBlue)
            Text("Unlock Full Power")
                .font(.title.bold())
            Text("Professional reports, brand customization, and more")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }

    private var featureComparison: some View {
        VStack(spacing: 0) {
            featureRow("Up to 10 properties", free: false, pro: true)
            featureRow("All 4 report templates", free: false, pro: true)
            featureRow("Brand customization", free: false, pro: true)
            featureRow("PDF without watermark", free: false, pro: true)
            featureRow("Batch report generation", free: false, pro: true)
            featureRow("Email reports", free: false, pro: true)
            featureRow("1 property", free: true, pro: true)
            featureRow("Basic P&L report", free: true, pro: true)
        }
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func featureRow(_ text: String, free: Bool, pro: Bool) -> some View {
        HStack {
            Text(text)
                .font(.subheadline)
            Spacer()
            Image(systemName: free ? "checkmark" : "xmark")
                .foregroundStyle(free ? Color.incomeGreen : Color.expenseRed)
                .frame(width: 30)
            Image(systemName: pro ? "checkmark" : "xmark")
                .foregroundStyle(pro ? Color.incomeGreen : Color.expenseRed)
                .frame(width: 30)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .overlay(Divider(), alignment: .bottom)
    }

    private var productPicker: some View {
        VStack(spacing: 12) {
            Text("Choose Your Plan")
                .font(.headline)

            ForEach(purchaseManager.products, id: \.id) { product in
                productCard(product)
            }
        }
    }

    private func productCard(_ product: Product) -> some View {
        Button {
            selectedProduct = product
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.displayName)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                    Text(product.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(product.displayPrice)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color.primaryBlue)
                if selectedProduct?.id == product.id {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.primaryBlue)
                }
            }
            .padding()
            .background(selectedProduct?.id == product.id ? Color.lightBlue : Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(selectedProduct?.id == product.id ? Color.primaryBlue : Color.clear, lineWidth: 2)
            )
        }
    }

    private var purchaseButton: some View {
        Button {
            guard let product = selectedProduct else { return }
            isPurchasing = true
            Task {
                let success = await purchaseManager.purchase(product)
                isPurchasing = false
                if success { dismiss() }
            }
        } label: {
            HStack {
                if isPurchasing {
                    ProgressView()
                        .tint(.white)
                }
                Text(isPurchasing ? "Processing..." : "Subscribe Now")
            }
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.primaryBlue)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(isPurchasing || selectedProduct == nil)
    }

    private var restoreButton: some View {
        Button {
            Task { await purchaseManager.restorePurchases() }
        } label: {
            Text("Restore Purchases")
                .font(.subheadline)
                .foregroundStyle(Color.primaryBlue)
        }
    }

    private var legalLinks: some View {
        VStack(spacing: 8) {
            Text("14-day free trial. Cancel anytime.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
            HStack(spacing: 16) {
                Link("Privacy Policy", destination: URL(string: "https://zzoutuo.github.io/RentBrief/privacy")!)
                Link("Terms of Use", destination: URL(string: "https://zzoutuo.github.io/RentBrief/terms")!)
            }
            .font(.caption2)
        }
        .padding(.top, 8)
    }
}
