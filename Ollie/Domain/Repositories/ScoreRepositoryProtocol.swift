protocol ScoreRepositoryProtocol {
    func getHighestArenaUnlocked() -> Int
    func saveHighestArenaUnlocked(_ arena: Int)
    func getCoins() -> Int
    func saveCoins(_ coins: Int)
}
