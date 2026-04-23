import SwiftUI

struct CoinView: View {
    var size: CGFloat = 22
    @State private var shimmer = false

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.ollie_glow, Color.ollie_gold, Color(red: 0.82, green: 0.57, blue: 0.10)],
                        center: .topLeading,
                        startRadius: 2,
                        endRadius: size
                    )
                )
            Circle()
                .strokeBorder(Color.ollie_ink.opacity(0.75), lineWidth: 1.5)
            Text("o")
                .font(.ollieSerif(size * 0.55))
                .foregroundStyle(Color.ollie_ink)
            Circle()
                .trim(from: 0.08, to: 0.38)
                .stroke(Color.white.opacity(0.85), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .rotationEffect(.degrees(shimmer ? 340 : 20))
        }
        .frame(width: size, height: size)
        .shadow(color: Color.ollie_gold.opacity(0.35), radius: 6, x: 0, y: 3)
        .onAppear {
            withAnimation(.linear(duration: 1.8).repeatForever(autoreverses: false)) {
                shimmer = true
            }
        }
    }
}

struct CoinView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.ollie_cream.ignoresSafeArea()
            CoinView(size: 40)
        }
    }
}
