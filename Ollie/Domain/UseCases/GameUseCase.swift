import CoreGraphics
import Foundation

// MARK: - Platformer Physics Engine (pure, stateless)

struct GameUseCase {
    let world: GameWorld

    // Physics constants
    let gravity:       CGFloat = 2250
    let jumpVelocity:  CGFloat = -1090
    let runSpeed:      CGFloat = 280
    let maxFallSpeed:  CGFloat = 1650
    let attackDuration: CGFloat = 0.26
    let invincibleDuration: CGFloat = 1.8
    let swordReach:    CGFloat = 90
    let coyoteTime:    CGFloat = 0.12
    let jumpBufferTime: CGFloat = 0.12

    // MARK: - Player physics

    func applyGravity(to p: PlayerState, dt: CGFloat) -> PlayerState {
        var n = p
        n.vy = min(n.vy + gravity * dt, maxFallSpeed)
        n.screenY += n.vy * dt
        n.runPhase += dt * 10  // running animation
        n.worldX   += runSpeed * dt
        n.coyoteTimer = n.isOnGround ? coyoteTime : max(0, n.coyoteTimer - dt)
        n.jumpBufferTimer = max(0, n.jumpBufferTimer - dt)

        // Timers
        if n.attackTimer > 0 {
            n.attackTimer -= dt
            if n.attackTimer <= 0 {
                n.attackTimer  = 0
                n.isAttacking  = false
            }
        }
        if n.invincibleTimer > 0 {
            n.invincibleTimer -= dt
            if n.invincibleTimer < 0 { n.invincibleTimer = 0 }
        }
        return n
    }

    func jump(_ p: PlayerState) -> PlayerState {
        var n = p

        if p.isOnGround || p.coyoteTimer > 0 {
            n.vy = jumpVelocity
            n.isOnGround = false
            n.coyoteTimer = 0
            n.jumpBufferTimer = 0
            n.extraJumpsRemaining = 1
            return n
        }

        if p.extraJumpsRemaining > 0 {
            n.vy = jumpVelocity * 0.94
            n.isOnGround = false
            n.jumpBufferTimer = 0
            n.extraJumpsRemaining -= 1
            return n
        }

        n.jumpBufferTimer = jumpBufferTime
        return n
    }

    func attack(_ p: PlayerState) -> PlayerState {
        guard !p.isAttacking else { return p }
        var n        = p
        n.isAttacking = true
        n.attackTimer = attackDuration
        return n
    }

    func applyInvincibility(_ p: PlayerState) -> PlayerState {
        var n = p
        n.invincibleTimer = invincibleDuration
        return n
    }

    // MARK: - Ground collision

    func resolveGround(player p: PlayerState, groundSegs: [GroundSegment]) -> PlayerState {
        var n = p
        let groundY = world.groundY
        let bottom  = n.screenY + world.charSize * 0.5

        let onSeg = groundSegs.contains { seg in
            n.worldX >= seg.startX && n.worldX <= seg.endX
        }

        if onSeg && bottom >= groundY && n.vy >= 0 {
            n.screenY   = groundY - world.charSize * 0.5
            n.vy        = 0
            n.isOnGround = true
            n.coyoteTimer = coyoteTime
            n.extraJumpsRemaining = 1
        } else if !onSeg {
            n.isOnGround = false
        }
        return n
    }

    // MARK: - Platform collision

