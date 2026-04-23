import Foundation

final class UserDefaultsScoreRepository: ScoreRepositoryProtocol {
    private enum Keys {
        static let highestArena = "ollie-highest-arena"
        static let coins        = "ollie-coins"
    }

    func getHighestArenaUnlocked() -> Int {
        let v = UserDefaults.standard.integer(forKey: Keys.highestArena)
        return max(1, v)   // at least arena 1 is always unlocked
    }

    func saveHighestArenaUnlocked(_ arena: Int) {
        UserDefaults.standard.set(arena, forKey: Keys.highestArena)
    }

    func getCoins() -> Int { UserDefaults.standard.integer(forKey: Keys.coins) }
    func saveCoins(_ coins: Int) { UserDefaults.standard.set(coins, forKey: Keys.coins) }
}
