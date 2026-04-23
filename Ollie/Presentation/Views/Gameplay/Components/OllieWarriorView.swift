import SwiftUI

/// Ollie reimagined as a round-eyed warrior with a helmet and sword.
struct OllieWarriorView: View {
    var size:       CGFloat
    var color:      Color   = .ollie_paper
    var runPhase:   CGFloat = 0
    var isAttacking: Bool   = false
    var isDead:     Bool    = false
    var isBlinking: Bool    = false  // invincibility flicker

    private var legPhase: Double { Double(runPhase) }

    var body: some View {
        ZStack {
            if isAttacking {
                slashTrail
            }
            swordArm
            warriorBody
            helmet
            legs
        }
        .frame(width: size * 1.8, height: size * 1.4)
        .opacity(isBlinking ? 0.35 : 1.0)
    }

    // MARK: - Body (round Ollie eye)

    private var warriorBody: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            color.opacity(0.98),
                            color,
                            color.opacity(0.72)
                        ],
                        center: .topLeading,
                        startRadius: 6,
                        endRadius: size
                    )
                )
                .shadow(color: .black.opacity(0.14), radius: 8, x: 0, y: 6)
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .strokeBorder(Color.white.opacity(0.45), lineWidth: 1)
                        .padding(3)
                )

            if !isDead {
                faceOverlay
            } else {
                xEyes
            }
        }
    }

    private var faceOverlay: some View {
        ZStack {
            // Iris
            Ellipse()
                .fill(Color.ollie_ink)
                .frame(width: size * 0.48, height: size * 0.48)
                .overlay(
                    ZStack {
                        Circle()
                            .fill(Color.ollie_coral)
                            .frame(width: size * 0.24, height: size * 0.24)
                        Circle()
                            .fill(Color.white)
                            .frame(width: size * 0.12, height: size * 0.12)
                            .offset(x: -size * 0.05, y: -size * 0.07)
                    }
                )
                .offset(x: size * 0.06)  // look right

            // Determined brow (warrior look)
            Path { path in
                path.move(to: CGPoint(x: -size * 0.18, y: -size * 0.28))
                path.addLine(to: CGPoint(x: size * 0.24, y: -size * 0.22))
            }
            .stroke(Color.ollie_ink, style: StrokeStyle(lineWidth: size * 0.05, lineCap: .round))

            // Blush
            Ellipse()
                .fill(Color.ollie_coral.opacity(0.25))
                .frame(width: size * 0.12, height: size * 0.05)
                .offset(x: -size * 0.20, y: size * 0.16)
            Ellipse()
                .fill(Color.ollie_coral.opacity(0.25))
                .frame(width: size * 0.12, height: size * 0.05)
                .offset(x: size * 0.26, y: size * 0.16)
        }
    }

    private var xEyes: some View {
        Canvas { ctx, sz in
            var path = Path()
            let m: CGFloat = sz.width * 0.20
            path.move(to: CGPoint(x: m, y: m))
            path.addLine(to: CGPoint(x: sz.width - m, y: sz.height - m))
            path.move(to: CGPoint(x: sz.width - m, y: m))
            path.addLine(to: CGPoint(x: m, y: sz.height - m))
            ctx.stroke(path, with: .color(.ollie_ink),
                       style: StrokeStyle(lineWidth: sz.width * 0.10, lineCap: .round))
        }
        .frame(width: size * 0.5, height: size * 0.5)
    }

    // MARK: - Helmet

    private var helmet: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(
                    LinearGradient(
                        colors: [Color.ollie_ink, Color.ollie_night],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: size * 0.72, height: size * 0.30)
                .offset(y: -size * 0.60)

            RoundedRectangle(cornerRadius: 3)
                .fill(Color(red: 0.6, green: 0.65, blue: 0.7))
                .frame(width: size * 0.40, height: size * 0.10)
                .offset(x: size * 0.06, y: -size * 0.52)

            Capsule()
                .fill(Color.ollie_coral)
                .frame(width: size * 0.10, height: size * 0.26)
                .offset(x: -size * 0.26, y: -size * 0.76)
        }
    }

    // MARK: - Sword arm

    private var swordArm: some View {
        let attackRot: CGFloat = isAttacking ? -35 : 8
        return ZStack {
            Capsule()
                .fill(color)
                .frame(width: size * 0.18, height: size * 0.34)
                .offset(x: size * 0.56, y: size * 0.04)
                .rotationEffect(.degrees(Double(attackRot)), anchor: .top)

            RoundedRectangle(cornerRadius: 2)
                .fill(
                    LinearGradient(
                        colors: [Color.white, Color(red: 0.78, green: 0.82, blue: 0.88), Color.ollie_sky.opacity(0.8)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: size * 0.10, height: size * 0.70)
                .overlay(alignment: .top) {
                    Triangle()
                        .fill(Color(red: 0.78, green: 0.82, blue: 0.88))
                        .frame(width: size * 0.10, height: size * 0.12)
                        .offset(y: -size * 0.10)
                }
                .offset(x: size * 0.58, y: -size * 0.18)
                .rotationEffect(.degrees(Double(attackRot)), anchor: UnitPoint(x: 0.5, y: 0.85))
                .shadow(color: Color.ollie_sky.opacity(isAttacking ? 0.35 : 0.12), radius: isAttacking ? 10 : 4, x: 0, y: 0)

            RoundedRectangle(cornerRadius: 2)
                .fill(Color(red: 0.85, green: 0.70, blue: 0.10))
                .frame(width: size * 0.28, height: size * 0.07)
                .offset(x: size * 0.58, y: size * 0.14)
                .rotationEffect(.degrees(Double(attackRot)), anchor: UnitPoint(x: 0.5, y: 0.85))
        }
        .animation(.spring(duration: 0.15), value: isAttacking)
    }

    // MARK: - Legs

    private var legs: some View {
        let l1 = CGFloat(sin(legPhase) * 16)
        let l2 = CGFloat(-sin(legPhase) * 16)
        return ZStack {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.ollie_ink)
                .frame(width: size * 0.10, height: size * 0.24)
                .offset(x: -size * 0.15, y: size * 0.60)
                .rotationEffect(.degrees(Double(l1)), anchor: .top)

            RoundedRectangle(cornerRadius: 2)
                .fill(Color.ollie_ink)
                .frame(width: size * 0.10, height: size * 0.24)
                .offset(x: size * 0.15, y: size * 0.60)
                .rotationEffect(.degrees(Double(l2)), anchor: .top)
        }
    }

    private var slashTrail: some View {
        Capsule(style: .continuous)
            .fill(
                LinearGradient(
                    colors: [Color.white.opacity(0.0), Color.ollie_glow.opacity(0.95), Color.ollie_coral.opacity(0.18)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: size * 1.1, height: size * 0.22)
            .blur(radius: 1)
            .rotationEffect(.degrees(-18))
            .offset(x: size * 0.74, y: -size * 0.08)
    }
}

// MARK: - Triangle shape helper

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

struct OllieWarriorView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.ollie_cream.ignoresSafeArea()
            VStack(spacing: 20) {
                OllieWarriorView(size: 80, runPhase: 0)
                OllieWarriorView(size: 80, runPhase: 0, isAttacking: true)
                OllieWarriorView(size: 80, runPhase: 0, isDead: true)
            }
        }
    }
}
