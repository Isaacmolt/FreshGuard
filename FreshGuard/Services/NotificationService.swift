import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()
    private init() {}
    
    // MARK: - Permission
    func requestPermission(completion: ((Bool) -> Void)? = nil) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                completion?(granted)
            }
            if let error = error {
                print("[NotificationService] Permission error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Schedule All
    func scheduleAll(spaces: [SpaceItem], trafficLights: [TrafficLight], languageKey: String) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        let enabledLights = trafficLights.filter { $0.notificationEnabled }.sorted { $0.daysThreshold < $1.daysThreshold }
        guard !enabledLights.isEmpty else { return }
        
        for space in spaces {
            guard space.type.showsExpiryDate else { continue }
            
            for item in space.items {
                guard let expiryDate = item.expiryDate else { continue }
                
                for light in enabledLights {
                    scheduleNotification(
                        item: item,
                        daysBeforeExpiry: light.daysThreshold,
                        expiryDate: expiryDate,
                        languageKey: languageKey
                    )
                }
            }
        }
    }
    
    // MARK: - Schedule Single
    private func scheduleNotification(item: FoodItem, daysBeforeExpiry: Int, expiryDate: Date, languageKey: String) {
        let cal = Calendar.current
        guard let triggerDate = cal.date(byAdding: .day, value: -daysBeforeExpiry, to: cal.startOfDay(for: expiryDate)) else { return }
        
        // Set notification for 9:00 AM
        var triggerComponents = cal.dateComponents([.year, .month, .day], from: triggerDate)
        triggerComponents.hour = 9
        triggerComponents.minute = 0
        
        // Skip if already in the past
        guard let fullTriggerDate = cal.date(from: triggerComponents), fullTriggerDate > Date() else { return }
        
        let content = UNMutableNotificationContent()
        content.sound = .default
        content.badge = 1
        
        switch languageKey {
        case "zh-Hant":
            content.title = "🧊 鮮守衛提醒"
            if daysBeforeExpiry == 0 {
                content.body = "「\(item.name)」今天到期了！"
            } else {
                content.body = "「\(item.name)」還有 \(daysBeforeExpiry) 天就要過期囉！"
            }
        case "zh-Hans":
            content.title = "🧊 鲜守卫提醒"
            if daysBeforeExpiry == 0 {
                content.body = "「\(item.name)」今天到期了！"
            } else {
                content.body = "「\(item.name)」还有 \(daysBeforeExpiry) 天就要过期了！"
            }
        default:
            content.title = "🧊 FreshGuard Reminder"
            if daysBeforeExpiry == 0 {
                content.body = "\"\(item.name)\" expires today!"
            } else {
                content.body = "\"\(item.name)\" expires in \(daysBeforeExpiry) day\(daysBeforeExpiry > 1 ? "s" : "")!"
            }
        }
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
        let identifier = "\(item.id.uuidString)_\(daysBeforeExpiry)d"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("[NotificationService] Schedule error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Remove for Item
    func removeNotifications(for itemID: UUID) {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            let ids = requests.filter { $0.identifier.hasPrefix(itemID.uuidString) }.map { $0.identifier }
            center.removePendingNotificationRequests(withIdentifiers: ids)
        }
    }
    
    // MARK: - Clear Badge
    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0) { _ in }
    }
}
