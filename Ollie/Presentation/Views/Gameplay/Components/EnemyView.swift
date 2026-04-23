import SwiftUI

// MARK: - Walker Enemy

struct WalkerEnemyView: View {
    var size:       CGFloat = 54
    var facingLeft: Bool    = false
    var isDead:     Bool    = false
    var runPhase:   CGFloat = 0

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 1.0, green: 0.56, blue: 0.42),
                            Color(red: 0.88, green: 0.22, blue: 0.18),
                            Color(red: 0.45, green: 0.08, blue: 0.09)
                        ],
                        center: .topLeading,
                        startRadius: 4,
                        endRadius: size
                    )
                )
                .frame(width: size, height: size)
                .shadow(color: Color.red.opacity(0.20), radius: 10, x: 0, y: 8)

            Circle()
                .strokeBorder(Color.white.opacity(0.22), lineWidth: 1)
                .frame(width: size * 0.88, height: size * 0.88)
                .offset(y: -size * 0.02)

            // Face
            if !isDead {
                ZStack {
                    // Eyes
                    HStack(spacing: size * 0.12) {
                        angryEye
                        angryEye
                    }
                    // Teeth
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white.opacity(0.96))
                        .frame(width: size * 0.30, height: size * 0.10)
                        .offset(y: size * 0.20)
                }
            } else {
                // X eyes on death
                Canvas { ctx, sz in
                    var path = Path()
                    let m = sz.width * 0.25
                    path.move(to: CGPoint(x: m, y: m))
                    path.addLine(to: CGPoint(x: sz.width - m, y: sz.height - m))
                    path.move(to: CGPoint(x: sz.width - m, y: m))
                    path.addLine(to: CGPoint(x: m, y: sz.height - m))
                    ctx.stroke(path, with: .color(.white),
                               style: StrokeStyle(lineWidth: sz.width * 0.09, lineCap: .round))
                }
                .frame(width: size * 0.5, height: size * 0.5)
            }

            // Legs
            HStack(spacing: size * 0.22) {
                leg(phase: Double(runPhase))
                leg(phase: Double(runPhase) + .pi)
            }
            .offset(y: size * 0.52)
        }
        .frame(width: size, height: size * 1.35)
        .scaleEffect(x: facingLeft ? -1 : 1, y: 1)
        .opacity(isDead ? 0.4 : 1.0)
    }

    private var angryEye: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: size * 0.18, height: size * 0.18)
            Circle()
                .fill(Color.ollie_ink)
                .frame(width: size * 0.10, height: size * 0.10)
        }
    }

    private func leg(phase: Double) -> some View {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(red: 0.65, green: 0.12, blue: 0.10))
                .frame(width: size * 0.09, height: size * 0.24)
                .rotationEffect(.degrees(sin(phase) * 18), anchor: .top)
    }
}

// MARK: - Cannon Enemy

struct CannonEnemyView: View {
    var size:       CGFloat = 60
    var isFiring:   Bool    = false

    var body: some View {
        ZStack {
            HStack(spacing: size * 0.42) {
                wheel
                wheel
            }
            .offset(y: size * 0.36)

            RoundedRectangle(cornerRadius: size * 0.14)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.40, green: 0.42, blue: 0.48),
                            Color(red: 0.22, green: 0.22, blue: 0.26),
                            Color(red: 0.12, green: 0.12, blue: 0.16)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size * 0.64)
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.14)
                        .strokeBorder(Color.white.opacity(0.16), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.24), radius: 8, x: 0, y: 6)

            RoundedRectangle(cornerRadius: 4)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.18, green: 0.19, blue: 0.24), Color.black.opacity(0.72)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: size * 0.62, height: size * 0.22)
                .offset(x: -size * 0.54)

            if isFiring {
                Circle()
                    .fill(Color.orange.opacity(0.85))
                    .frame(width: size * 0.28, height: size * 0.28)
                    .offset(x: -size * 0.85)
                    .blur(radius: 0.5)
                    .transition(.scale.combined(with: .opacity))
            }

            Circle()
                .fill(Color(red: 0.35, green: 0.35, blue: 0.40))
                .frame(width: size * 0.16, height: size * 0.16)
                .offset(x: size * 0.18)
        }
        .frame(width: size * 1.3, height: size)
        .animation(.easeOut(duration: 0.08), value: isFiring)
    }

    private var wheel: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.30, green: 0.22, blue: 0.12))
                .frame(width: size * 0.30, height: size * 0.30)
            Circle()
                .fill(Color(red: 0.55, green: 0.40, blue: 0.22))
                .frame(width: size * 0.16, height: size * 0.16)
        }
    }
}

// MARK: - Fireball Projectile

struct FireballView: View {
    @State private var pulse = false

    var body: some View {
        ZStack {
            Circle()
                .fill(RadialGradient(
                    colors: [Color.yellow, Color.orange, Color.red.opacity(0.82), Color.red.opacity(0.42)],
                    center: .center,
                    startRadius: 0,
                    endRadius: 14
                ))
                .frame(width: 26, height: 26)
                .scaleEffect(pulse ? 1.25 : 0.85)
                .shadow(color: .orange.opacity(0.8), radius: 10)

            LinearGradient(
                colors: [Color.orange.opacity(0.7), .clear],
                startPoint: .trailing,
                endPoint: .leading
            )
            .frame(width: 50, height: 10)
            .blur(radius: 3)
            .offset(x: 20)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.15).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}

struct EnemyView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.ollie_cream.ignoresSafeArea()
            VStack(spacing: 30) {
                WalkerEnemyView(size: 54)
                CannonEnemyView(size: 60)
                FireballView()
            }
        }
    }
}
