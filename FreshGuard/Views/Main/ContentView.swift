import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var storeManager: StoreManager
    @State private var showOnboarding = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Main content
            NavigationStack {
                HomeView()
            }
            
            // MARK: - Ad Banner Placeholder (bottom)
            // Reserved for future AdMob / ad integration
            // Standard banner: 50pt iPhone, 90pt iPad
            // Replace with GADBannerView (Google AdMob) when ready
            AdBannerPlaceholder()
        }
        .onAppear {
            NotificationService.shared.clearBadge()
            if !appState.hasCompletedOnboarding {
                showOnboarding = true
            }
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView(isPresented: $showOnboarding)
        }
    }
}

// MARK: - Ad Banner Placeholder
/// Replace this with actual AdMob GADBannerView when ready.
/// Standard banner height: 50pt (iPhone), 90pt (iPad leaderboard)
struct AdBannerPlaceholder: View {
    var body: some View {
        Rectangle()
            .fill(Color(.secondarySystemBackground))
            .frame(height: 50)
            .overlay(
                // Remove this overlay when integrating real ads
                Text("AD SPACE")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary.opacity(0.3))
            )
    }
}

// MARK: - Preview
#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppState())
            .environmentObject(StoreManager())
    }
}
#endif
