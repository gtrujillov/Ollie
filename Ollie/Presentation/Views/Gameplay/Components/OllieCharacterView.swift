import SwiftUI

struct OllieCharacterView: View {
    let size:      CGFloat
    var color:     Color   = .ollie_paper
    var rotation:  CGFloat = 0
    var wingPhase: CGFloat = 0
    var isDead:    Bool    = false
    var isBlinking: Bool   = false

    private var wingUp: Bool { sin(wingPhase) > 0 }

    var body: some View {
        ZStack {
            wings
            eyeball
            legs
        }
        .frame(width: size * 1.5, height: size)
        .rotationEffect(.degrees(Double(rotation)))
    }

    // MARK: - Wings

    private var wings: some View {
        ZStack {
            // Left wing
            wingShape
                .fill(color)
                .frame(width: size * 0.42, height: size * 0.5)
                .rotationEffect(.degrees(wingUp ? -20 : 30))
                .scaleEffect(y: wingUp ? 1.0 : 0.55)
                .offset(x: -size * 0.52)
                .animation(.linear(duration: 0.07), value: wingUp)

            // Right wing
            wingShape
                .fill(color)
                .frame(width: size * 0.42, height: size * 0.5)
                .rotationEffect(.degrees(wingUp ? 20 : -30))
                .scaleEffect(y: wingUp ? 1.0 : 0.55)
                .offset(x: size * 0.52)
                .animation(.linear(duration: 0.07), value: wingUp)
        }
    }

    private var wingShape: some Shape { Capsule() }

    // MARK: - Eyeball

    private var eyeball: some View {
        Circle()
            .fill(color)
            .shadow(color: .black.opacity(0.07), radius: 2, x: 0, y: size * 0.04)
            .frame(width: size, height: size)
            .overlay(faceOverlay)
    }

    @ViewBuilder
    private var faceOverlay: some View {
        ZStack {
            if !isDead {
                // Iris
                Ellipse()
                    .fill(Color.ollie_ink)
                    .frame(width: size * 0.5, height: isBlinking ? size * 0.06 : size * 0.5)
                    .animation(.easeInOut(duration: 0.1), value: isBlinking)
                    .overlay(
                        Group {
                            if !isBlinking {
                                ZStack {
                                    Circle()
                                        .fill(Color.ollie_coral)
                                        .frame(width: size * 0.26, height: size * 0.26)
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: size * 0.14, height: size * 0.14)
                                        .offset(x: -size * 0.06, y: -size * 0.08)
                                }
                            }
                        }
                    )
            } else {
                // X eyes
                xEyes
            }

            // Blush
            Ellipse()
                .fill(Color.ollie_coral.opacity(0.28))
                .frame(width: size * 0.13, height: size * 0.06)
                .offset(x: -size * 0.22, y: size * 0.18)
            Ellipse()
                .fill(Color.ollie_coral.opacity(0.28))
                .frame(width: size * 0.13, height: size * 0.06)
                .offset(x: size * 0.22, y: size * 0.18)
        }
    }

    private var xEyes: some View {
        Canvas { ctx, sz in
            var path = Path()
            let m: CGFloat = sz.width * 0.22
            path.move(to: CGPoint(x: m, y: m))
            path.addLine(to: CGPoint(x: sz.width - m, y: sz.height - m))
            path.move(to: CGPoint(x: sz.width - m, y: m))
            path.addLine(to: CGPoint(x: m, y: sz.height - m))
            ctx.stroke(
                path,
                with: .color(.ollie_ink),
                style: StrokeStyle(lineWidth: sz.width * 0.11, lineCap: .round)
            )
        }
        .frame(width: size * 0.5, height: size * 0.5)
    }

    // MARK: - Legs

    private var legs: some View {
        HStack(spacing: size * 0.36) {
            legPill
            legPill
        }
        .offset(y: size * 0.52)
    }

    private var legPill: some View {
        RoundedRectangle(cornerRadius: 1)
            .fill(Color.ollie_ink)
            .frame(width: 2, height: size * 0.1)
    }
}

struct OllieCharacterView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.ollie_cream.ignoresSafeArea()
            OllieCharacterView(size: 100, wingPhase: 0)
        }
    }
}
