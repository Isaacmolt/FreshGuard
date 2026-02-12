import SwiftUI
import Combine

class SpaceViewModel: ObservableObject {
    var appState: AppState
    
    init(appState: AppState) {
        self.appState = appState
    }
    
    // MARK: - Traffic Light Color
    func trafficLightColor(for item: FoodItem) -> Color {
        guard let daysRemaining = item.daysRemaining else { return .clear }
        let sorted = appState.trafficLights.sorted { $0.daysThreshold < $1.daysThreshold }
        
        if daysRemaining < 0 {
            // Expired — flash red
            return Color(hex: "#FF3B30")
        }
        
        for light in sorted {
            if daysRemaining <= light.daysThreshold {
                return light.color
            }
        }
        
        // Beyond all thresholds
        return sorted.last?.color ?? Color(hex: "#34C759")
    }
    
    // MARK: - Add Item
    func addItem(to spaceID: UUID, name: String, expiryDate: Date?, section: SpaceSection?, note: String = "") {
        guard let index = appState.spaces.firstIndex(where: { $0.id == spaceID }) else { return }
        let item = FoodItem(name: name, expiryDate: expiryDate, storedDate: Date(), section: section, note: note)
        appState.spaces[index].items.append(item)
        rescheduleNotifications()
        HapticManager.notification(.success)
    }
    
    // MARK: - Delete Item
    func deleteItem(from spaceID: UUID, itemID: UUID) {
        guard let si = appState.spaces.firstIndex(where: { $0.id == spaceID }) else { return }
        appState.spaces[si].items.removeAll { $0.id == itemID }
        NotificationService.shared.removeNotifications(for: itemID)
        HapticManager.impact(.medium)
    }
    
    // MARK: - Update Item
    func updateItem(in spaceID: UUID, item: FoodItem) {
        guard let si = appState.spaces.firstIndex(where: { $0.id == spaceID }),
              let ii = appState.spaces[si].items.firstIndex(where: { $0.id == item.id }) else { return }
        appState.spaces[si].items[ii] = item
        rescheduleNotifications()
    }
    
    // MARK: - Space Management
    func addSpace(type: SpaceType, customName: String) {
        let space = SpaceItem(type: type, customName: customName, colorHex: defaultColor(for: type), sortOrder: appState.spaces.count)
        appState.spaces.append(space)
        HapticManager.notification(.success)
    }
    
    func deleteSpace(id: UUID) {
        guard appState.spaces.count > 1 else { return }
        // Remove all notifications for items in this space
        if let space = appState.spaces.first(where: { $0.id == id }) {
            for item in space.items {
                NotificationService.shared.removeNotifications(for: item.id)
            }
        }
        appState.spaces.removeAll { $0.id == id }
    }
    
    func updateSpaceColor(id: UUID, hex: String) {
        guard let i = appState.spaces.firstIndex(where: { $0.id == id }) else { return }
        appState.spaces[i].colorHex = hex
    }
    
    func renameSpace(id: UUID, name: String) {
        guard let i = appState.spaces.firstIndex(where: { $0.id == id }) else { return }
        appState.spaces[i].customName = name
    }
    
    // MARK: - Sorted Items
    func sortedItems(for space: SpaceItem, section: SpaceSection? = nil) -> [FoodItem] {
        var items = space.items
        if let section = section {
            items = items.filter { $0.section == section }
        }
        
        if space.type.showsExpiryDate {
            // Sort by urgency: expired first, then fewest days remaining
            return items.sorted { ($0.daysRemaining ?? Int.max) < ($1.daysRemaining ?? Int.max) }
        } else {
            // Wine: longest stored first
            return items.sorted { $0.daysStored > $1.daysStored }
        }
    }
    
    // MARK: - Notifications
    func rescheduleNotifications() {
        NotificationService.shared.scheduleAll(
            spaces: appState.spaces,
            trafficLights: appState.trafficLights,
            languageKey: appState.currentLanguage.rawValue
        )
    }
    
    // MARK: - Helpers
    private func defaultColor(for type: SpaceType) -> String {
        switch type {
        case .fridge:       return "#A8D8EA"
        case .snackCabinet: return "#FFDAC1"
        case .vanityTable:  return "#FCBAD3"
        case .wineCellar:   return "#C7CEEA"
        case .custom:       return "#B5EAD7"
        }
    }
    
    /// Count items expiring within X days across all spaces
    func urgentItemCount(withinDays days: Int = 3) -> Int {
        appState.spaces
            .filter { $0.type.showsExpiryDate }
            .flatMap { $0.items }
            .filter { item in
                guard let remaining = item.daysRemaining else { return false }
                return remaining <= days
            }
            .count
    }
}
