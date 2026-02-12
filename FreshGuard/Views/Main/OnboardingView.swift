import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @Binding var isPresented: Bool
    @State private var currentStep = 0
    
    private let totalSteps = 3
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Content
                TabView(selection: $currentStep) {
                    onboardingPage(
                        icon: "refrigerator.fill",
                        iconColor: Color(hex: "#A8D8EA"),
                        title: appState.L("onboard_title_1"),
                        subtitle: appState.L("onboard_sub_1")
                    ).tag(0)
                    
                    onboardingPage(
                        icon: "bell.badge.fill",
                        iconColor: Color(hex: "#FFCC00"),
                        title: appState.L("onboard_title_2"),
                        subtitle: appState.L("onboard_sub_2")
                    ).tag(1)
                    
                    onboardingPage(
                        icon: "crown.fill",
                        iconColor: .orange,
                        title: appState.L("onboard_title_3"),
                        subtitle: appState.L("onboard_sub_3")
                    ).tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .frame(height: UIScreen.main.bounds.height * 0.55)
                
                Spacer()
                
                // Button
                Button {
                    if currentStep < totalSteps - 1 {
                        withAnimation { currentStep += 1 }
                    } else {
                        appState.hasCompletedOnboarding = true
                        isPresented = false
                    }
                } label: {
                    Text(currentStep < totalSteps - 1 ? appState.L("next") : appState.L("get_started"))
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.accentColor)
                        )
                }
                .padding(.horizontal, 32)
                
                // Skip
                if currentStep < totalSteps - 1 {
                    Button {
                        appState.hasCompletedOnboarding = true
                        isPresented = false
                    } label: {
                        Text(appState.L("skip"))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 12)
                }
                
                Spacer().frame(height: 40)
            }
        }
    }
    
    private func onboardingPage(icon: String, iconColor: Color, title: String, subtitle: String) -> some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 120, height: 120)
                
                Image(systemName: icon)
                    .font(.system(size: 52, weight: .light))
                    .foregroundColor(iconColor)
            }
            
            Text(title)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
            
            Text(subtitle)
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}
