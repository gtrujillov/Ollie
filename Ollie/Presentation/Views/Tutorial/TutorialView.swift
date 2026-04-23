import SwiftUI

struct TutorialView: View {
    let onDismiss: () -> Void

    @State private var page = 0

    private let pages: [TutorialPage] = [
        TutorialPage(
            icon:   "arrow.up.circle.fill",
            title:  "JUMP",
            body:   "Tap the LEFT side of the screen to make Ollie jump. Tap again in the air for a double jump!",
            accent: Color(red: 0.35, green: 0.70, blue: 0.35)
        ),
        TutorialPage(
            icon:   "bolt.fill",
            title:  "ATTACK",
            body:   "Tap the RIGHT side to swing your sword. Slash enemies to defeat them and earn coins.",
            accent: Color(red: 0.88, green: 0.70, blue: 0.08)
        ),
        TutorialPage(
            icon:   "heart.fill",
            title:  "3 HEARTS",
            body:   "Ollie has 3 hearts. Taking damage costs one heart — reach a checkpoint to respawn there.",
            accent: Color(red: 0.92, green: 0.22, blue: 0.22)
        ),
        TutorialPage(
            icon:   "flag.fill",
            title:  "REACH THE GOAL",
            body:   "Run to the GOAL flag at the end of each arena. Clear it to unlock the next challenge!",
            accent: Color(red: 0.45, green: 0.38, blue: 0.92)
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
    let accent: Color
}

struct TutorialView_Previews: PreviewProvider {
    static var previews: some View {
        TutorialView(onDismiss: {})
    }
}
