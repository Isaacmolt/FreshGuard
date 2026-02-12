import SwiftUI

struct SubscriptionView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var storeManager: StoreManager
    @Environment(\.dismiss) private var dismiss
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var errorMsg = ""
    
    private var info: StoreManager.PriceInfo {
        storeManager.priceInfo(for: appState.selectedTimezoneID)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    // Crown header
                    header
                    
                    // Feature list
                    features
                    
                    // Already Pro?
                    if appState.isProUser {
                        proActiveBadge
                    } else {
                        // Pricing
                        pricing
                        
                        // Bait text
                        baitText
                    }
                    
                    // Restore
                    Button {
                        Task { await storeManager.restorePurchases() }
                    } label: {
                        Text(appState.L("restore_purchases"))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.accentColor)
                    }
                    .padding(.top, 4)
                    
                    // Legal
                    legalLinks
                    
                    Spacer(minLength: 40)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .alert(appState.L("error"), isPresented: $showError) {
                Button(appState.L("confirm")) {}
            } message: {
                Text(errorMsg)
            }
        }
    }
    
    // MARK: - Header
    private var header: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(colors: [.orange.opacity(0.2), .yellow.opacity(0.1)],
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 100, height: 100)
                
                Image(systemName: "crown.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(
                        LinearGradient(colors: [.orange, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
            }
            .padding(.top, 24)
            
            Text("FreshGuard Pro")
                .font(.system(size: 30, weight: .bold, design: .rounded))
            
            Text(appState.L("pro_description"))
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
    
    // MARK: - Features
    private var features: some View {
        VStack(alignment: .leading, spacing: 18) {
            featureRow("popcorn.fill", appState.L("pro_feature_snack"))
            featureRow("sparkles", appState.L("pro_feature_vanity"))
            featureRow("wineglass.fill", appState.L("pro_feature_wine"))
            featureRow("paintpalette.fill", appState.L("pro_feature_custom_lights"))
            featureRow("rectangle.stack.fill", appState.L("pro_feature_unlimited"))
            featureRow("person.text.rectangle.fill", appState.L("pro_feature_naming"))
        }
        .padding(.horizontal, 36)
    }
    
    private func featureRow(_ icon: String, _ text: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 17))
                .foregroundColor(.orange)
                .frame(width: 28)
            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.primary)
        }
    }
    
    // MARK: - Pricing Cards
    private var pricing: some View {
        VStack(spacing: 14) {
            // Monthly
            pricingCard(
                title: appState.L("monthly"),
                price: info.monthlyDisplay,
                subtitle: info.isTWD
                    ? appState.L("monthly_subtitle_twd")
                    : appState.L("monthly_subtitle_usd"),
                productID: StoreManager.monthlyID,
                highlight: false
            )
            
            // Lifetime
            pricingCard(
                title: appState.L("lifetime"),
                price: info.lifetimeDisplay,
                subtitle: appState.L("one_time_purchase"),
                productID: StoreManager.lifetimeID,
                highlight: true
            )
        }
        .padding(.horizontal, 24)
    }
    
    private func pricingCard(title: String, price: String, subtitle: String, productID: String, highlight: Bool) -> some View {
        Button {
            Task { await purchase(productID: productID) }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(title)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        if highlight {
                            Text(appState.L("best_value"))
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(Color.orange))
                        }
                    }
                    
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(price)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .strokeBorder(highlight ? Color.orange.opacity(0.5) : .clear, lineWidth: 2)
                    )
                    .shadow(color: highlight ? Color.orange.opacity(0.1) : .clear, radius: 8, y: 4)
            )
        }
        .disabled(isPurchasing)
        .opacity(isPurchasing ? 0.6 : 1)
    }
    
    // MARK: - Bait Text
    private var baitText: some View {
        Text(info.isTWD ? appState.L("bait_text_twd") : appState.L("bait_text_usd"))
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundColor(.orange)
    }
    
    // MARK: - Pro Active
    private var proActiveBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.seal.fill")
                .foregroundColor(.green)
            Text(appState.L("pro_active"))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.green)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.green.opacity(0.1))
        )
    }
    
    // MARK: - Legal Links
    private var legalLinks: some View {
        HStack(spacing: 16) {
            Link(appState.L("terms_of_service"), destination: URL(string: "https://freshguard.app/terms")!)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            
            Text("·").foregroundColor(.secondary)
            
            Link(appState.L("privacy_policy"), destination: URL(string: "https://freshguard.app/privacy")!)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .padding(.bottom, 16)
    }
    
    // MARK: - Purchase Logic
    private func purchase(productID: String) async {
        isPurchasing = true
        defer { isPurchasing = false }
        
        guard let product = storeManager.products.first(where: { $0.id == productID }) else {
            errorMsg = appState.L("product_not_found")
            showError = true
            return
        }
        
        do {
            _ = try await storeManager.purchase(product)
            if storeManager.isPro {
                HapticManager.notification(.success)
                appState.isProUser = true
                dismiss()
            }
        } catch {
            errorMsg = error.localizedDescription
            showError = true
        }
    }
}
