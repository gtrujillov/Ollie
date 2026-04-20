import Foundation

final class UserDefaultsScoreRepository: ScoreRepositoryProtocol {
    private enum Keys {
        static let best       = "ollie-best"
        static let coins      = "ollie-coins"
        static let streak     = "ollie-streak"
        static let lastPlayed = "ollie-last-played"
    }

    func getBestScore() -> Int { UserDefaults.standard.integer(forKey: Keys.best) }
    func saveBestScore(_ score: Int) { UserDefaults.standard.set(score, forKey: Keys.best) }
    func getCoins() -> Int { UserDefaults.standard.integer(forKey: Keys.coins) }
    func saveCoins(_ coins: Int) { UserDefaults.standard.set(coins, forKey: Keys.coins) }
    func getStreak() -> Int { UserDefaults.standard.integer(forKey: Keys.streak) }
    func saveStreak(_ streak: Int) { UserDefaults.standard.set(streak, forKey: Keys.streak) }
    func getLastPlayedDate() -> String? { UserDefaults.standard.string(forKey: Keys.lastPlayed) }
    func saveLastPlayedDate(_ dateString: String) { UserDefaults.standard.set(dateString, forKey: Keys.lastPlayed) }
}
