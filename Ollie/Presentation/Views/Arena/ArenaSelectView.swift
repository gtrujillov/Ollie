import SwiftUI

struct ArenaSelectView: View {
    @ObservedObject var viewModel: GameViewModel
    let onPlay:  (Int) -> Void
    let onBack:  () -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [viewModel.currentArena.skyTop, viewModel.currentArena.skyBottom, viewModel.currentArena.bgColor],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                ScrollView {
                    VStack(spacing: 14) {
                        ForEach(ArenaRegistry.all, id: \.id) { arena in
                            arenaCard(arena)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.white)
                    .frame(width: 40, height: 40)
                    .premiumPanel(tint: viewModel.currentArena.accentColor.opacity(0.25), cornerRadius: 999, shadowOpacity: 0.10)
            }
            Spacer()
            Text("ARENAS")
                .font(.ollieMono(14, weight: .bold))
                .foregroundStyle(Color.white)
                .tracking(3)
            Spacer()
            Color.clear.frame(width: 40)
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
        .padding(.bottom, 10)
    }

    // MARK: - Arena card

    private func arenaCard(_ arena: ArenaDefinition) -> some View {
        let unlocked = arena.id <= viewModel.highestArena
        let isCurrent = arena.id == viewModel.highestArena

        return Button {
            if unlocked { onPlay(arena.id) }
        } label: {
            HStack(spacing: 14) {
                // Icon badge
                ZStack {
                    Circle()
                        .fill(unlocked ? arena.accentColor : Color.ollie_muted.opacity(0.20))
                        .frame(width: 52, height: 52)
                    if unlocked {
                        Image(systemName: arena.emojiName)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(Color.white)
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(Color.ollie_muted)
                    }
                }

                // Text
                VStack(alignment: .leading, spacing: 3) {
                    Text(arena.name.uppercased())
                        .font(.ollieMono(11, weight: .bold))
                        .foregroundStyle(unlocked ? Color.white : Color.white.opacity(0.45))
                        .tracking(1)
                    Text(unlocked ? arena.description : "Beat arena \(arena.id - 1) to unlock")
                        .font(.ollieBody(11, weight: .regular))
                        .foregroundStyle(Color.white.opacity(0.65))
                        .lineLimit(1)
                }

                Spacer()

                if isCurrent {
                    Text("PLAY")
                        .font(.ollieMono(9, weight: .bold))
                        .foregroundStyle(Color.ollie_paper)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(arena.accentColor, in: Capsule())
                } else if unlocked {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(arena.accentColor)
                        .font(.system(size: 20))
                } else {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(Color.ollie_muted)
                        .font(.system(size: 16))
                }
            }
            .padding(14)
            .premiumPanel(tint: arena.accentColor.opacity(isCurrent ? 0.32 : 0.18), cornerRadius: 18, shadowOpacity: 0.10)
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(
                        isCurrent ? arena.glowColor : Color.white.opacity(0.08),
                        lineWidth: isCurrent ? 1.6 : 1
                    )
            )
        }
        .disabled(!unlocked)
    }
}

struct ArenaSelectView_Previews: PreviewProvider {
    static var previews: some View {
        ArenaSelectView(viewModel: GameViewModel(), onPlay: { _ in }, onBack: {})
    }
}
