import SwiftUI

struct StartView: View {
    @ObservedObject var viewModel: GameViewModel
    let onPlay:  () -> Void
    let onShop:  () -> Void

    @State private var idlePhase: CGFloat = 0
    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            Color.ollie_cream.ignoresSafeArea()

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
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                pulseScale = 1.04
            }
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            if viewModel.streak > 1 {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color(red: 0.9, green: 0.4, blue: 0.1))
                    Text("\(viewModel.streak)")
                        .font(.ollieBody(13, weight: .bold))
                        .foregroundStyle(Color.ollie_ink)
                        .monospacedDigit()
                }
                .padding(.vertical, 6)
                .padding(.leading, 8)
                .padding(.trailing, 12)
                .background(Color.ollie_subtle, in: Capsule())
                .transition(.scale.combined(with: .opacity))
            }
            Spacer()
            HStack(spacing: 8) {
                CoinView(size: 22)
                Text("\(viewModel.score.coins)")
                    .font(.ollieBody(15, weight: .bold))
                    .foregroundStyle(Color.ollie_ink)
                    .monospacedDigit()
            }
            .padding(.vertical, 6)
            .padding(.leading, 8)
            .padding(.trailing, 12)
            .background(Color.ollie_subtle, in: Capsule())
        }
        .padding(.top, 60)
        .animation(.spring(duration: 0.4), value: viewModel.streak)
    }

    // MARK: - Hero

    private var heroArea: some View {
        VStack(spacing: 28) {
            VStack(spacing: 4) {
                Text("Ollie")
                    .font(.ollieSerif(96))
                    .foregroundStyle(Color.ollie_ink)
                    .offset(y: idlePhase == 1 ? -10 : 0)
                    .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: idlePhase)

                Text("TAP · HOLD · BLINK")
                    .font(.ollieMono(11))
                    .foregroundStyle(Color.ollie_muted)
                    .tracking(3)
            }

            OllieCharacterView(
                size:      140,
                wingPhase: idlePhase * 2 * .pi
            )
            .offset(y: idlePhase == 1 ? -10 : 0)
            .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: idlePhase)

            statRow
        }
    }

    private var statRow: some View {
        HStack(spacing: 10) {
            statCard(label: "BEST", value: "\(viewModel.score.best)")
            statCard(label: "COINS", value: "\(viewModel.score.coins)")
        }
    }

    private func statCard(label: LocalizedStringKey, value: String) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.ollieMono(9))
                .foregroundStyle(Color.ollie_muted)
                .tracking(2)
            Text(value)
                .font(.ollieSerif(28))
                .foregroundStyle(Color.ollie_ink)
                .monospacedDigit()
        }
        .frame(minWidth: 80)
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(Color.ollie_subtle, in: RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Bottom

    private var bottomArea: some View {
        VStack(spacing: 12) {
            playButton
            secondaryIcons
        }
        .padding(.bottom, 60)
    }

    private var playButton: some View {
        Button(action: onPlay) {
            HStack {
                Spacer()
                Text("FLAP TO START")
                    .font(.ollieBody(20, weight: .bold))
                    .foregroundStyle(Color.ollie_paper)
                    .tracking(1)
                Spacer()

                ZStack {
                    Circle()
                        .fill(Color.ollie_coral)
                        .frame(width: 30, height: 30)
                    Image(systemName: "play.fill")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.ollie_paper)
                }
                .padding(.trailing, 4)
            }
            .frame(height: 68)
            .background(Color.ollie_ink, in: Capsule())
            .shadow(color: Color.ollie_ink.opacity(0.22), radius: 10, x: 0, y: 6)
            .scaleEffect(pulseScale)
        }
    }

    private var secondaryIcons: some View {
        HStack(spacing: 10) {
            Button(action: onShop) {
                iconLabel("SHOP")
            }
            iconButton("RANKS")
            iconButton("DAILY", badge: "2")
        }
    }

    private func iconButton(_ label: LocalizedStringKey, badge: String? = nil) -> some View {
        ZStack(alignment: .topTrailing) {
            iconLabel(label)
            if let badge {
                Text(badge)
                    .font(.ollieBody(11, weight: .bold))
                    .foregroundStyle(Color.ollie_paper)
                    .frame(minWidth: 20, minHeight: 20)
                    .padding(.horizontal, 4)
                    .background(Color.ollie_coral, in: Capsule())
                    .offset(x: 4, y: -4)
            }
        }
    }

    private func iconLabel(_ label: LocalizedStringKey) -> some View {
        Text(label)
            .font(.ollieBody(12, weight: .semibold))
            .foregroundStyle(Color.ollie_ink)
            .tracking(1.5)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(Color.ollie_subtle, in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    StartView(viewModel: GameViewModel(), onPlay: {}, onShop: {})
}
