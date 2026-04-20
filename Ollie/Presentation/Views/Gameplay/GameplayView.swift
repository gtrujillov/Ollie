import SwiftUI

struct GameplayView: View {
    @ObservedObject var viewModel: GameViewModel
    let onGameOver: () -> Void

    @State private var isTouching = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                background
                groundAndCeiling(geo: geo)
                obstacleLayer
                pickupLayer
                shieldRing
                beamReadyRing
                ollieLayer
                projectileLayer
                dangerGlow
                ringLayer
                popupLayer
                blinkTint
                beamZoneGlow(geo: geo)
                uiLayer
                tapHint
                flashLayer
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .contentShape(Rectangle())
            .gesture(splitTouchGesture(geo: geo))
        }
        .ignoresSafeArea()
        .onAppear  { viewModel.startLoop() }
        .onDisappear { viewModel.stopLoop() }
        .onChange(of: viewModel.phase) { _, newPhase in
            if newPhase == .dead { onGameOver() }
        }
    }

    // MARK: - Background

    private var background: some View {
        viewModel.selectedBackgroundColor.ignoresSafeArea()
    }

    // MARK: - Ground & Ceiling

    private func groundAndCeiling(geo: GeometryProxy) -> some View {
        let w = viewModel.world
        return ZStack {
            Rectangle()
                .fill(Color.ollie_ink.opacity(0.12))
                .frame(width: geo.size.width, height: 1.5)
                .position(x: geo.size.width / 2, y: w.ceilingHeight)

            Rectangle()
                .fill(Color.ollie_ink.opacity(0.045))
                .frame(width: geo.size.width, height: w.groundHeight)
                .position(x: geo.size.width / 2, y: geo.size.height - w.groundHeight / 2)

            Rectangle()
                .fill(Color.ollie_ink.opacity(0.14))
                .frame(width: geo.size.width, height: 1.5)
                .position(x: geo.size.width / 2, y: geo.size.height - w.groundHeight)
        }
    }

    // MARK: - Obstacles

    private var obstacleLayer: some View {
        let w      = viewModel.world
        let totalH = w.height - w.groundHeight
        return ZStack {
            ForEach(viewModel.obstacles) { obs in
                LashObstacleView(
                    gapY:   obs.gapY,
                    gapH:   obs.gapH,
                    totalH: totalH,
                    width:  w.obstacleWidth,
                    color:  obs.oscillating
                        ? viewModel.selectedLashColor.opacity(0.75)
                        : viewModel.selectedLashColor
                )
                .position(x: obs.x + w.obstacleWidth / 2, y: totalH / 2)
            }
        }
    }

    // MARK: - Pickups

    private var pickupLayer: some View {
        ZStack {
            ForEach(viewModel.pickups) { pickup in
                Group {
                    if pickup.kind == .shield {
                        ShieldPickupView()
                    } else {
                        CoinView(size: 22)
                    }
                }
                .position(x: pickup.x + 11, y: pickup.y)
            }
        }
    }

    // MARK: - Shield ring around Ollie

    @ViewBuilder
    private var shieldRing: some View {
        if viewModel.shielded {
            let w = viewModel.world
            ShieldRingView(size: w.charSize * 1.55)
                .position(x: w.charX + w.charSize / 2, y: viewModel.absY)
                .allowsHitTesting(false)
        }
    }

    // MARK: - Ollie

    private var ollieLayer: some View {
        let w = viewModel.world
        return OllieCharacterView(
            size:       w.charSize,
            color:      viewModel.selectedOllieColor,
            rotation:   viewModel.phase == .playing ? viewModel.ollie.rotation : 0,
            wingPhase:  viewModel.ollie.wingPhase,
            isDead:     viewModel.phase == .dead,
            isBlinking: viewModel.isBlinking
        )
        .position(x: w.charX + w.charSize / 2, y: viewModel.absY)
    }

    // MARK: - Beam ready ring (gold pulsing ring around Ollie)

    @ViewBuilder
    private var beamReadyRing: some View {
        if viewModel.beamReady {
            let w = viewModel.world
            Circle()
                .strokeBorder(
                    Color(red: 0.95, green: 0.80, blue: 0.10).opacity(0.55),
                    lineWidth: 2
                )
                .frame(width: w.charSize * 1.45, height: w.charSize * 1.45)
                .position(x: w.charX + w.charSize / 2, y: viewModel.absY)
                .allowsHitTesting(false)
                .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true),
                           value: viewModel.beamReady)
        }
    }

    // MARK: - Eye Beam projectile

    private var projectileLayer: some View {
        ZStack {
            ForEach(viewModel.projectiles) { proj in
                BeamOrbView()
                    .position(x: proj.x, y: proj.y)
            }
        }
    }

    // MARK: - Danger glow (red circle that expands with proximity)

    @ViewBuilder
    private var dangerGlow: some View {
        if viewModel.dangerLevel > 0.05 {
            let w = viewModel.world
            Circle()
                .fill(Color.ollie_coral.opacity(viewModel.dangerLevel * 0.45))
                .frame(
                    width:  w.charSize * (1 + viewModel.dangerLevel * 0.4),
                    height: w.charSize * (1 + viewModel.dangerLevel * 0.4)
                )
                .position(x: w.charX + w.charSize / 2, y: viewModel.absY)
                .allowsHitTesting(false)
                .animation(.linear(duration: 0.08), value: viewModel.dangerLevel)
        }
    }

    // MARK: - Rings

    private var ringLayer: some View {
        ZStack {
            ForEach(viewModel.rings) { ring in
                RingEffectView(x: ring.x, y: ring.y)
            }
        }
    }

    // MARK: - Popups

    private var popupLayer: some View {
        ZStack {
            ForEach(viewModel.popups) { popup in
                Text(popup.text)
                    .font(.ollieMono(11, weight: .bold))
                    .foregroundStyle(popupColor(popup.kind))
                    .position(x: popup.x + 50, y: popup.y)
                    .transition(.asymmetric(
                        insertion: .offset(y: 0).combined(with: .opacity),
                        removal:   .offset(y: -44).combined(with: .opacity)
                    ))
            }
        }
        .animation(.easeOut(duration: 0.85), value: viewModel.popups.count)
    }

    private func popupColor(_ kind: PopupModel.Kind) -> Color {
        switch kind {
        case .coin:      return Color(red: 0.72, green: 0.53, blue: 0.04)
        case .closeCall: return Color.ollie_coral
        case .shield:    return Color(red: 0.2,  green: 0.65, blue: 1.0)
        case .speedUp:   return Color(red: 0.9,  green: 0.4,  blue: 0.1)
        case .beam:      return Color(red: 0.95, green: 0.80, blue: 0.10)
        }
    }

    // MARK: - Blink tint

    @ViewBuilder
    private var blinkTint: some View {
        if viewModel.isBlinking {
            LinearGradient(
                colors: [Color.ollie_coral.opacity(0.08), Color.ollie_ink.opacity(0.06)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            RoundedRectangle(cornerRadius: 48)
                .strokeBorder(Color.ollie_coral.opacity(0.35), lineWidth: 3)
                .ignoresSafeArea()
                .allowsHitTesting(false)
        }
    }

    // MARK: - Flash

    @ViewBuilder
    private var flashLayer: some View {
        if viewModel.flashActive {
            Color.ollie_coral.opacity(0.25)
                .ignoresSafeArea()
                .allowsHitTesting(false)
        }
    }

    // MARK: - UI Overlay

    private var uiLayer: some View {
        VStack {
            HStack {
                coinAndShieldBadge
                Spacer()
                speedBadge
                beamChargeBadge
            }
            .padding(.horizontal, 20)
            .padding(.top, 56)

            scoreDisplay

            Spacer()
        }
        .overlay(alignment: .leading) {
            blinkMeterBar
        }
    }

    private var coinAndShieldBadge: some View {
        HStack(spacing: 6) {
            CoinView(size: 18)
            Text("\(viewModel.score.coinsEarned)")
                .font(.ollieBody(13, weight: .bold))
                .foregroundStyle(Color.ollie_ink)
                .monospacedDigit()

            if viewModel.shielded {
                Image(systemName: "shield.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color(red: 0.2, green: 0.65, blue: 1.0))
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.vertical, 4)
        .padding(.leading, 6)
        .padding(.trailing, 10)
        .background(Color.ollie_subtle, in: Capsule())
        .animation(.spring(duration: 0.3), value: viewModel.shielded)
    }

    @ViewBuilder
    private var speedBadge: some View {
        if viewModel.speedTier > 0 {
            HStack(spacing: 3) {
                ForEach(0..<min(viewModel.speedTier, 4), id: \.self) { _ in
                    Image(systemName: "chevron.right")
                        .font(.system(size: 9, weight: .bold))
                }
            }
            .foregroundStyle(Color(red: 0.9, green: 0.4, blue: 0.1))
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(Color(red: 0.9, green: 0.4, blue: 0.1).opacity(0.12), in: Capsule())
            .transition(.scale.combined(with: .opacity))
        }
    }

    private var beamChargeBadge: some View {
        let ready  = viewModel.beamReady
        let charge = viewModel.beamCharge
        let gold   = Color(red: 0.95, green: 0.80, blue: 0.10)

        return ZStack {
            // Track ring
            Circle()
                .stroke(Color.ollie_ink.opacity(0.10), lineWidth: 3.5)
                .frame(width: 44, height: 44)

            // Charge arc
            Circle()
                .trim(from: 0, to: charge)
                .stroke(
                    ready ? gold : Color.ollie_muted,
                    style: StrokeStyle(lineWidth: 3.5, lineCap: .round)
                )
                .frame(width: 44, height: 44)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.08), value: charge)

            // Icon
            Image(systemName: ready ? "bolt.fill" : "bolt")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(ready ? gold : Color.ollie_muted)

            // "READY" flash
            if ready {
                Circle()
                    .stroke(gold.opacity(0.30), lineWidth: 6)
                    .frame(width: 44, height: 44)
                    .animation(
                        .easeInOut(duration: 0.7).repeatForever(autoreverses: true),
                        value: ready
                    )
            }
        }
        .frame(width: 44, height: 44)
        .scaleEffect(ready ? 1.08 : 1.0)
        .animation(.spring(duration: 0.3), value: ready)
    }

    private var scoreDisplay: some View {
        VStack(spacing: 4) {
            Text("\(viewModel.score.current)")
                .font(.ollieSerif(92))
                .foregroundStyle(Color.ollie_ink)
                .monospacedDigit()
                .lineLimit(1)

            if viewModel.scoreMultiplier > 1 {
                Text("×\(viewModel.scoreMultiplier)  ·  \(viewModel.combo) COMBO")
                    .font(.ollieMono(10, weight: .bold))
                    .foregroundStyle(Color.ollie_paper)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
                    .background(
                        viewModel.scoreMultiplier >= 3
                            ? Color(red: 0.9, green: 0.4, blue: 0.1)
                            : Color.ollie_coral,
                        in: RoundedRectangle(cornerRadius: 10)
                    )
                    .animation(.spring(duration: 0.25), value: viewModel.scoreMultiplier)
            }
        }
        .padding(.top, 4)
    }

    private var blinkMeterBar: some View {
        GeometryReader { geo in
            let barH = geo.size.height - viewModel.world.groundHeight - 30 - 110
            VStack(spacing: 4) {
                Text("BLINK")
                    .font(.ollieMono(8, weight: .bold))
                    .foregroundStyle(Color.ollie_muted)
                    .rotationEffect(.degrees(-90))
                    .fixedSize()

                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.ollie_ink.opacity(0.08))
                        .frame(width: 10, height: barH)

                    RoundedRectangle(cornerRadius: 5)
                        .fill(blinkMeterColor)
                        .frame(width: 10, height: max(0, barH * viewModel.blinkMeter))
                        .animation(.linear(duration: 0.08), value: viewModel.blinkMeter)
                }
                .frame(height: barH)

                Text(LocalizedStringKey(blinkLabel))
                    .font(.ollieMono(7, weight: .bold))
                    .foregroundStyle(
                        !viewModel.projectiles.isEmpty
                            ? Color(red: 0.95, green: 0.80, blue: 0.10)
                            : (viewModel.isBlinking ? Color.ollie_coral : Color.ollie_muted)
                    )
                    .rotationEffect(.degrees(-90))
                    .fixedSize()
            }
            .frame(width: 20)
            .position(x: 20, y: geo.size.height / 2)
        }
        .padding(.leading, 8)
    }

    private var blinkMeterColor: Color {
        if !viewModel.projectiles.isEmpty { return Color(red: 0.95, green: 0.80, blue: 0.10) }
        if viewModel.blinkMeter > 0.15    { return Color.ollie_coral }
        return Color.ollie_coral.opacity(0.35)
    }

    private var blinkLabel: String {
        if !viewModel.projectiles.isEmpty { return "BEAM" }
        if viewModel.isBlinking           { return "BLINK" }
        return "HOLD"
    }

    // MARK: - Beam zone glow (right edge, visible when beam ready)

    @ViewBuilder
    private func beamZoneGlow(geo: GeometryProxy) -> some View {
        if viewModel.beamReady {
            LinearGradient(
                colors: [Color.clear, Color(red: 0.95, green: 0.80, blue: 0.10).opacity(0.10)],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: geo.size.width * 0.42)
            .frame(maxHeight: .infinity)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .ignoresSafeArea()
            .allowsHitTesting(false)
            .animation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true),
                       value: viewModel.beamReady)
        }
    }

    // MARK: - Tap hint

    @ViewBuilder
    private var tapHint: some View {
        if viewModel.phase == .idle {
            VStack(spacing: 6) {
                Text("tap to fly")
                    .font(.ollieMono(11))
                    .foregroundStyle(Color.ollie_muted)
                Text("hold → BLINK  ·  right side → EYE BEAM ⚡")
                    .font(.ollieMono(9))
                    .foregroundStyle(Color.ollie_muted.opacity(0.7))
            }
            .position(
                x: viewModel.world.width / 2,
                y: viewModel.world.height - viewModel.world.groundHeight - 90
            )
        }
    }

    // MARK: - Touch Gesture (split zones)

    private func splitTouchGesture(geo: GeometryProxy) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                guard !isTouching else { return }
                isTouching = true
                // Right zone fires beam when charged — always flap+hold regardless
                if value.startLocation.x > geo.size.width * 0.58 && viewModel.beamReady {
                    viewModel.onBeamTap()
                }
                viewModel.onTap()
                viewModel.holdBegan()
            }
            .onEnded { _ in
                isTouching = false
                viewModel.holdEnded()
            }
    }
}

