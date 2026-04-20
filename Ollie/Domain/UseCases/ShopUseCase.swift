import SwiftUI

struct ShopUseCase {

    func isPurchased(_ item: ShopItem, in inventory: PlayerInventory) -> Bool {
        item.cost == 0 || inventory.purchasedItems.contains(item.id)
    }

    func isSelected(_ item: ShopItem, in inventory: PlayerInventory) -> Bool {
        switch item.category {
        case .ollieColor: return inventory.selectedOllieId == item.id
        case .background: return inventory.selectedBgId    == item.id
        case .lashColor:  return inventory.selectedLashId  == item.id
        case .powerUp:    return inventory.activeUpgrades.contains(item.id)
        }
    }

    func canPurchase(_ item: ShopItem, inventory: PlayerInventory, coins: Int) -> Bool {
        !isPurchased(item, in: inventory) && coins >= item.cost
    }

    /// Returns true and mutates state if purchase succeeds.
    func purchase(_ item: ShopItem, inventory: inout PlayerInventory, coins: inout Int) -> Bool {
        guard canPurchase(item, inventory: inventory, coins: coins) else { return false }
        coins -= item.cost
        inventory.purchasedItems.insert(item.id)
        select(item, in: &inventory)
        return true
    }

    func select(_ item: ShopItem, in inventory: inout PlayerInventory) {
        guard isPurchased(item, in: inventory) else { return }
        switch item.category {
        case .ollieColor: inventory.selectedOllieId = item.id
        case .background: inventory.selectedBgId    = item.id
        case .lashColor:  inventory.selectedLashId  = item.id
        case .powerUp:    inventory.activeUpgrades.insert(item.id)
        }
    }

    func deselect(_ item: ShopItem, in inventory: inout PlayerInventory) {
        guard item.category == .powerUp else { return }
        inventory.activeUpgrades.remove(item.id)
    }

    // MARK: - Color resolvers

    func ollieColor(for inventory: PlayerInventory) -> Color {
        ShopCatalog.item(id: inventory.selectedOllieId)?.colorValue ?? .ollie_ink
    }

    func backgroundColor(for inventory: PlayerInventory) -> Color {
        ShopCatalog.item(id: inventory.selectedBgId)?.colorValue ?? .ollie_cream
    }

    func lashColor(for inventory: PlayerInventory) -> Color {
        ShopCatalog.item(id: inventory.selectedLashId)?.colorValue ?? .ollie_ink
    }
}
