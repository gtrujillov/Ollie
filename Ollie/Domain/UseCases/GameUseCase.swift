import CoreGraphics

struct GameUseCase {
    let world:      GameWorld
    let difficulty: CGFloat   // 1.0 = normal

    // Base physics (difficulty-scaled, not score-scaled)
    private var baseGravity:   CGFloat { world.height * 1.604 * difficulty }
    private var jumpVelocity:  CGFloat { -world.height * 0.492 }
    private var baseSpeed:     CGFloat { world.width  * 0.498 * difficulty }
    private var baseGapH:      CGFloat { world.height * 210   / 874 }
    private var baseSpawnInt:  Double  { 1.6 / Double(difficulty) }

    // MARK: - Progressive difficulty (pure functions, ViewModel applies them)

    func speedMultiplier(score: Int) -> CGFloat {
        // +7 % every 8 points, capped at 2.2×
        min(1.0 + CGFloat(score / 8) * 0.07, 2.2)
    }

    func gapHeight(score: Int) -> CGFloat {
        // shrinks every 6 points, floor at 60 % of base
        let reduction = CGFloat(score / 6) * world.height * 0.008
        return max(baseGapH - reduction, baseGapH * 0.60)
    }

    func spawnInterval(score: Int) -> Double {
        // spawns accelerate with speed
        baseSpawnInt / Double(speedMultiplier(score: score))
    }

    // MARK: - Blink / Dash tuning

    let blinkDrainRate:      CGFloat = 0.45
    let blinkRechargeRate:   CGFloat = 0.08
    let blinkTimeScale:      CGFloat = 0.28
    let closeCallBlinkBonus: CGFloat = 0.25
    let closeCallScoreBonus: Int     = 3

    let beamChargeRate: CGFloat = 1.0 / 7.0   // full charge in 7 real seconds
    let beamSpeed:      CGFloat = 1800         // px/s

    // MARK: - Physics

    func jumpVelocityValue() -> CGFloat { jumpVelocity }

    func applyPhysics(_ s: OlliePhysics, dt: CGFloat, timeScale: CGFloat) -> OlliePhysics {
        let sdt = dt * timeScale
        var n = s
        n.vy        += baseGravity * sdt
        n.y         += n.vy * sdt
        n.rotation   = max(-30, min(70, n.vy * 0.08))
        n.wingPhase += sdt * 12
        return n
    }

    // MARK: - Bounds & collision

    func isOutOfBounds(absY: CGFloat) -> Bool {
        absY > world.height - world.groundHeight - world.charSize / 2
            || absY < world.ceilingHeight - world.charSize / 2
    }

    func collides(absY: CGFloat, with o: ObstacleModel) -> Bool {
        let inX = o.x < world.charX + world.charSize * 0.7
               && o.x + world.obstacleWidth > world.charX + world.charSize * 0.3
        guard inX else { return false }
        return absY < o.gapY + 8 || absY > o.gapY + o.gapH - 8
    }

    func hasPassed(_ o: ObstacleModel) -> Bool {
        o.x + world.obstacleWidth < world.charX
    }

    func isCloseCall(absY: CGFloat, o: ObstacleModel, bonusFactor: CGFloat = 0) -> Bool {
        let margin = min(absY - o.gapY, (o.gapY + o.gapH) - absY)
        return margin < world.charSize * (0.43 + bonusFactor)
    }

    // 0–1 danger signal for visual feedback
    func dangerLevel(absY: CGFloat, obstacles: [ObstacleModel]) -> CGFloat {
        guard let near = obstacles.first(where: {
            $0.x + world.obstacleWidth > world.charX - 10 &&
            $0.x < world.charX + world.charSize
        }) else { return 0 }
        let margin = min(absY - near.gapY, (near.gapY + near.gapH) - absY)
        return max(0, 1 - margin / (world.charSize * 1.8))
    }

    // MARK: - Movement