    func resolvePlatforms(player p: PlayerState, platforms: [PlatformModel]) -> PlayerState {
        var n = p
        guard n.vy > 0 else {
            // Still check if standing on a platform (prevent falling through)
            for plat in platforms {
                let platScreenY = world.screenY(norm: plat.normY)
                let topOfPlat   = platScreenY
                let pLeft       = world.charScreenX - world.charSize * 0.35
                let pRight      = world.charScreenX + world.charSize * 0.35
                let platLeft    = plat.currentWorldX - (n.worldX - world.charScreenX)
                let platRight   = platLeft + plat.width

                if pRight > platLeft && pLeft < platRight {
                    let pBottom = n.screenY + world.charSize * 0.5
                    if abs(pBottom - topOfPlat) < 4 {
                        n.isOnGround = true
                        return n
                    }
                }
            }
            return n
        }

        let prevBottom = n.screenY - n.vy * (1.0/60.0) + world.charSize * 0.5  // approximate prev pos
        let currBottom = n.screenY + world.charSize * 0.5
        let pLeft      = world.charScreenX - world.charSize * 0.35
        let pRight     = world.charScreenX + world.charSize * 0.35

        for plat in platforms {
            let platScreenY = world.screenY(norm: plat.normY)
            let topOfPlat   = platScreenY
            let platLeft    = plat.currentWorldX - (n.worldX - world.charScreenX)
            let platRight   = platLeft + plat.width

            let overlapX = pRight > platLeft && pLeft < platRight
            guard overlapX else { continue }

            // Landing detection: was above, now at or below top
            if prevBottom <= topOfPlat + 6 && currBottom >= topOfPlat - 2 {
                n.screenY   = topOfPlat - world.charSize * 0.5
                n.vy        = 0
                n.isOnGround = true
                n.coyoteTimer = coyoteTime
                n.extraJumpsRemaining = 1
                return n
            }
        }
        return n
    }

    func consumeBufferedJumpIfPossible(_ p: PlayerState) -> PlayerState {
        guard p.jumpBufferTimer > 0, p.isOnGround || p.coyoteTimer > 0 else { return p }
        return jump(p)
    }

    // MARK: - Moving platform tick

    func updateMovingPlatforms(_ platforms: [PlatformModel], dt: CGFloat) -> [PlatformModel] {
        platforms.map { p in
            guard p.isMoving else { return p }
            var m         = p
            m.movePhase  += dt * p.moveSpeed
            return m
        }
    }

    // MARK: - Enemy AI

    func updateEnemies(_ enemies: [EnemyModel], dt: CGFloat) -> [EnemyModel] {
        enemies.map { e in
            var m = e
            if m.isDead {
                m.deathTimer += dt
                return m
            }
            switch m.type {
            case .walker:
                m.worldX += m.velocityX * dt
                if m.worldX >= m.patrolRight  { m.velocityX = -abs(m.velocityX) }
                if m.worldX <= m.patrolLeft   { m.velocityX =  abs(m.velocityX) }
            case .cannon:
                m.fireTimer += dt
            }
            return m
        }
    }

    func spawnFireballs(from enemies: [EnemyModel]) -> [FireballModel] {
        enemies.compactMap { e in
            guard e.type == .cannon && !e.isDead && e.fireTimer >= e.fireInterval else { return nil }
            return FireballModel(worldX: e.worldX - 20, screenY: world.screenY(norm: e.normY) - world.charSize * 0.2)
        }
    }

    func consumeFireballTimers(_ enemies: [EnemyModel]) -> [EnemyModel] {
        enemies.map { e in
            guard e.type == .cannon && !e.isDead && e.fireTimer >= e.fireInterval else { return e }
            var m = e
            m.fireTimer = 0
            return m
        }
    }

    func moveFireballs(_ fireballs: [FireballModel], dt: CGFloat, cameraX: CGFloat) -> [FireballModel] {
        fireballs.compactMap { f in
            var m = f
            m.worldX -= f.speed * dt
            // Remove if far off-screen left or out of bounds
            let screenX = m.worldX - cameraX
            return (screenX > -120 && m.worldX > 0) ? m : nil
        }
    }

    // MARK: - Collision detection

    /// Returns true if player is hit by a walking enemy
    func playerHitByEnemy(player p: PlayerState, enemies: [EnemyModel]) -> Bool {
        guard !p.isInvincible else { return false }
        let pr = world.charSize * 0.42
        for e in enemies where !e.isDead && e.type == .walker {
            let screenX = e.worldX - (p.worldX - world.charScreenX)
            let es = world.charSize * 0.45
            let dx = abs(screenX - world.charScreenX)
            let dy = abs(world.screenY(norm: e.normY) - p.screenY)
            if dx < pr + es && dy < pr + es { return true }
        }
        return false
    }

