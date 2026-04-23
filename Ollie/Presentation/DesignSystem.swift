import SwiftUI

// MARK: - Colors

extension Color {
    static let ollie_ink    = Color(red: 22/255,  green: 22/255,  blue: 29/255)
    static let ollie_cream  = Color(red: 245/255, green: 239/255, blue: 230/255)
    static let ollie_paper  = Color(red: 250/255, green: 246/255, blue: 239/255)
    static let ollie_coral  = Color(red: 232/255, green: 90/255,  blue: 79/255)
    static let ollie_gold   = Color(red: 242/255, green: 201/255, blue: 76/255)
    static let ollie_muted  = Color(red: 22/255,  green: 22/255,  blue: 29/255).opacity(0.45)
    static let ollie_subtle = Color(red: 22/255,  green: 22/255,  blue: 29/255).opacity(0.06)
    static let ollie_night  = Color(red: 18/255,  green: 22/255,  blue: 38/255)
    static let ollie_sky    = Color(red: 118/255, green: 162/255, blue: 243/255)
    static let ollie_mint   = Color(red: 111/255, green: 228/255, blue: 196/255)
    static let ollie_plum   = Color(red: 103/255, green: 72/255,  blue: 170/255)
    static let ollie_glow   = Color(red: 255/255, green: 236/255, blue: 171/255)
}

// MARK: - Typography

extension Font {
    static func ollieSerif(_ size: CGFloat) -> Font {
        Font.custom("Georgia-Italic", size: size)
    }

    static func ollieMono(_ size: CGFloat, weight: Weight = .regular) -> Font {
        Font.system(size: size, weight: weight, design: .monospaced)
    }

    static func ollieBody(_ size: CGFloat, weight: Weight = .regular) -> Font {
        Font.system(size: size, weight: weight, design: .rounded)
    }
}

// MARK: - Shape Helper

struct RoundedCorner: Shape {
    var radius:  CGFloat      = 0
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let bz = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(bz.cgPath)
    }
}

extension View {
    func roundedCorners(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

// MARK: - Premium surfaces

struct PremiumPanel: ViewModifier {
    var tint: Color = .white
    var cornerRadius: CGFloat = 24
    var shadowOpacity: CGFloat = 0.18

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                tint.opacity(0.82),
                                Color.white.opacity(0.56)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.35), lineWidth: 1)
                    )
            )
            .shadow(color: Color.ollie_ink.opacity(shadowOpacity), radius: 18, x: 0, y: 10)
    }
}

extension View {
    func premiumPanel(tint: Color = .white, cornerRadius: CGFloat = 24, shadowOpacity: CGFloat = 0.18) -> some View {
        modifier(PremiumPanel(tint: tint, cornerRadius: cornerRadius, shadowOpacity: shadowOpacity))
    }
}

struct PremiumCapsuleButtonStyle: ButtonStyle {
    var fill: Color
    var foreground: Color = .white

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(foreground)
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(
                Capsule(style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                fill.opacity(configuration.isPressed ? 0.80 : 1.0),
                                fill.opacity(configuration.isPressed ? 0.95 : 0.88)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        Capsule(style: .continuous)
                            .strokeBorder(Color.white.opacity(0.24), lineWidth: 1)
                    )
            )
            .shadow(color: fill.opacity(configuration.isPressed ? 0.18 : 0.30), radius: configuration.isPressed ? 6 : 12, x: 0, y: configuration.isPressed ? 2 : 8)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.24, dampingFraction: 0.72), value: configuration.isPressed)
    }
}
