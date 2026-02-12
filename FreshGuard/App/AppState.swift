import SwiftUI
import Combine

// MARK: - Language
enum AppLanguage: String, CaseIterable, Codable {
    case zhHant = "zh-Hant"
    case zhHans = "zh-Hans"
    case en = "en"
    
    var localeIdentifier: String { rawValue }
    
    var displayName: String {
        switch self {
        case .zhHant: return "繁體中文"
        case .zhHans: return "简体中文"
        case .en: return "English"
        }
    }
    
    var calendarLocale: Locale {
        Locale(identifier: rawValue)
    }
}

// MARK: - AppState
class AppState: ObservableObject {
    @AppStorage("app_language") var currentLanguage: AppLanguage = .zhHant
    @AppStorage("is_dark_mode") var isDarkMode: Bool = false
    @AppStorage("is_pro_user") var isProUser: Bool = false
    @AppStorage("selected_timezone_id") var selectedTimezoneID: String = TimeZone.current.identifier
    @AppStorage("has_completed_onboarding") var hasCompletedOnboarding: Bool = false
    
    var selectedTimezone: TimeZone {
        TimeZone(identifier: selectedTimezoneID) ?? .current
    }
    
    @Published var trafficLights: [TrafficLight] {
        didSet { saveTrafficLights() }
    }
    
    @Published var spaces: [SpaceItem] {
        didSet { saveSpaces() }
    }
    
    @Published var currentPageIndex: Int = 0
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "traffic_lights"),
           let lights = try? JSONDecoder().decode([TrafficLight].self, from: data) {
            self.trafficLights = lights
        } else {
            self.trafficLights = TrafficLight.defaults
        }
        
        if let data = UserDefaults.standard.data(forKey: "spaces"),
           let loaded = try? JSONDecoder().decode([SpaceItem].self, from: data) {
            self.spaces = loaded
        } else {
            self.spaces = [SpaceItem.defaultFridge]
        }
    }
    
    private func saveTrafficLights() {
        if let data = try? JSONEncoder().encode(trafficLights) {
            UserDefaults.standard.set(data, forKey: "traffic_lights")
        }
    }
    
    private func saveSpaces() {
        if let data = try? JSONEncoder().encode(spaces) {
            UserDefaults.standard.set(data, forKey: "spaces")
        }
    }
    
    /// Localized string helper — reads from the correct .lproj bundle
    func L(_ key: String) -> String {
        guard let path = Bundle.main.path(forResource: currentLanguage.rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return NSLocalizedString(key, comment: "")
        }
        return NSLocalizedString(key, bundle: bundle, comment: "")
    }
    
    /// Whether the current timezone is Taiwan
    var isTaiwanTimezone: Bool {
        selectedTimezoneID.contains("Taipei")
    }
}
