import SwiftUI

struct LevelCompleteView: View {
    @ObservedObject var viewModel: GameViewModel
    let onNext:    () -> Void   // play next arena
    let onArenas:  () -> Void   // go back to arena select
    let onHome:    () -> Void

    private var arena: ArenaDefinition { viewModel.currentArena }
    private var unlockedNext: Bool { viewModel.arenaId < 7 }

    var body: some View {
        ZStack {
            arena.bgColor.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()
                card
                Spacer()
            }
            .padding(.horizontal, 22)
        }
    }

    private var card: some View {
        VStack(spacing: 0) {
            // Trophy
            ZStack {
                Circle()
                    .fill(arena.accentColor.opacity(0.15))
                    .frame(width: 100, height: 100)
                Image(systemName: "trophy.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(arena.accentColor)
            }
            .padding(.top, 28)

            Text("ARENA CLEAR!")
                .font(.ollieMono(13, weight: .bold))
                .foregroundStyle(arena.accentColor)
                .tracking(3)
                .padding(.top, 12)

            Text(arena.name)
                .font(.ollieSerif(38))
                .foregroundStyle(Color.ollie_ink)
                .padding(.top, 4)

            Divider()
                .opacity(0.18)
                .padding(.vertical, 18)
                .padding(.horizontal, 22)

            // Stats
            HStack(spacing: 12) {
                statBox(label: "COINS", value: "+\(viewModel.score.coinsEarned)")
                statBox(label: "HEARTS", value: "\(viewModel.hearts)/3")
            }
            .padding(.horizontal, 22)

            // Next unlock
            if unlockedNext, let next = ArenaRegistry.definition(id: viewModel.arenaId + 1) {
                HStack(spacing: 8) {
                    Image(systemName: "lock.open.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(next.accentColor)
                    Text("\(next.name) unlocked!")
                        .font(.ollieMono(10, weight: .bold))
                        .foregroundStyle(Color.ollie_ink)
                        .tracking(1)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background(next.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
                .padding(.top, 12)
                .padding(.horizontal, 22)
            } else if viewModel.arenaId == 7 {
                Text("🏆 All arenas conquered!")
                    .font(.ollieMono(10, weight: .bold))
                    .foregroundStyle(Color.ollie_ink)
                    .padding(.top, 12)
            }

            // Buttons
            VStack(spacing: 10) {
                if unlockedNext {
                    Button(action: onNext) {
                        HStack {
                            Image(systemName: "arrow.right.circle.fill")
                            Text("NEXT ARENA")
                                .font(.ollieBody(18, weight: .bold))
                                .tracking(1)
                        }
                        .foregroundStyle(Color.ollie_paper)
                        .frame(maxWidth: .infinity)
                        .frame(height: 62)
                        .background(arena.accentColor, in: Capsule())
                    }
                }

                HStack(spacing: 8) {
                    Button(action: onArenas) {
                        Text("ARENAS")
                            .font(.ollieBody(12, weight: .semibold))
                            .foregroundStyle(Color.ollie_ink)
                            .tracking(1.5)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color.ollie_subtle, in: Capsule())
                    }
                    Button(action: onHome) {
                        Text("HOME")
                            .font(.ollieBody(12, weight: .semibold))
                            .foregroundStyle(Color.ollie_ink)
                            .tracking(1.5)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color.ollie_subtle, in: Capsule())
                    }
                }
            }
            .padding(.horizontal, 22)
            .padding(.top, 18)
            .padding(.bottom, 22)
        }
        .background(Color.ollie_paper, in: RoundedRectangle(cornerRadius: 28))
        .shadow(color: Color.ollie_ink.opacity(0.12), radius: 30, x: 0, y: 15)
    }

    private func statBox(label: LocalizedStringKey, value: String) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.ollieMono(9))
                .foregroundStyle(Color.ollie_muted)
                .tracking(1.8)
            Text(value)
                .font(.ollieSerif(34))
                .foregroundStyle(Color.ollie_ink)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.ollie_cream, in: RoundedRectangle(cornerRadius: 14))
    }
}
