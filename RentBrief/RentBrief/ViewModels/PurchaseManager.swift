import SwiftUI
import SwiftData
import StoreKit

@MainActor
@Observable
final class PurchaseManager {
    var isProUser: Bool = false
    var isPortfolioUser: Bool = false
    var isLoading: Bool = true
    var products: [Product] = []
    var purchasedProductIDs: Set<String> = []

    private var transactionListener: Task<Void, Never>?
    private let productIDs = [
        "com.zzoutuo.RentBrief.pro.monthly",
        "com.zzoutuo.RentBrief.pro.yearly",
        "com.zzoutuo.RentBrief.portfolio.monthly",
        "com.zzoutuo.RentBrief.portfolio.yearly"
    ]

    init() {
        transactionListener = listenForTransactions()
        Task { await loadProducts() }
    }

    func loadProducts() async {
        do {
            products = try await Product.products(for: productIDs)
            await updatePurchaseStatus()
        } catch {
            isLoading = false
        }
    }

    func purchase(_ product: Product) async -> Bool {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                purchasedProductIDs.insert(transaction.productID)
                await updatePurchaseStatus()
                await transaction.finish()
                return true
            case .userCancelled, .pending:
                return false
            @unknown default:
                return false
            }
        } catch {
            return false
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updatePurchaseStatus()
        } catch {}
    }

    var maxProperties: Int {
        if isPortfolioUser { return Int.max }
        if isProUser { return 10 }
        return 1
    }

    var canUseBrandCustomization: Bool {
        isProUser || isPortfolioUser
    }

    var canUseAllTemplates: Bool {
        isProUser || isPortfolioUser
    }

    var canBatchReports: Bool {
        isProUser || isPortfolioUser
    }

    var canEmailReports: Bool {
        isProUser || isPortfolioUser
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task { [weak self] in
            for await result in StoreKit.Transaction.updates {
                do {
                    guard let self = self else { return }
                    let transaction = try self.checkVerified(result)
                    self.purchasedProductIDs.insert(transaction.productID)
                    await self.updatePurchaseStatus()
                    await transaction.finish()
                } catch {}
            }
        }
    }

    private func updatePurchaseStatus() async {
        var isPro = false
        var isPortfolio = false

        for productID in productIDs {
            guard let result = await StoreKit.Transaction.currentEntitlement(for: productID) else { continue }
            if let transaction = try? checkVerified(result) {
                purchasedProductIDs.insert(transaction.productID)
                if productID.contains("portfolio") {
                    isPortfolio = true
                } else if productID.contains("pro") {
                    isPro = true
                }
            }
        }

        isProUser = isPro || isPortfolio
        isPortfolioUser = isPortfolio
        isLoading = false
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let safe):
            return safe
        }
    }
}