    func moveObstacles(_ obstacles: [ObstacleModel], sdt: CGFloat) -> [ObstacleModel] {
        obstacles.compactMap { o in
            var m  = o
            m.x   -= baseSpeed * sdt
            return m.x > -100 ? m : nil
        }
    }

    // Update gapY for oscillating obstacles
    func updateOscillation(_ obstacles: [ObstacleModel], sdt: CGFloat) -> [ObstacleModel] {
        let amplitude = world.height * 0.065
        let minGY     = world.ceilingHeight + 22
        return obstacles.map { o in
            guard o.oscillating else { return o }
            var m      = o
            m.oscPhase += sdt * 2.0
            let maxGY   = world.height - world.groundHeight - o.gapH - 22
            m.gapY      = max(minGY, min(maxGY, o.baseGapY + sin(m.oscPhase) * amplitude))
            return m
        }
    }

    func movePickups(_ pickups: [PickupModel], sdt: CGFloat) -> [PickupModel] {
        pickups.compactMap { p in
            var m  = p
            m.x   -= baseSpeed * sdt
            return !m.collected && m.x > -40 ? m : nil
        }
    }

    // MARK: - Spawning

    func spawnObstacle(score: Int) -> (ObstacleModel, [PickupModel]) {
        let gh    = gapHeight(score: score)
        let minGY = world.ceilingHeight + 50
        let maxGY = max(minGY + 1, world.height - world.groundHeight - gh - 100)
        let gapY  = minGY + CGFloat.random(in: 0...(maxGY - minGY))

        var obs = ObstacleModel(x: world.width + 40, gapY: gapY, gapH: gh)

        // 30 % chance of oscillating obstacle (after score 5)
        if score > 5 && CGFloat.random(in: 0...1) < 0.30 {
            obs.oscillating = true
            obs.oscPhase    = CGFloat.random(in: 0...(2 * .pi))
        }

        let pickups = spawnPickups(gapY: gapY, gapH: gh, baseX: world.width + 40)
        return (obs, pickups)
    }

    private func spawnPickups(gapY: CGFloat, gapH: CGFloat, baseX: CGFloat) -> [PickupModel] {
        let cx = baseX + world.obstacleWidth / 2 - 11
        let cy = gapY  + gapH / 2

        let roll = CGFloat.random(in: 0...1)
        if roll < 0.07 {
            // Shield (rare)
            return [PickupModel(x: cx, y: cy, kind: .shield)]
        } else if roll < 0.28 {
            // Arc of 5 coins through the gap
            return (0..<5).map { j in
                let t: CGFloat = CGFloat(j) / 4.0
                let px = cx - 40 + CGFloat(j) * 20
                let py = cy + sin(t * .pi) * (gapH * 0.22)
                return PickupModel(x: px, y: py, kind: .coin)
            }
        } else if roll < 0.68 {
            // Single coin
            return [PickupModel(x: cx, y: cy, kind: .coin)]
        }
        return []
    }

    // MARK: - Projectile (Eye Beam)

    func moveProjectiles(_ projectiles: [ProjectileModel], sdt: CGFloat) -> [ProjectileModel] {
        projectiles.compactMap { p in
            var m = p
            m.x += beamSpeed * sdt
            return m.x < world.width + 80 ? m : nil
        }
    }

    func collidesWithProjectile(_ proj: ProjectileModel, obstacle: ObstacleModel) -> Bool {
        proj.x >= obstacle.x - 10 && proj.x <= obstacle.x + world.obstacleWidth + 10
    }

    // MARK: - Pickup collision

    func collidesWithPickup(absY: CGFloat, pickup: PickupModel, magnetBonus: CGFloat = 0) -> Bool {
        let dx = (pickup.x + 11) - (world.charX + world.charSize / 2)
        let dy = pickup.y - absY
        return sqrt(dx * dx + dy * dy) < world.charSize / 2 + 14 + magnetBonus
    }
}
