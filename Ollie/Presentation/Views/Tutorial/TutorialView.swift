import SwiftUI

struct TutorialView: View {
    let onDismiss: () -> Void

    @State private var page = 0

    private let pages: [TutorialPage] = [
        TutorialPage(
            icon:     "hand.tap.fill",
            title:    "TAP & HOLD",
            body:     "Tap anywhere on the left to flap. Hold to BLINK — time slows and Ollie glows.",
            bodyES:   "Toca la izquierda para aletear. Mantén para PARPADEAR — el tiempo se ralentiza.",
            accent:   Color.ollie_coral
        ),
        TutorialPage(
            icon:     "bolt.fill",
            title:    "EYE BEAM",
            body:     "Wait for the ⚡ charge to fill, then tap the right side to unleash a beam that blasts obstacles.",
            bodyES:   "Espera a que ⚡ se recargue y toca la derecha para disparar el rayo ocular.",
            accent:   Color(red: 0.95, green: 0.80, blue: 0.10)
        ),
        TutorialPage(
            icon:     "target",
            title:    "MISSIONS",
            body:     "Each run gives you 3 missions. Complete them to earn bonus coins and unlock the shop.",
            bodyES:   "Cada partida tiene 3 misiones. Complétalas para ganar monedas extra.",
            accent:   Color(red: 0.2, green: 0.75, blue: 0.4)
        ),
    ]

    var body: some View {
        ZStack {
            Color.ollie_cream.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                TabView(selection: $page) {
                    ForEach(pages.indices, id: \.self) { i in
                        pageCard(pages[i])
                            .tag(i)
                            .padding(.horizontal, 30)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 360)

                // Dot indicators
                HStack(spacing: 8) {
                    ForEach(pages.indices, id: \.self) { i in
                        Circle()
                            .fill(i == page ? Color.ollie_ink : Color.ollie_ink.opacity(0.2))
                            .frame(width: 7, height: 7)
                            .animation(.spring(duration: 0.3), value: page)
                    }
                }
                .padding(.top, 20)

                Spacer()

                Button(action: {
                    if page < pages.count - 1 {
                        withAnimation(.spring(duration: 0.35)) { page += 1 }
                    } else {
                        onDismiss()
                    }
                }) {
                    Text(page < pages.count - 1 ? LocalizedStringKey("NEXT") : LocalizedStringKey("GOT IT"))
                        .font(.ollieBody(18, weight: .bold))
                        .foregroundStyle(Color.ollie_paper)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color.ollie_ink, in: Capsule())
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 60)
            }
        }
    }

    private func pageCard(_ p: TutorialPage) -> some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(p.accent.opacity(0.12))
                    .frame(width: 90, height: 90)
                Image(systemName: p.icon)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(p.accent)
            }

            Text(LocalizedStringKey(p.title))
                .font(.ollieSerif(34))
                .foregroundStyle(Color.ollie_ink)

            Text(LocalizedStringKey(p.body))
                .font(.ollieBody(15))
                .foregroundStyle(Color.ollie_muted)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .background(Color.ollie_paper, in: RoundedRectangle(cornerRadius: 28))
        .shadow(color: Color.ollie_ink.opacity(0.08), radius: 20, x: 0, y: 8)
    }
}

private struct TutorialPage {
    let icon:   String
    let title:  String
    let body:   String
    let bodyES: String
    let accent: Color
}

#Preview {
    TutorialView(onDismiss: {})
}
