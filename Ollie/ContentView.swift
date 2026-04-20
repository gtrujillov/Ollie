import SwiftUI

struct ContentView: View {
    @StateObject private var gameVM = GameViewModel()
    @State private var screen: AppScreen = .start
    @State private var shopReturnScreen: AppScreen = .start
    @AppStorage("ollie-tutorial-v1") private var tutorialSeen = false

    var body: some View {
        ZStack {
            switch screen {
            case .start:
                StartView(
                    viewModel: gameVM,
                    onPlay: { screen = .gameplay },
                    onShop: { shopReturnScreen = .start; screen = .shop }
                )
                .transition(.opacity)

            case .gameplay:
                GameplayView(viewModel: gameVM) {
                    screen = .gameOver
                }
                .transition(.opacity)

            case .gameOver:
                GameOverView(
                    viewModel: gameVM,
                    onReplay: { gameVM.prepareForReplay(); screen = .gameplay },
                    onHome:   { gameVM.prepareForReplay(); screen = .start },
                    onShop:   { shopReturnScreen = .gameOver; screen = .shop }
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
        .fullScreenCover(isPresented: .init(
            get: { !tutorialSeen },
            set: { if !$0 { tutorialSeen = true } }
        )) {
            TutorialView { tutorialSeen = true }
        }
    }
}

#Preview {
    ContentView()
}
