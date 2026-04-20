protocol ShopRepositoryProtocol {
    func getInventory() -> PlayerInventory
    func saveInventory(_ inventory: PlayerInventory)
}
