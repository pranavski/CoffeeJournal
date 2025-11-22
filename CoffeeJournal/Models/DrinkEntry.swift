import Foundation
import SwiftData

@Model
final class DrinkEntry {
    var id: UUID
    var drinkType: DrinkType
    var specificDrink: String
    var location: String
    var temperature: DrinkTemperature
    var milkType: MilkType
    var price: Double?
    var rating: Int
    var notes: String
    var mood: DrinkMood?
    var tags: [String]
    var photoData: Data?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        drinkType: DrinkType = .coffee,
        specificDrink: String = "",
        location: String = "",
        temperature: DrinkTemperature = .hot,
        milkType: MilkType = .none,
        price: Double? = nil,
        rating: Int = 0,
        notes: String = "",
        mood: DrinkMood? = nil,
        tags: [String] = [],
        photoData: Data? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.drinkType = drinkType
        self.specificDrink = specificDrink
        self.location = location
        self.temperature = temperature
        self.milkType = milkType
        self.price = price
        self.rating = rating
        self.notes = notes
        self.mood = mood
        self.tags = tags
        self.photoData = photoData
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

enum DrinkType: String, Codable, CaseIterable {
    case coffee = "Coffee"
    case matcha = "Matcha"
    case other = "Other"

    var icon: String {
        switch self {
        case .coffee: return "cup.and.saucer.fill"
        case .matcha: return "leaf.fill"
        case .other: return "mug.fill"
        }
    }

    var emoji: String {
        switch self {
        case .coffee: return "☕"
        case .matcha: return "🍵"
        case .other: return "🥤"
        }
    }

    var subTypes: [String] {
        switch self {
        case .coffee:
            return ["Espresso", "Latte", "Cappuccino", "Americano", "Cold Brew", "Mocha", "Flat White", "Macchiato"]
        case .matcha:
            return ["Traditional", "Latte", "Smoothie", "Iced Matcha", "Matcha Frappe"]
        case .other:
            return ["Tea", "Hot Chocolate", "Chai", "Golden Milk", "Other"]
        }
    }
}

enum DrinkTemperature: String, Codable, CaseIterable {
    case hot = "Hot"
    case iced = "Iced"

    var icon: String {
        switch self {
        case .hot: return "flame.fill"
        case .iced: return "snowflake"
        }
    }
}

enum MilkType: String, Codable, CaseIterable {
    case none = "None"
    case dairy = "Dairy"
    case oat = "Oat"
    case almond = "Almond"
    case soy = "Soy"
    case coconut = "Coconut"
}

enum DrinkMood: String, Codable, CaseIterable {
    case relaxing = "Relaxing"
    case energizing = "Energizing"
    case social = "Social"
    case productive = "Productive"
    case cozy = "Cozy"
    case adventurous = "Adventurous"

    var icon: String {
        switch self {
        case .relaxing: return "😌"
        case .energizing: return "⚡"
        case .social: return "👥"
        case .productive: return "💪"
        case .cozy: return "🛋️"
        case .adventurous: return "🌟"
        }
    }
}
