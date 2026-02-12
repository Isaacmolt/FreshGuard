import SwiftUI

// MARK: - SpaceType
enum SpaceType: String, Codable, CaseIterable {
    case fridge
    case snackCabinet = "snack_cabinet"
    case vanityTable = "vanity_table"
    case wineCellar = "wine_cellar"
    case custom
    
    var requiresPro: Bool { self != .fridge }
    
    /// Wine cellar shows stored days instead of expiry
    var showsExpiryDate: Bool { self != .wineCellar }
    
    /// Fridge = frozen/refrigerated, Vanity = cosmetics/skincare
    var hasSections: Bool {
        self == .fridge || self == .vanityTable
    }
    
    var defaultSFIcon: String {
        switch self {
        case .fridge:        return "refrigerator.fill"
        case .snackCabinet:  return "popcorn.fill"
        case .vanityTable:   return "sparkles"
        case .wineCellar:    return "wineglass.fill"
        case .custom:        return "archivebox.fill"
        }
    }
    
    var localizedKey: String {
        switch self {
        case .fridge:        return "space_fridge"
        case .snackCabinet:  return "space_snack_cabinet"
        case .vanityTable:   return "space_vanity_table"
        case .wineCellar:    return "space_wine_cellar"
        case .custom:        return "space_custom"
        }
    }
}

// MARK: - SpaceSection
enum SpaceSection: String, Codable, CaseIterable {
    case frozen
    case refrigerated
    case cosmetics
    case skincare
    
    var localizedKey: String {
        switch self {
        case .frozen:       return "section_frozen"
        case .refrigerated: return "section_refrigerated"
        case .cosmetics:    return "section_cosmetics"
        case .skincare:     return "section_skincare"
        }
    }
}

// MARK: - SpaceItem (a room/storage)
struct SpaceItem: Identifiable, Codable, Equatable, Hashable {
    var id: UUID = UUID()
    var type: SpaceType
    var customName: String = ""
    var colorHex: String = "#A8D8EA"
    var sortOrder: Int = 0
    var items: [FoodItem] = []
    
    static var defaultFridge: SpaceItem {
        SpaceItem(type: .fridge, colorHex: "#A8D8EA", sortOrder: 0)
    }
    
    var displayNameKey: String {
        if !customName.isEmpty { return customName }
        return type.localizedKey
    }
    
    var isCustomName: Bool { !customName.isEmpty }
    
    var defaultSection: SpaceSection? {
        switch type {
        case .fridge:      return .refrigerated
        case .vanityTable: return .skincare
        default:           return nil
        }
    }
    
    var sections: [SpaceSection] {
        switch type {
        case .fridge:      return [.frozen, .refrigerated]
        case .vanityTable: return [.cosmetics, .skincare]
        default:           return []
        }
    }
    
    static func == (lhs: SpaceItem, rhs: SpaceItem) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: - FoodItem
struct FoodItem: Identifiable, Codable, Equatable, Hashable {
    var id: UUID = UUID()
    var name: String
    var expiryDate: Date?
    var storedDate: Date = Date()
    var section: SpaceSection?
    var note: String = ""
    
    /// Days stored since added
    var daysStored: Int {
        max(0, Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: storedDate), to: Calendar.current.startOfDay(for: Date())).day ?? 0)
    }
    
    /// Days remaining until expiry (negative = expired)
    var daysRemaining: Int? {
        guard let expiry = expiryDate else { return nil }
        return Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: expiry)).day
    }
    
    var isExpired: Bool {
        guard let remaining = daysRemaining else { return false }
        return remaining < 0
    }
    
    func formattedExpiryDate() -> String {
        guard let date = expiryDate else { return "—" }
        let f = DateFormatter()
        f.dateFormat = "yyyy/M/d"
        return f.string(from: date)
    }
    
    func formattedStoredDate() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy/M/d"
        return f.string(from: storedDate)
    }
}

// MARK: - TrafficLight
struct TrafficLight: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var colorHex: String
    var daysThreshold: Int
    var notificationEnabled: Bool = true
    var isCustom: Bool = false
    var sortOrder: Int = 0
    
    var color: Color { Color(hex: colorHex) }
    
    static var defaults: [TrafficLight] {
        [
            TrafficLight(colorHex: "#FF3B30", daysThreshold: 3, sortOrder: 0),
            TrafficLight(colorHex: "#FFCC00", daysThreshold: 10, sortOrder: 1),
            TrafficLight(colorHex: "#34C759", daysThreshold: 30, sortOrder: 2),
        ]
    }
}