// MARK: - Mission Strip

// MARK: - Ring Effect

private struct RingEffectView: View {
    let x: CGFloat
    let y: CGFloat

    @State private var scale:   CGFloat = 0.6
    @State private var opacity: CGFloat = 0.9

    var body: some View {
        Circle()
            .strokeBorder(Color.ollie_ink, lineWidth: 1.5)
            .frame(width: 40, height: 40)
            .position(x: x, y: y)
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 0.42)) {
                    scale   = 2.4
                    opacity = 0
                }
            }
    }
}

// MARK: - Shield Ring (around Ollie when protected)

private struct ShieldRingView: View {
    let size: CGFloat
    @State private var pulse = false

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.2, green: 0.65, blue: 1.0).opacity(0.12))
                .scaleEffect(pulse ? 1.12 : 1.0)
            Circle()
                .strokeBorder(
                    Color(red: 0.2, green: 0.65, blue: 1.0).opacity(0.6),
                    lineWidth: 2.5
                )
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}

// MARK: - Eye Beam Orb

private struct BeamOrbView: View {
    @State private var pulse = false

    var body: some View {
        ZStack {
            // Trailing glow
            LinearGradient(
                colors: [Color(red: 0.95, green: 0.85, blue: 0.10).opacity(0.7), .clear],
                startPoint: .trailing,
                endPoint: .leading
            )
            .frame(width: 90, height: 8)
            .blur(radius: 4)
            .offset(x: -45)

            // Core orb
            Circle()
                .fill(Color.white)
                .frame(width: 10, height: 10)

            Circle()
                .fill(Color(red: 0.95, green: 0.85, blue: 0.10))
                .frame(width: 18, height: 18)
                .opacity(0.85)
                .scaleEffect(pulse ? 1.25 : 0.85)
                .blur(radius: 1)
        }
        .shadow(color: Color(red: 1.0, green: 0.9, blue: 0.2).opacity(0.9), radius: 10)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.12).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}

// MARK: - Shield Pickup View

struct ShieldPickupView: View {
    @State private var glow = false

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.2, green: 0.65, blue: 1.0).opacity(0.18))
                .frame(width: 30, height: 30)
                .scaleEffect(glow ? 1.3 : 1.0)
            Image(systemName: "shield.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color(red: 0.2, green: 0.65, blue: 1.0))
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.75).repeatForever(autoreverses: true)) {
                glow = true
            }
        }
    }
}
