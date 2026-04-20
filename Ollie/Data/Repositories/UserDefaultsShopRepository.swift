import Foundation

final class UserDefaultsShopRepository: ShopRepositoryProtocol {
    private let key = "ollie-inventory-v1"

    func getInventory() -> PlayerInventory {
        guard
            let data    = UserDefaults.standard.data(forKey: key),
            let stored  = try? JSONDecoder().decode(Stored.self, from: data)
        else { return PlayerInventory() }

        var inv = PlayerInventory()
        inv.purchasedItems  = Set(stored.purchasedItems)
        inv.selectedOllieId = stored.selectedOllieId
        inv.selectedBgId    = stored.selectedBgId
        inv.selectedLashId  = stored.selectedLashId
        inv.activeUpgrades  = Set(stored.activeUpgrades)
        return inv
    }

    func saveInventory(_ inventory: PlayerInventory) {
        let stored = Stored(
            purchasedItems:  Array(inventory.purchasedItems),
            selectedOllieId: inventory.selectedOllieId,
            selectedBgId:    inventory.selectedBgId,
            selectedLashId:  inventory.selectedLashId,
            activeUpgrades:  Array(inventory.activeUpgrades)
        )
        if let data = try? JSONEncoder().encode(stored) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}

private struct Stored: Codable {
    var purchasedItems:  [String]
    var selectedOllieId: String
    var selectedBgId:    String
    var selectedLashId:  String
    var activeUpgrades:  [String]
}
