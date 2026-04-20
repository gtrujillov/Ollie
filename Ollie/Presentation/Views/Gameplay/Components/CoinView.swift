import SwiftUI

struct CoinView: View {
    var size: CGFloat = 22

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.ollie_gold)
            Circle()
                .strokeBorder(Color.ollie_ink, lineWidth: 1.5)
            Text("o")
                .font(.ollieSerif(size * 0.55))
                .foregroundStyle(Color.ollie_ink)
        }
        .frame(width: size, height: size)
        .shadow(color: .black.opacity(0.12), radius: 1, x: 0, y: 1)
    }
}

#Preview {
    ZStack {
        Color.ollie_cream.ignoresSafeArea()
        CoinView(size: 40)
    }
}
