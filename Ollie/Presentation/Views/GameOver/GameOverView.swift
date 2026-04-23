import SwiftUI

struct GameOverView: View {
    @ObservedObject var viewModel: GameViewModel
    let onRetry:  () -> Void
    let onArenas: () -> Void
    let onHome:   () -> Void
    let onShop:   () -> Void

    private var arena: ArenaDefinition { viewModel.currentArena }

    var body: some View {
        ZStack {
            Color.ollie_cream.ignoresSafeArea()

            OllieWarriorView(size: 70, isDead: true)
                .rotationEffect(.degrees(-20))
                .opacity(0.9)
                .position(x: 130, y: 340)

            ScrollView {
                VStack(spacing: 0) {
                    Spacer().frame(height: 110)
                    card
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 40)
            }
        }
    }

    private var card: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 6) {
                Text("ollie fell.")
                    .font(.ollieMono(10))
                    .foregroundStyle(Color.ollie_muted)
                    .tracking(2.5)
                Text("game over.")
                    .font(.ollieSerif(52))
                    .foregroundStyle(Color.ollie_ink)
            }
            .padding(.top, 24)
            .padding(.horizontal, 22)

            Divider()
                .padding(.horizontal, 22)
                .padding(.vertical, 16)
                .opacity(0.2)

            VStack(spacing: 10) {
                // Arena row
                arenaRow

                // Coins earned
                HStack {
                    Text("COINS EARNED")
                        .font(.ollieMono(10))
                        .foregroundStyle(Color.ollie_muted)
                        .tracking(2)
                    Spacer()
                    HStack(spacing: 6) {
                        CoinView(size: 18)
                        Text("+\(viewModel.score.coinsEarned)")
                            .font(.ollieBody(16, weight: .bold))
                            .foregroundStyle(Color.ollie_ink)
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 14)
                .background(Color.ollie_cream, in: RoundedRectangle(cornerRadius: 14))

                // Encourage message
                Text("Keep going! You can clear this arena.")
                    .font(.ollieMono(9))
                    .foregroundStyle(Color.ollie_muted)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 6)
            }
            .padding(.horizontal, 22)

            // Actions
            VStack(spacing: 10) {
                Button(action: onRetry) {
                    HStack(spacing: 10) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 16, weight: .bold))
                        Text("TRY AGAIN")
                            .font(.ollieBody(18, weight: .bold))
                            .tracking(1)
                    }
                    .foregroundStyle(Color.ollie_paper)
                    .frame(maxWidth: .infinity)
                    .frame(height: 62)
                    .background(Color.ollie_ink, in: Capsule())
                }

                HStack(spacing: 8) {
                    Button(action: onArenas) {
                        actionLabel("ARENAS")
                    }
                    Button(action: onShop) {
                        actionLabel("SHOP")
                    }
                    Button(action: onHome) {
                        actionLabel("HOME")
                    }
                }
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 22)
            .padding(.top, 14)
        }
        .background(Color.ollie_paper, in: RoundedRectangle(cornerRadius: 28))
        .shadow(color: Color.ollie_ink.opacity(0.12), radius: 30, x: 0, y: 15)
    }

    private var arenaRow: some View {
        HStack(spacing: 10) {
            Image(systemName: arena.emojiName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(arena.accentColor)
            VStack(alignment: .leading, spacing: 2) {
                Text("FAILED IN")
                    .font(.ollieMono(8))
                    .foregroundStyle(Color.ollie_muted)
                    .tracking(1.5)
                Text(arena.name)
                    .font(.ollieBody(14, weight: .bold))
                    .foregroundStyle(Color.ollie_ink)
            }
            Spacer()
            HStack(spacing: 4) {
                ForEach(0..<3) { i in
                    Image(systemName: i < viewModel.hearts ? "heart.fill" : "heart")
                        .font(.system(size: 13))
                        .foregroundStyle(i < viewModel.hearts
                            ? Color(red: 0.92, green: 0.22, blue: 0.22)
                            : Color.ollie_muted)
                }
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(Color.ollie_cream, in: RoundedRectangle(cornerRadius: 14))
    }

    private func actionLabel(_ text: String) -> some View {
        Text(text)
            .font(.ollieBody(12, weight: .bold))
            .foregroundStyle(Color.ollie_ink)
            .tracking(1.5)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(Color.ollie_subtle, in: Capsule())
    }
}
