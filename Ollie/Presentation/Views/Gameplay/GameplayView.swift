import SwiftUI

struct GameplayView: View {
    @ObservedObject var viewModel: GameViewModel
    let onLevelComplete: () -> Void
    let onGameOver:      () -> Void

    private var progress: CGFloat {
        guard viewModel.finishX > 0 else { return 0 }
        return min(max(viewModel.player.worldX / viewModel.finishX, 0), 1)
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ArenaBackdropView(
                    arena: viewModel.currentArena,
                    progress: progress,
                    cameraX: viewModel.cameraX
                )

                groundLayer
                platformLayer
                pickupLayer
                enemyLayer
                fireballLayer
                finishFlagLayer
                playerLayer
                ringLayer

                if viewModel.flashActive { flashLayer }

                VStack(spacing: 0) {
                    hudLayer
                    Spacer()
                    if viewModel.phase == .idle || viewModel.tutorialEnabled {
                        tutorialPrompt
                            .padding(.horizontal, 22)
                            .padding(.bottom, 26)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }

                if let text = viewModel.bannerText {
                    statusBanner(text: text)
                        .padding(.top, 120)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                controlOverlay(geo: geo)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
        }
        .ignoresSafeArea()
        .onAppear { viewModel.startLoop() }
        .onDisappear { viewModel.stopLoop() }
        .onChange(of: viewModel.phase) { _, phase in
            if phase == .levelComplete { onLevelComplete() }
            if phase == .dead { onGameOver() }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.82), value: viewModel.bannerText)
    }

    private var groundLayer: some View {
        let w = viewModel.world
        let cam = viewModel.cameraX

        return ZStack {
            ForEach(viewModel.groundSegs.indices, id: \.self) { i in
                let seg = viewModel.groundSegs[i]
                let screenLeft = seg.startX - cam
                let segW = seg.endX - seg.startX
                let segH = w.height - w.groundY

                ZStack(alignment: .top) {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    viewModel.currentArena.accentColor.opacity(0.96),
                                    viewModel.currentArena.accentColor.opacity(0.38),
                                    Color.ollie_ink.opacity(0.50)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.55),
                                    viewModel.currentArena.glowColor.opacity(0.35),
                                    .clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 12)
                        .padding(.horizontal, 10)
                        .padding(.top, 6)
                }
                .frame(width: segW, height: segH + 46)
                .overlay(alignment: .topLeading) {
                    HStack(spacing: 18) {
                        Circle().frame(width: 5, height: 5)
                        Circle().frame(width: 3, height: 3)
                        Circle().frame(width: 4, height: 4)
                    }
                    .foregroundStyle(Color.white.opacity(0.24))
                    .padding(.top, 14)
                    .padding(.leading, 18)
                }
                .position(x: screenLeft + segW / 2, y: w.groundY + segH / 2 + 10)
                .shadow(color: viewModel.currentArena.accentColor.opacity(0.20), radius: 18, x: 0, y: 10)
            }

