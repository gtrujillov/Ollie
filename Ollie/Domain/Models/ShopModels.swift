import SwiftUI

// MARK: - Category


enum ShopCategory: String, CaseIterable {
    case ollieColor = "OLLIE"
    case background = "BG"
    case lashColor  = "LASH"
    case powerUp    = "POWER"
}

// MARK: - Item

struct ShopItem: Identifiable {
    let id:          String
    let name:        LocalizedStringKey
    let description: LocalizedStringKey
    let cost:        Int
    let category:    ShopCategory
    let colorValue:  Color?
}

// MARK: - Player Inventory

struct PlayerInventory {
    var purchasedItems:  Set<String> = []
    var selectedOllieId: String      = "ollie_classic"
    var selectedBgId:    String      = "bg_parchment"
    var selectedLashId:  String      = "lash_classic"
    var activeUpgrades:  Set<String> = []
}

// MARK: - Catalog

enum ShopCatalog {
    static let items: [ShopItem] = ollieColors + backgrounds + lashColors + powerUps

    static let ollieColors: [ShopItem] = [
        ShopItem(id: "ollie_classic", name: "Classic",  description: "The original.",      cost: 0,   category: .ollieColor, colorValue: Color(red: 22/255, green: 22/255, blue: 29/255)),
        ShopItem(id: "ollie_minty",   name: "Minty",    description: "Fresh & cool.",       cost: 50,  category: .ollieColor, colorValue: Color(red: 0.25, green: 0.75, blue: 0.55)),
        ShopItem(id: "ollie_dreamy",  name: "Dreamy",   description: "Soft lavender.",      cost: 80,  category: .ollieColor, colorValue: Color(red: 0.60, green: 0.45, blue: 0.85)),
        ShopItem(id: "ollie_coral",   name: "Coral",    description: "Warm & vibrant.",     cost: 100, category: .ollieColor, colorValue: Color(red: 232/255, green: 90/255, blue: 79/255)),
        ShopItem(id: "ollie_goldie",  name: "Goldie",   description: "Pure gold.",          cost: 150, category: .ollieColor, colorValue: Color(red: 0.85, green: 0.70, blue: 0.12)),
        ShopItem(id: "ollie_shadow",  name: "Shadow",   description: "Into the dark.",      cost: 220, category: .ollieColor, colorValue: Color(red: 0.10, green: 0.10, blue: 0.25)),
    ]

    static let backgrounds: [ShopItem] = [
        ShopItem(id: "bg_parchment",  name: "Parchment", description: "Classic cream.",    cost: 0,   category: .background, colorValue: Color(red: 245/255, green: 239/255, blue: 230/255)),
        ShopItem(id: "bg_sky",        name: "Sky",        description: "Clear blue sky.",   cost: 60,  category: .background, colorValue: Color(red: 0.75, green: 0.88, blue: 0.97)),
        ShopItem(id: "bg_garden",     name: "Garden",     description: "Lush green.",       cost: 80,  category: .background, colorValue: Color(red: 0.82, green: 0.93, blue: 0.80)),
        ShopItem(id: "bg_sunset",     name: "Sunset",     description: "Warm glow.",        cost: 100, category: .background, colorValue: Color(red: 0.99, green: 0.88, blue: 0.78)),
        ShopItem(id: "bg_midnight",   name: "Midnight",   description: "Deep space.",       cost: 200, category: .background, colorValue: Color(red: 0.06, green: 0.06, blue: 0.18)),
    ]

    static let lashColors: [ShopItem] = [
        ShopItem(id: "lash_classic",  name: "Classic",  description: "Standard ink.",       cost: 0,   category: .lashColor, colorValue: Color(red: 22/255, green: 22/255, blue: 29/255)),
        ShopItem(id: "lash_forest",   name: "Forest",   description: "Deep forest green.",  cost: 75,  category: .lashColor, colorValue: Color(red: 0.10, green: 0.38, blue: 0.20)),
        ShopItem(id: "lash_navy",     name: "Navy",     description: "Oceanic blue.",        cost: 100, category: .lashColor, colorValue: Color(red: 0.10, green: 0.18, blue: 0.45)),
        ShopItem(id: "lash_crimson",  name: "Crimson",  description: "Blood red.",           cost: 150, category: .lashColor, colorValue: Color(red: 0.62, green: 0.08, blue: 0.08)),
        ShopItem(id: "lash_gilt",     name: "Gilt",     description: "Golden lashes.",       cost: 180, category: .lashColor, colorValue: Color(red: 0.75, green: 0.60, blue: 0.10)),
    ]

    static let powerUps: [ShopItem] = [
        ShopItem(id: "pw_iron",      name: "Iron Eyelid",   description: "Start each run shielded.",     cost: 120, category: .powerUp, colorValue: nil),
        ShopItem(id: "pw_rookie",    name: "Rookie Shield", description: "Shield absorbs 2 hits.",       cost: 150, category: .powerUp, colorValue: nil),
        ShopItem(id: "pw_magnet",    name: "Coin Magnet",   description: "Wider coin pickup radius.",    cost: 100, category: .powerUp, colorValue: nil),
        ShopItem(id: "pw_daredevil", name: "Daredevil",     description: "Bigger close-call zone.",      cost: 130, category: .powerUp, colorValue: nil),
    ]

    static func item(id: String) -> ShopItem? { items.first { $0.id == id } }
    static func items(in category: ShopCategory) -> [ShopItem] { items.filter { $0.category == category } }
}
