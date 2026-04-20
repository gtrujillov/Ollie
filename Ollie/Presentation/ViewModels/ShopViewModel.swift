import SwiftUI
internal import Combine

final class ShopViewModel: ObservableObject {
    @Published var inventory:         PlayerInventory
    @Published var coins:             Int
    @Published var selectedCategory:  ShopCategory = .ollieColor

    private let shopUseCase = ShopUseCase()
    private let shopRepo:    ShopRepositoryProtocol
    private let scoreRepo:   ScoreRepositoryProtocol

    init(
        shopRepo:  ShopRepositoryProtocol  = UserDefaultsShopRepository(),
        scoreRepo: ScoreRepositoryProtocol = UserDefaultsScoreRepository()
    ) {
        self.shopRepo  = shopRepo
        self.scoreRepo = scoreRepo
        self.inventory = shopRepo.getInventory()
        self.coins     = scoreRepo.getCoins()
    }

    // MARK: - Queries

    var currentItems: [ShopItem] { ShopCatalog.items(in: selectedCategory) }

    func isPurchased(_ item: ShopItem) -> Bool  { shopUseCase.isPurchased(item, in: inventory) }
    func isSelected(_ item: ShopItem) -> Bool   { shopUseCase.isSelected(item, in: inventory) }
    func canPurchase(_ item: ShopItem) -> Bool  { shopUseCase.canPurchase(item, inventory: inventory, coins: coins) }

    // MARK: - Actions

    func purchase(_ item: ShopItem) {
        guard shopUseCase.purchase(item, inventory: &inventory, coins: &coins) else { return }
        shopRepo.saveInventory(inventory)
        scoreRepo.saveCoins(coins)
    }

    func select(_ item: ShopItem) {
        shopUseCase.select(item, in: &inventory)
        shopRepo.saveInventory(inventory)
    }

    func togglePowerUp(_ item: ShopItem) {
        guard item.category == .powerUp, isPurchased(item) else { return }
        if isSelected(item) {
            shopUseCase.deselect(item, in: &inventory)
        } else {
            shopUseCase.select(item, in: &inventory)
        }
        shopRepo.saveInventory(inventory)
    }

    // MARK: - Preview helpers

    var ollieColor: Color      { shopUseCase.ollieColor(for: inventory) }
    var backgroundColor: Color { shopUseCase.backgroundColor(for: inventory) }
    var lashColor: Color       { shopUseCase.lashColor(for: inventory) }
}