            Rectangle()
                .fill(Color.white.opacity(0.12))
                .frame(width: viewModel.world.width, height: 1.5)
                .position(x: viewModel.world.width / 2, y: w.ceilingY)
        }
        .allowsHitTesting(false)
    }

    private var platformLayer: some View {
        let w = viewModel.world
        let cam = viewModel.cameraX

        return ZStack {
            ForEach(viewModel.platforms) { plat in
                let screenX = plat.currentWorldX - cam
                let screenY = w.screenY(norm: plat.normY)
                PlatformView(
                    width: plat.width,
                    thickness: plat.thickness,
                    color: viewModel.currentArena.accentColor,
                    isMoving: plat.isMoving
                )
                .position(x: screenX + plat.width / 2, y: screenY + plat.thickness / 2)
            }
        }
        .allowsHitTesting(false)
    }

    private var pickupLayer: some View {
        let w = viewModel.world
        let cam = viewModel.cameraX

        return ZStack {
            ForEach(viewModel.pickups) { pickup in
                let screenX = pickup.worldX - cam
                let screenY = w.screenY(norm: pickup.normY)
                Group {
                    if pickup.kind == .coin {
                        CoinView(size: 24)
                    } else {
                        HeartPickupView()
                    }
                }
                .position(x: screenX, y: screenY)
            }
        }
        .allowsHitTesting(false)
    }

    private var enemyLayer: some View {
        let w = viewModel.world
        let cam = viewModel.cameraX

        return ZStack {
            ForEach(viewModel.enemies) { enemy in
                let screenX = enemy.worldX - cam
                let screenY = w.screenY(norm: enemy.normY)

                Group {
                    switch enemy.type {
                    case .walker:
                        WalkerEnemyView(
                            size: w.charSize * 0.88,
                            facingLeft: enemy.velocityX < 0,
                            isDead: enemy.isDead,
                            runPhase: CGFloat(CACurrentMediaTime() * 8)
                        )
                    case .cannon:
                        CannonEnemyView(
                            size: w.charSize,
                            isFiring: enemy.fireTimer < 0.12
                        )
                    }
                }
                .position(x: screenX, y: screenY - w.charSize * 0.4)
            }
        }
        .allowsHitTesting(false)
    }

    private var fireballLayer: some View {
        let cam = viewModel.cameraX
        return ZStack {
            ForEach(viewModel.fireballs) { fb in
                FireballView()
                    .position(x: fb.worldX - cam, y: fb.screenY)
            }
        }
        .allowsHitTesting(false)
    }

    private var finishFlagLayer: some View {
        let w = viewModel.world
        let screenX = viewModel.finishX - viewModel.cameraX
        guard screenX > -140 && screenX < w.width + 140 else { return AnyView(EmptyView()) }

        return AnyView(
            ZStack {
                Capsule(style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.95), Color.ollie_ink.opacity(0.65)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 6, height: w.groundY - w.ceilingY + 20)
                    .position(x: screenX, y: (w.groundY + w.ceilingY) / 2)

                FlagShape()
                    .fill(
                        LinearGradient(
                            colors: [viewModel.currentArena.glowColor, viewModel.currentArena.accentColor],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 64, height: 40)
                    .overlay {
                        Text("GOAL")
                            .font(.ollieMono(10, weight: .bold))
                            .foregroundStyle(Color.ollie_paper)
                            .tracking(1.5)
                    }
                    .shadow(color: viewModel.currentArena.accentColor.opacity(0.35), radius: 14, x: 0, y: 8)
                    .position(x: screenX + 32, y: w.ceilingY + 32)
            }
            .allowsHitTesting(false)
        )
    }

    private var playerLayer: some View {
        let w = viewModel.world
        return ZStack {
            if viewModel.shieldCharges > 0 {
                Circle()
                    .strokeBorder(
                        AngularGradient(
                            colors: [.clear, .ollie_sky, viewModel.currentArena.glowColor, .clear],
                            center: .center
                        ),
                        lineWidth: 4
                    )
                    .frame(width: w.charSize * 1.5, height: w.charSize * 1.5)
                    .blur(radius: 0.5)
                    .opacity(0.85)
            }

            OllieWarriorView(
                size: w.charSize,
                color: viewModel.selectedOllieColor,
                runPhase: viewModel.player.runPhase,
                isAttacking: viewModel.player.isAttacking,
                isDead: viewModel.phase == .dead,
                isBlinking: viewModel.player.isInvincible && !viewModel.player.flashVisible
            )
        }
        .position(x: w.charScreenX, y: viewModel.player.screenY)
        .allowsHitTesting(false)
    }

    private var ringLayer: some View {
        ZStack {
            ForEach(viewModel.rings) { ring in
                SwordRingView(x: ring.x, y: ring.y, accent: viewModel.currentArena.glowColor)
            }
        }
        .allowsHitTesting(false)
    }

    private var flashLayer: some View {
        LinearGradient(
            colors: [viewModel.currentArena.glowColor.opacity(0.15), Color.ollie_coral.opacity(0.28)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private var hudLayer: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                heartsRow
                Spacer()
                progressPill
                Spacer()
                resourceCluster
            }
            progressBar
        }
        .padding(.horizontal, 18)
        .padding(.top, 52)
    }

    private var heartsRow: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { i in
                Image(systemName: i < viewModel.hearts ? "heart.fill" : "heart")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(i < viewModel.hearts ? Color(red: 0.95, green: 0.30, blue: 0.34) : Color.white.opacity(0.45))
            }

            if viewModel.shieldCharges > 0 {
                Label("\(viewModel.shieldCharges)", systemImage: "shield.lefthalf.filled")
                    .font(.ollieMono(10, weight: .bold))
                    .foregroundStyle(Color.ollie_sky)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(Color.white.opacity(0.10), in: Capsule())
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .premiumPanel(tint: viewModel.currentArena.skyTop.opacity(0.55), cornerRadius: 20, shadowOpacity: 0.10)
    }

    private var progressPill: some View {
        HStack(spacing: 6) {
            Image(systemName: viewModel.currentArena.emojiName)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(viewModel.currentArena.glowColor)
            Text(viewModel.currentArena.name.uppercased())
                .font(.ollieMono(9, weight: .bold))
                .foregroundStyle(Color.white)
                .tracking(1.4)
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .premiumPanel(tint: viewModel.currentArena.accentColor.opacity(0.38), cornerRadius: 20, shadowOpacity: 0.10)
    }

    private var resourceCluster: some View {
        HStack(spacing: 8) {
            CoinView(size: 18)
            Text("\(viewModel.score.coinsEarned)")
                .font(.ollieBody(13, weight: .bold))
                .foregroundStyle(Color.white)
                .monospacedDigit()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .premiumPanel(tint: viewModel.currentArena.skyBottom.opacity(0.30), cornerRadius: 20, shadowOpacity: 0.10)
    }

    private var progressBar: some View {
        VStack(spacing: 6) {
            HStack {
                Text("RUN PROGRESS")
                    .font(.ollieMono(8, weight: .bold))
                    .foregroundStyle(Color.white.opacity(0.72))
                    .tracking(1.7)
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.ollieMono(8, weight: .bold))
                    .foregroundStyle(Color.white.opacity(0.82))
            }

            GeometryReader { geo in
                let width = max(10, geo.size.width * progress)
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.12))
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [viewModel.currentArena.glowColor, viewModel.currentArena.accentColor],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: width)
                        .overlay(alignment: .trailing) {
                            Circle()
                                .fill(Color.white.opacity(0.9))
                                .frame(width: 10, height: 10)
                                .blur(radius: 0.3)
                        }
                }
            }
            .frame(height: 10)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .premiumPanel(tint: Color.ollie_night.opacity(0.55), cornerRadius: 20, shadowOpacity: 0.10)
    }

    private var tutorialPrompt: some View {
        HStack(spacing: 14) {
            controlHint(icon: "arrow.up.circle.fill", title: "LEFT", body: "Jump / double jump")
            controlHint(icon: "sparkles", title: "RIGHT", body: "Sword slash")
        }
        .padding(14)
        .premiumPanel(tint: viewModel.currentArena.skyBottom.opacity(0.28), cornerRadius: 26, shadowOpacity: 0.12)
    }

    private func controlHint(icon: String, title: String, body: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(viewModel.currentArena.glowColor)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.ollieMono(9, weight: .bold))
                    .foregroundStyle(Color.white.opacity(0.62))
                    .tracking(1.4)
                Text(body)
                    .font(.ollieBody(12, weight: .semibold))
                    .foregroundStyle(Color.white)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func statusBanner(text: String) -> some View {
        Text(text)
            .font(.ollieMono(10, weight: .bold))
            .foregroundStyle(Color.white)
            .tracking(1.4)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .premiumPanel(tint: viewModel.bannerAccent.opacity(0.44), cornerRadius: 999, shadowOpacity: 0.14)
    }

    private func controlOverlay(geo: GeometryProxy) -> some View {
        Color.clear
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if viewModel.phase == .idle {
                            viewModel.startPlay()
                        }

                        if value.startLocation.x < geo.size.width * 0.50 {
                            viewModel.onJump()
                        } else {
                            viewModel.onAttack()
                        }
                    }
            )
    }
}

