import SwiftUI

struct StartView: View {
    @ObservedObject var viewModel: GameViewModel
    let onPlay:        () -> Void
    let onArenaSelect: () -> Void
    let onShop:        () -> Void

    @State private var idlePhase:  CGFloat = 0
    @State private var pulseScale: CGFloat = 1.0

    private var currentArena: ArenaDefinition {
        ArenaRegistry.arena(id: viewModel.highestArena)
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [currentArena.skyTop, currentArena.skyBottom, currentArena.bgColor],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            Circle()
                .fill(currentArena.glowColor.opacity(0.25))
                .frame(width: 280, height: 280)
                .blur(radius: 18)
                .offset(x: 120, y: -220)

            VStack(spacing: 0) {
                topBar
                Spacer()
                heroArea
                Spacer()
                bottomArea
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                idlePhase = 1
            }
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                pulseScale = 1.04
            }
        }
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack {
            // Current arena badge
            HStack(spacing: 6) {
                Image(systemName: currentArena.emojiName)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(currentArena.glowColor)
                Text(currentArena.name.uppercased())
                    .font(.ollieMono(10, weight: .bold))
                    .foregroundStyle(Color.white)
                    .tracking(1)
            }
            .padding(.vertical, 6)
            .padding(.leading, 8)
            .padding(.trailing, 12)
            .premiumPanel(tint: currentArena.accentColor.opacity(0.28), cornerRadius: 999, shadowOpacity: 0.10)

            Spacer()

            HStack(spacing: 6) {
                CoinView(size: 20)
                Text("\(viewModel.score.coins)")
                    .font(.ollieBody(14, weight: .bold))
                    .foregroundStyle(Color.white)
                    .monospacedDigit()
            }
            .padding(.vertical, 6)
            .padding(.leading, 8)
            .padding(.trailing, 12)
            .premiumPanel(tint: currentArena.skyBottom.opacity(0.24), cornerRadius: 999, shadowOpacity: 0.10)
        }
        .padding(.top, 60)
    }

    // MARK: - Hero

    private var heroArea: some View {
        VStack(spacing: 24) {
            VStack(spacing: 4) {
                Text("Ollie")
                    .font(.ollieSerif(90))
                    .foregroundStyle(Color.white)
                    .offset(y: idlePhase == 1 ? -10 : 0)
                    .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: idlePhase)

                Text("WARRIOR")
                    .font(.ollieMono(12))
                    .foregroundStyle(currentArena.glowColor)
                    .tracking(5)
            }

            OllieWarriorView(
                size:      130,
                runPhase:  idlePhase * 3
            )
            .offset(y: idlePhase == 1 ? -8 : 0)
            .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: idlePhase)

            arenaInfoCard
        }
    }

    private var arenaInfoCard: some View {
        Button(action: onArenaSelect) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(currentArena.accentColor.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: currentArena.emojiName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(currentArena.accentColor)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(currentArena.name.uppercased())
                        .font(.ollieMono(11, weight: .bold))
                        .foregroundStyle(Color.white)
                        .tracking(1)
                    Text(currentArena.description)
                        .font(.ollieBody(11))
                        .foregroundStyle(Color.white.opacity(0.72))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.white.opacity(0.62))
            }
            .padding(14)
            .premiumPanel(tint: currentArena.accentColor.opacity(0.24), cornerRadius: 18, shadowOpacity: 0.10)
        }
    }

    // MARK: - Bottom

    private var bottomArea: some View {
        VStack(spacing: 12) {
            playButton
            secondaryButtons
        }
        .padding(.bottom, 60)
    }

    private var playButton: some View {
        Button(action: onPlay) {
            HStack {
                Spacer()
                Text("PLAY")
                    .font(.ollieBody(22, weight: .bold))
                    .foregroundStyle(Color.ollie_paper)
                    .tracking(2)
                Spacer()
                ZStack {
                    Circle()
                        .fill(currentArena.accentColor)
                        .frame(width: 32, height: 32)
                    Image(systemName: "play.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.ollie_paper)
                }
                .padding(.trailing, 4)
            }
            .frame(height: 68)
            .scaleEffect(pulseScale)
        }
        .buttonStyle(PremiumCapsuleButtonStyle(fill: currentArena.accentColor, foreground: .white))
    }

    private var secondaryButtons: some View {
        HStack(spacing: 10) {
            Button(action: onArenaSelect) {
                Label("ARENAS", systemImage: "map.fill")
                    .font(.ollieBody(12, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .tracking(1)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .premiumPanel(tint: currentArena.skyBottom.opacity(0.20), cornerRadius: 16, shadowOpacity: 0.08)
            }
            Button(action: onShop) {
                Text("SHOP")
                    .font(.ollieBody(12, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .tracking(1.5)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .premiumPanel(tint: currentArena.skyBottom.opacity(0.20), cornerRadius: 16, shadowOpacity: 0.08)
            }
        }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView(viewModel: GameViewModel(), onPlay: {}, onArenaSelect: {}, onShop: {})
    }
}
