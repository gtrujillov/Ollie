import SwiftUI

struct ContentView: View {
    @StateObject private var gameVM = GameViewModel()
    @State private var screen: AppScreen = .start
    @State private var shopReturnScreen: AppScreen = .start

    var body: some View {
        ZStack {
            switch screen {
            case .start:
                StartView(
                    viewModel:     gameVM,
                    onPlay:        { gameVM.loadArena(gameVM.highestArena); screen = .gameplay },
                    onArenaSelect: { screen = .arenaSelect },
                    onShop:        { shopReturnScreen = .start; screen = .shop }
                )
                .transition(.opacity)

            case .arenaSelect:
                ArenaSelectView(
                    viewModel: gameVM,
                    onPlay:    { id in gameVM.loadArena(id); screen = .gameplay },
                    onBack:    { screen = .start }
                )
                .transition(.opacity)

            case .gameplay:
                GameplayView(
                    viewModel:       gameVM,
                    onLevelComplete: { screen = .levelComplete },
                    onGameOver:      { screen = .gameOver }
                )
                .transition(.opacity)

            case .levelComplete:
                LevelCompleteView(
                    viewModel: gameVM,
                    onNext:    { gameVM.loadArena(gameVM.arenaId + 1); screen = .gameplay },
                    onArenas:  { screen = .arenaSelect },
                    onHome:    { screen = .start }
                )
                .transition(.opacity)

            case .gameOver:
                GameOverView(
                    viewModel: gameVM,
                    onRetry:   { gameVM.loadArena(gameVM.arenaId); screen = .gameplay },
                    onArenas:  { screen = .arenaSelect },
                    onHome:    { screen = .start },
                    onShop:    { shopReturnScreen = .gameOver; screen = .shop }
                )
                .transition(.opacity)

            case .shop:
                ShopView {
                    gameVM.refreshInventory()
                    screen = shopReturnScreen
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.22), value: screen)
        .ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
