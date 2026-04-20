protocol ScoreRepositoryProtocol {
    func getBestScore() -> Int
    func saveBestScore(_ score: Int)
    func getCoins() -> Int
    func saveCoins(_ coins: Int)
    func getStreak() -> Int
    func saveStreak(_ streak: Int)
    func getLastPlayedDate() -> String?
    func saveLastPlayedDate(_ dateString: String)
}