    /// Returns true if player is hit by a fireball
    func playerHitByFireball(player p: PlayerState, fireballs: [FireballModel]) -> Bool {
        guard !p.isInvincible else { return false }
        let pr = world.charSize * 0.40
        let fr: CGFloat = 14
        for f in fireballs {
            let screenX = f.worldX - (p.worldX - world.charScreenX)
            let dx = abs(screenX - world.charScreenX)
            let dy = abs(f.screenY - p.screenY)
            if dx < pr + fr && dy < pr + fr { return true }
        }
        return false
    }

    /// Returns IDs of enemies killed by sword
    func enemiesKilledBySword(player p: PlayerState, enemies: [EnemyModel]) -> Set<UUID> {
        guard p.isAttacking else { return [] }
        let swordLeft  = world.charScreenX + world.charSize * 0.38
        let swordRight = swordLeft + swordReach
        let swordTop   = p.screenY - world.charSize * 0.32
        let swordBottom = p.screenY + world.charSize * 0.32
        var killed = Set<UUID>()
        for e in enemies where !e.isDead {
            let screenX = e.worldX - (p.worldX - world.charScreenX)
            let es = world.charSize * 0.45
            let eLeft  = screenX - es
            let eRight = screenX + es
            let eTop   = world.screenY(norm: e.normY) - es
            let eBottom = world.screenY(norm: e.normY) + es
            let overlapX = eRight > swordLeft && eLeft < swordRight
            let overlapY = eBottom > swordTop && eTop < swordBottom
            if overlapX && overlapY { killed.insert(e.id) }
        }
        return killed
    }

    /// Returns IDs of fireballs killed by sword
    func fireballsDeflectedBySword(player p: PlayerState, fireballs: [FireballModel]) -> Set<UUID> {
        guard p.isAttacking else { return [] }
        let swordLeft   = world.charScreenX + world.charSize * 0.38
        let swordRight  = swordLeft + swordReach
        let swordTop    = p.screenY - world.charSize * 0.32
        let swordBottom = p.screenY + world.charSize * 0.32
        var deflected = Set<UUID>()
        for f in fireballs {
            let screenX = f.worldX - (p.worldX - world.charScreenX)
            if screenX > swordLeft && screenX < swordRight &&
               f.screenY > swordTop && f.screenY < swordBottom {
                deflected.insert(f.id)
            }
        }
        return deflected
    }

    /// Returns IDs of pickups collected
    func collectPickups(player p: PlayerState, pickups: [PickupModel], radiusMultiplier: CGFloat = 1.0) -> Set<UUID> {
        let pr: CGFloat = world.charSize * 0.55 * radiusMultiplier
        var collected = Set<UUID>()
        for pickup in pickups where !pickup.collected {
            let screenX = pickup.worldX - (p.worldX - world.charScreenX)
            let screenY = world.screenY(norm: pickup.normY)
            let dx = abs(screenX - world.charScreenX)
            let dy = abs(screenY - p.screenY)
            if dx < pr && dy < pr { collected.insert(pickup.id) }
        }
        return collected
    }

    /// Returns true if player reached the finish line
    func reachedFinish(player p: PlayerState, finishX: CGFloat) -> Bool {
        p.worldX >= finishX
    }

    /// Returns true if player fell off the map
    func playerFellOff(player p: PlayerState) -> Bool {
        p.screenY > world.height + 80
    }

    /// Returns updated checkpoint world X if player passed a new one
    func checkpointPassed(player p: PlayerState, checkpoints: [CGFloat]) -> CGFloat? {
        checkpoints.last { cp in cp <= p.worldX && cp > p.checkpointWorldX }
    }
}
