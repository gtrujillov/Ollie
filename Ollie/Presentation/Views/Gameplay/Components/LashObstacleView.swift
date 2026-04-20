import SwiftUI

struct LashObstacleView: View {
    let gapY:   CGFloat
    let gapH:   CGFloat
    let totalH: CGFloat
    let width:  CGFloat
    var color:  Color = .ollie_ink

    var body: some View {
        Canvas { context, size in
            var ctx = context
            drawTopPillar(&ctx, w: size.width)
            drawBottomPillar(&ctx, w: size.width, h: size.height)
        }
        .frame(width: width, height: totalH)
        .allowsHitTesting(false)
    }

    // MARK: - Pillars

    private func drawTopPillar(_ ctx: inout GraphicsContext, w: CGFloat) {
        guard gapY > 0 else { return }

        let rect = CGRect(x: 0, y: 0, width: w, height: gapY)
        let path = Path(
            UIBezierPath(
                roundedRect: rect,
                byRoundingCorners: [.bottomLeft, .bottomRight],
                cornerRadii: CGSize(width: 12, height: 12)
            ).cgPath
        )
        ctx.fill(path, with: .color(color))
        drawStrands(&ctx, atY: gapY, direction: .down, w: w)
    }

    private func drawBottomPillar(_ ctx: inout GraphicsContext, w: CGFloat, h: CGFloat) {
        let botY = gapY + gapH
        guard botY < h else { return }

        let rect = CGRect(x: 0, y: botY, width: w, height: h - botY)
        let path = Path(
            UIBezierPath(
                roundedRect: rect,
                byRoundingCorners: [.topLeft, .topRight],
                cornerRadii: CGSize(width: 12, height: 12)
            ).cgPath
        )
        ctx.fill(path, with: .color(color))
        drawStrands(&ctx, atY: botY, direction: .up, w: w)
    }

    // MARK: - Lash Strands

    private enum StrandDirection { case up, down }

    private func drawStrands(_ ctx: inout GraphicsContext, atY y: CGFloat, direction: StrandDirection, w: CGFloat) {
        let count = 6
        for i in 0..<count {
            let xPos    = 6 + CGFloat(i) * ((w - 12) / CGFloat(count - 1))
            let strandH = CGFloat(14 + (i % 2) * 6)
            let yOff    = CGFloat(8  + (i % 2) * 4)
            let rot     = CGFloat(i - 2) * 4.0 * .pi / 180

            let centerY: CGFloat = direction == .down
                ? y + yOff + strandH / 2
                : y - yOff - strandH / 2

            var local = ctx
            local.transform = CGAffineTransform.identity
                .translatedBy(x: xPos, y: centerY)
                .rotated(by: rot)

            var path = Path()
            path.addRoundedRect(
                in: CGRect(x: -1.25, y: -strandH / 2, width: 2.5, height: strandH),
                cornerSize: CGSize(width: 1.25, height: 1.25)
            )
            local.fill(path, with: .color(color))
        }
    }
}
