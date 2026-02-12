import SwiftUI

@main
struct FreshGuardApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var storeManager = StoreManager()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(storeManager)
                .preferredColorScheme(appState.isDarkMode ? .dark : nil)
                .environment(\.locale, Locale(identifier: appState.currentLanguage.localeIdentifier))
                .onAppear {
                    // Sync Pro status
                    appState.isProUser = storeManager.isPro
                }
                .onChange(of: storeManager.isPro) { newValue in
                    appState.isProUser = newValue
                }
        }
    }
}

// MARK: - AppDelegate for Notification Handling
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
        return true
    }
    
    // Show notification even when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}
