import SwiftUI

struct PlatformView: View {
    let width:     CGFloat
    let thickness: CGFloat
    var color:     Color = Color.ollie_ink
    var isMoving:  Bool  = false

    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            color.opacity(isMoving ? 0.90 : 1.0),
                            color.opacity(0.70),
                            Color.ollie_ink.opacity(0.35)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: width, height: thickness)
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
                )
                .shadow(color: color.opacity(isMoving ? 0.35 : 0.18), radius: 10, x: 0, y: 6)

            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.white.opacity(0.22))
                .frame(width: width - 12, height: 5)
                .offset(y: 4)

            HStack(spacing: 14) {
                ForEach(0..<max(2, Int(width / 55)), id: \.self) { _ in
                    Capsule(style: .continuous)
                        .fill(Color.white.opacity(0.16))
                        .frame(width: 18, height: 3)
                }
            }
            .offset(y: thickness * 0.58)
        }
    }
}
