import Foundation
import StoreKit

@MainActor
class StoreManager: ObservableObject {
    // MARK: - Product IDs (must match App Store Connect)
    static let monthlyID  = "com.freshguard.pro.monthly"
    static let lifetimeID = "com.freshguard.pro.lifetime"
    
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var updateListener: Task<Void, Error>?
    
    var isPro: Bool { !purchasedProductIDs.isEmpty }
    
    // MARK: - Price Display
    struct PriceInfo {
        let monthlyDisplay: String
        let lifetimeDisplay: String
        let dailyCostText: String
        let isTWD: Bool
    }
    
    /// Returns display prices based on timezone
    /// Taiwan → NT$, others → USD
    func priceInfo(for timezoneID: String) -> PriceInfo {
        let isTaiwan = timezoneID.contains("Taipei")
        
        // If StoreKit products loaded, use real prices
        if !products.isEmpty {
            let monthly = products.first { $0.id == StoreManager.monthlyID }
            let lifetime = products.first { $0.id == StoreManager.lifetimeID }
            return PriceInfo(
                monthlyDisplay: monthly?.displayPrice ?? (isTaiwan ? "NT$ 35" : "$1.19"),
                lifetimeDisplay: lifetime?.displayPrice ?? (isTaiwan ? "NT$ 190" : "$5.99"),
                dailyCostText: isTaiwan ? "1" : "$0.04",
                isTWD: isTaiwan
            )
        }
        
        // Fallback display prices
        if isTaiwan {
            return PriceInfo(monthlyDisplay: "NT$ 35", lifetimeDisplay: "NT$ 190", dailyCostText: "1", isTWD: true)
        } else {
            return PriceInfo(monthlyDisplay: "$1.19", lifetimeDisplay: "$5.99", dailyCostText: "$0.04", isTWD: false)
        }
    }
    
    // MARK: - Init
    init() {
        updateListener = listenForTransactions()
        Task { await loadProducts() }
        Task { await refreshPurchaseStatus() }
    }
    
    deinit { updateListener?.cancel() }
    
    // MARK: - Load Products
    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        do {
            products = try await Product.products(for: [StoreManager.monthlyID, StoreManager.lifetimeID])
        } catch {
            print("[StoreManager] Load products error: \(error)")
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Purchase
    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let txn = try checkVerified(verification)
            await refreshPurchaseStatus()
            await txn.finish()
            return txn
        case .userCancelled:
            return nil
        case .pending:
            return nil
        @unknown default:
            return nil
        }
    }
    
    // MARK: - Restore
    func restorePurchases() async {
        try? await AppStore.sync()
        await refreshPurchaseStatus()
    }
    
    // MARK: - Refresh
    func refreshPurchaseStatus() async {
        var purchased: Set<String> = []
        for await result in Transaction.currentEntitlements {
            if let txn = try? checkVerified(result) {
                purchased.insert(txn.productID)
            }
        }
        purchasedProductIDs = purchased
    }
    
    // MARK: - Verify
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error): throw error
        case .verified(let value): return value
        }
    }
    
    // MARK: - Transaction Listener
    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                if let txn = try? self.checkVerified(result) {
                    await self.refreshPurchaseStatus()
                    await txn.finish()
                }
            }
        }
    }
}
