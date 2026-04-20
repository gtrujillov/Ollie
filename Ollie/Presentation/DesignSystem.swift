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