private struct ArenaBackdropView: View {
    let arena: ArenaDefinition
    let progress: CGFloat
    let cameraX: CGFloat

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 24.0)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate

            ZStack {
                LinearGradient(
                    colors: [arena.skyTop, arena.skyBottom, arena.bgColor],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                RadialGradient(
                    colors: [arena.glowColor.opacity(0.55), .clear],
                    center: .topTrailing,
                    startRadius: 20,
                    endRadius: 240
                )
                .blendMode(.screen)
                .ignoresSafeArea()

                GeometryReader { geo in
                    let w = geo.size.width
                    let h = geo.size.height

                    ForEach(0..<5, id: \.self) { idx in
                        Circle()
                            .fill(arena.particleColor.opacity(idx.isMultiple(of: 2) ? 0.22 : 0.12))
                            .frame(width: CGFloat(80 + idx * 40), height: CGFloat(80 + idx * 40))
                            .blur(radius: CGFloat(20 + idx * 4))
                            .position(
                                x: CGFloat(idx) * w * 0.22 + CGFloat(sin(time * 0.25 + Double(idx)) * 28) - cameraX * CGFloat(0.01 + Double(idx) * 0.003),
                                y: h * (0.15 + CGFloat(idx) * 0.09)
                            )
                    }

                    HorizonLayer(curveDepth: 0.26, crest: 0.23)
                        .fill(arena.accentColor.opacity(0.20))
                        .frame(height: h * 0.42)
                        .offset(y: h * 0.42)
                        .offset(x: -cameraX * 0.05)

                    HorizonLayer(curveDepth: 0.35, crest: 0.31)
                        .fill(Color.ollie_night.opacity(0.18))
                        .frame(height: h * 0.35)
                        .offset(y: h * 0.50)
                        .offset(x: -cameraX * 0.10)

                    HorizonLayer(curveDepth: 0.28, crest: 0.26)
                        .fill(arena.bgColor.opacity(0.45))
                        .frame(height: h * 0.20)
                        .offset(y: h * 0.66)
                        .offset(x: -cameraX * 0.16)

                    HStack(spacing: 16) {
                        ForEach(0..<20, id: \.self) { idx in
                            RoundedRectangle(cornerRadius: 99, style: .continuous)
                                .fill(arena.particleColor.opacity(0.16))
                                .frame(width: CGFloat((idx % 3) + 1) * 4, height: CGFloat((idx % 4) + 1) * 4)
                        }
                    }
                    .blur(radius: 0.4)
                    .offset(x: sin(time * 0.4) * 18 - cameraX * 0.03, y: h * 0.12)

                    if progress > 0.72 {
                        SparkCurtain(accent: arena.glowColor)
                            .frame(height: h * 0.36)
                            .offset(y: h * 0.18)
                            .opacity(Double((progress - 0.72) / 0.28))
                    }
                }
            }
        }
        .allowsHitTesting(false)
    }
}

