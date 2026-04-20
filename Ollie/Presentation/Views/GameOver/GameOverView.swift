import SwiftUI

struct GameOverView: View {
    @ObservedObject var viewModel: GameViewModel
    let onReplay: () -> Void
    let onHome:   () -> Void
    let onShop:   () -> Void

    private var isNewBest: Bool { viewModel.score.current >= viewModel.score.best && viewModel.score.current > 0 }

    private var leaderboard: [(name: String, score: Int, isYou: Bool)] {
        let entries: [(name: String, score: Int, isYou: Bool)] = [
            (name: "maya_k",  score: 118,                         isYou: false),
            (name: "dev_jun", score: 96,                          isYou: false),
            (name: "you",     score: viewModel.score.current,     isYou: true),
            (name: "lilmeow", score: 31,                          isYou: false),
        ]
        return Array(entries.sorted { $0.score > $1.score }.prefix(4))
    }

    var body: some View {
        ZStack {
            Color.ollie_cream.ignoresSafeArea()

            // Dead Ollie in background
            OllieCharacterView(size: 70, isDead: true)
                .rotationEffect(.degrees(-24))
                .opacity(0.9)
                .position(x: 140, y: 360)

            ScrollView {
                VStack(spacing: 0) {
                    Spacer().frame(height: 120)
                    card
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 40)
            }
        }
    }

    // MARK: - Card

    private var card: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 6) {
                Text("ollie got eaten")
                    .font(.ollieMono(10))
                    .foregroundStyle(Color.ollie_muted)
                    .tracking(2.5)
                Text("game over.")
                    .font(.ollieSerif(54))
                    .foregroundStyle(Color.ollie_ink)
            }
            .padding(.top, 24)
            .padding(.horizontal, 22)

            Divider()
                .padding(.horizontal, 22)
                .padding(.vertical, 18)
                .opacity(0.2)

            VStack(spacing: 10) {
                // Score row
                HStack(spacing: 10) {
                    statBox(label: "SCORE", value: "\(viewModel.score.current)", highlight: isNewBest)
                    statBox(label: "BEST",  value: "\(viewModel.score.best)",    showTrophy: true)
                }

                // Coins earned
                coinsRow

                // New best banner
                if isNewBest {
                    Text("★  new personal best  ★")
                        .font(.ollieMono(10, weight: .bold))
                        .foregroundStyle(Color.ollie_paper)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .frame(maxWidth: .infinity)
                        .background(Color.ollie_coral, in: RoundedRectangle(cornerRadius: 12))
                }

                // Daily progress
                dailyProgress

                // Friends leaderboard
                friendsBoard
            }
            .padding(.horizontal, 22)

            // Actions
            VStack(spacing: 10) {
                replayButton
                actionRow
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 22)
            .padding(.top, 14)
        }
        .background(Color.ollie_paper, in: RoundedRectangle(cornerRadius: 28))
        .shadow(color: Color.ollie_ink.opacity(0.12), radius: 30, x: 0, y: 15)
    }

    // MARK: - Components

    private func statBox(label: LocalizedStringKey, value: String, highlight: Bool = false, showTrophy: Bool = false) -> some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.ollieMono(9))
                    .foregroundStyle(Color.ollie_muted)
                    .tracking(1.8)
                Text(value)
                    .font(.ollieSerif(40))
                    .foregroundStyle(Color.ollie_ink)
                    .monospacedDigit()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.ollie_cream, in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(highlight ? Color.ollie_coral : Color.clear, lineWidth: 2)
            )

            if showTrophy {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.ollie_ink.opacity(0.7))
                    .padding(12)
            }
        }
    }

    private var coinsRow: some View {
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
    }

    private var dailyProgress: some View {
        let progress = min(1.0, CGFloat(viewModel.score.current) / 50.0)
        return VStack(spacing: 6) {
            HStack {
                Text("DAILY LASH · SHARED SEED")
                    .font(.ollieMono(10))
                    .foregroundStyle(Color.ollie_muted)
                    .tracking(1.5)
                Spacer()
                Text("\(min(viewModel.score.current, 50))/50")
                    .font(.ollieMono(10, weight: .bold))
                    .foregroundStyle(Color.ollie_ink)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.ollie_ink.opacity(0.08))
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.ollie_ink)
                        .frame(width: geo.size.width * progress)
                }
            }
            .frame(height: 6)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(Color.ollie_cream, in: RoundedRectangle(cornerRadius: 14))
    }

    private var friendsBoard: some View {
        VStack(spacing: 0) {
            Text("FRIENDS TODAY")
                .font(.ollieMono(10))
                .foregroundStyle(Color.ollie_muted)
                .tracking(1.8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 6)

            ForEach(leaderboard.indices, id: \.self) { i in
                let entry = leaderboard[i]
                HStack {
                    Text("\(i + 1)")
                        .font(.ollieMono(10))
                        .foregroundStyle(Color.ollie_muted)
                        .frame(width: 14, alignment: .leading)
                    Text(LocalizedStringKey(entry.name))
                        .font(.ollieBody(12, weight: entry.isYou ? .bold : .medium))
                        .foregroundStyle(entry.isYou ? Color.ollie_coral : Color.ollie_ink)
                    Spacer()
                    Text("\(entry.score)")
                        .font(.ollieBody(12, weight: entry.isYou ? .bold : .medium))
                        .foregroundStyle(entry.isYou ? Color.ollie_coral : Color.ollie_ink)
                        .monospacedDigit()
                }
                .padding(.vertical, 3)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(Color.ollie_cream, in: RoundedRectangle(cornerRadius: 14))
    }

    private var replayButton: some View {
        Button(action: onReplay) {
            HStack(spacing: 10) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 16, weight: .bold))
                Text("TAP TO FLY AGAIN")
                    .font(.ollieBody(18, weight: .bold))
                    .tracking(1)
            }
            .foregroundStyle(Color.ollie_paper)
            .frame(maxWidth: .infinity)
            .frame(height: 62)
            .background(Color.ollie_ink, in: Capsule())
            .shadow(color: Color.ollie_ink.opacity(0.22), radius: 10, x: 0, y: 5)
        }
    }

    private var actionRow: some View {
        HStack(spacing: 8) {
            actionButton("SHARE", action: nil)
            Button(action: onShop) {
                actionLabel("SHOP")
            }
            Button(action: onHome) {
                actionLabel("HOME")
            }
        }
    }

    private func actionButton(_ label: LocalizedStringKey, action: (() -> Void)?) -> some View {
        actionLabel(label)
    }

    private func actionLabel(_ label: LocalizedStringKey) -> some View {
        Text(label)
            .font(.ollieBody(12, weight: .bold))
            .foregroundStyle(Color.ollie_ink)
            .tracking(1.5)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(Color.ollie_subtle, in: Capsule())
    }
}

#Preview {
    GameOverView(viewModel: GameViewModel(), onReplay: {}, onHome: {}, onShop: {})
}