private struct HorizonLayer: Shape {
    let curveDepth: CGFloat
    let crest: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height * crest))
        path.addCurve(
            to: CGPoint(x: rect.width, y: rect.height * (crest + 0.04)),
            control1: CGPoint(x: rect.width * 0.25, y: rect.height * (crest - curveDepth)),
            control2: CGPoint(x: rect.width * 0.70, y: rect.height * (crest + curveDepth))
        )
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.closeSubpath()
        return path
    }
}

private struct SparkCurtain: View {
    let accent: Color

    var body: some View {
        HStack(spacing: 22) {
            ForEach(0..<12, id: \.self) { idx in
                Capsule(style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [accent.opacity(0.0), accent.opacity(0.50), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: CGFloat(idx.isMultiple(of: 3) ? 3 : 2), height: CGFloat(80 + (idx % 5) * 26))
            }
        }
        .blur(radius: 0.6)
    }
}

private struct FlagShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

private struct SwordRingView: View {
    let x: CGFloat
    let y: CGFloat
    let accent: Color
    @State private var scale: CGFloat = 0.5
    @State private var opacity: CGFloat = 0.9

    var body: some View {
        Circle()
            .strokeBorder(accent, lineWidth: 2.5)
            .background(
                Circle()
                    .fill(accent.opacity(0.16))
            )
            .frame(width: 42, height: 42)
            .position(x: x, y: y)
            .scaleEffect(scale)
            .opacity(opacity)
            .blur(radius: 0.25)
            .onAppear {
                withAnimation(.easeOut(duration: 0.40)) {
                    scale = 2.8
                    opacity = 0
                }
            }
    }
}

private struct HeartPickupView: View {
    @State private var pulse = false

    var body: some View {
        Image(systemName: "heart.fill")
            .font(.system(size: 18, weight: .bold))
            .foregroundStyle(Color(red: 0.96, green: 0.34, blue: 0.38))
            .shadow(color: .pink.opacity(0.55), radius: 10)
            .scaleEffect(pulse ? 1.16 : 0.96)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.72).repeatForever(autoreverses: true)) {
                    pulse = true
                }
            }
    }
}
