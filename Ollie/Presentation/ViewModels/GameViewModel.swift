import SwiftUI
import Foundation
internal import Combine

final class GameViewModel: ObservableObject {

    // MARK: - Published state

    @Published var phase:        GamePhase       = .idle
    @Published var ollie         = OlliePhysics()
    @Published var obstacles:    [ObstacleModel] = []
    @Published var pickups:      [PickupModel]   = []
    @Published var popups:       [PopupModel]    = []
    @Published var rings:        [RingModel]     = []
    @Published var score         = GameScore()
    @Published var blinkMeter:   CGFloat = 1.0
    @Published var isBlinking    = false
    @Published var flashActive   = false
    @Published var combo         = 0
    @Published var shielded      = false
    @Published var dangerLevel:  CGFloat = 0
    @Published var speedTier:    Int     = 0
    @Published var projectiles:  [ProjectileModel] = []
    @Published var beamCharge:   CGFloat = 0
    @Published var streak:       Int             = 0

    // MARK: - Dependencies

    let world:     GameWorld
    private let useCase:       GameUseCase
    private let scoreRepo:     ScoreRepositoryProtocol
    private let shopRepo:      ShopRepositoryProtocol
    private let shopCase =     ShopUseCase()
    @Published var inventory:  PlayerInventory = PlayerInventory()

    // MARK: - Private loop state

    private var loopDriver:        DisplayLinkDriver?
    private var lastTS:            CFTimeInterval = 0
    private var spawnTimer:        Double         = 1.0
    private var pendingDoubleSecs: Double         = 0
    private var spawnCount:        Int            = 0
    private var isHolding          = false
    private var shieldHitsLeft:    Int            = 1

    // MARK: - Init

    init(
        world:      GameWorld               = GameWorld(),
        difficulty: CGFloat                 = 1.0,
        scoreRepo:  ScoreRepositoryProtocol = UserDefaultsScoreRepository(),
        shopRepo:   ShopRepositoryProtocol  = UserDefaultsShopRepository()
    ) {
        self.world     = world
        self.useCase   = GameUseCase(world: world, difficulty: difficulty)
        self.scoreRepo = scoreRepo
        self.shopRepo  = shopRepo
        score.best     = scoreRepo.getBestScore()
        score.coins    = scoreRepo.getCoins()
        streak         = scoreRepo.getStreak()
        self.inventory = shopRepo.getInventory()
    }

    // MARK: - Computed helpers

    var absY: CGFloat { world.centerY + ollie.y }

    var scoreMultiplier: Int {
        if combo >= 6 { return 3 }
        if combo >= 3 { return 2 }
        return 1
    }

    var selectedOllieColor:      Color { shopCase.ollieColor(for: inventory) }
    var selectedBackgroundColor: Color { shopCase.backgroundColor(for: inventory) }
    var selectedLashColor:       Color { shopCase.lashColor(for: inventory) }

    var beamReady: Bool { beamCharge >= 1.0 && projectiles.isEmpty }

    private var startsWithShield: Bool { inventory.activeUpgrades.contains("pw_iron") }
    private var shieldMaxHits:    Int  { inventory.activeUpgrades.contains("pw_rookie") ? 2 : 1 }
    private var hasCoinMagnet:    Bool { inventory.activeUpgrades.contains("pw_magnet") }
    private var hasDaredevil:     Bool { inventory.activeUpgrades.contains("pw_daredevil") }

    func refreshInventory() {
        inventory   = shopRepo.getInventory()
        score.coins = scoreRepo.getCoins()
        streak      = scoreRepo.getStreak()
    }

    // MARK: - Public interface

    func onTap() {
        guard phase != .dead else { return }
        if phase == .idle {
            phase = .playing
            doFlap()
            return
        }
        doFlap()
    }

    func onBeamTap() {
        guard phase == .playing && beamReady else { return }
        fireBeam()
    }

    func holdBegan() { isHolding = true  }
    func holdEnded() { isHolding = false }

    func startLoop() {
        lastTS     = 0
        spawnTimer = 1.0
        loopDriver = DisplayLinkDriver { [weak self] ts in self?.tick(ts) }
    }

    func stopLoop() { loopDriver = nil }

    func prepareForReplay() {
        refreshInventory()
        phase      = .idle
        ollie      = OlliePhysics()
        obstacles  = []
        pickups    = []
        popups     = []
        rings      = []
        score.current     = 0
        score.coinsEarned = 0
        combo      = 0
        blinkMeter = 1.0
        isBlinking = false
        shielded   = startsWithShield
        shieldHitsLeft = shieldMaxHits
        dangerLevel = 0
        speedTier  = 0
        isHolding  = false
        spawnTimer = 1.0
        spawnCount = 0
        pendingDoubleSecs = 0
        lastTS      = 0
        projectiles = []
        beamCharge  = 0
    }

    // MARK: - Game loop

    private func tick(_ ts: CFTimeInterval) {
        guard lastTS != 0 else { lastTS = ts; return }
        let dt = CGFloat(min(0.04, ts - lastTS))
        lastTS = ts

        switch phase {
        case .dead:    break
        case .idle:    animateIdle(t: ts, dt: dt)
        case .playing: simulateStep(dt: dt)
        }
    }

    private func animateIdle(t: CFTimeInterval, dt: CGFloat) {
        ollie.y         = sin(t / 0.4) * 18 * world.height / 874
        ollie.rotation  = sin(t / 0.4) * 6
        ollie.wingPhase += dt * 8
    }

    private func simulateStep(dt: CGFloat) {
        // ── Blink ──────────────────────────────────────────────────
        let canBlink = isHolding && blinkMeter > 0.02
        isBlinking = canBlink
        blinkMeter = canBlink
            ? max(0,  blinkMeter - dt * useCase.blinkDrainRate)
            : min(1,  blinkMeter + dt * useCase.blinkRechargeRate)

        let timeScale: CGFloat = isBlinking ? useCase.blinkTimeScale : 1.0
        let sdt = dt * timeScale

        // ── Beam charge (real-time, unaffected by blink slow-mo) ──
        if beamCharge < 1.0 {
            beamCharge = min(1.0, beamCharge + dt * useCase.beamChargeRate)
        }

        // ── Progressive speed ──────────────────────────────────────
        let speedMul = useCase.speedMultiplier(score: score.current)
        let moveSdt  = sdt * speedMul
        let newTier  = Int((speedMul - 1.0) / 0.07)
        if newTier > speedTier {
            speedTier = newTier
            addPopup(String(localized: "SPEED UP!"), x: world.charX, y: absY - 50, kind: .speedUp)
        }

        // ── Physics ────────────────────────────────────────────────
        ollie = useCase.applyPhysics(ollie, dt: dt, timeScale: timeScale)
        let y = absY

        if useCase.isOutOfBounds(absY: y) { die(); return }

        // ── Oscillating obstacles ──────────────────────────────────
        var newObs = useCase.updateOscillation(
            useCase.moveObstacles(obstacles, sdt: moveSdt),
            sdt: sdt
        )

        // ── Score + close-calls ────────────────────────────────────
        for i in newObs.indices where !newObs[i].scored && useCase.hasPassed(newObs[i]) {
            newObs[i].scored = true
            let mult = scoreMultiplier
            score.current += 1 * mult

            if useCase.isCloseCall(absY: y, o: newObs[i], bonusFactor: hasDaredevil ? 0.25 : 0) {
                combo         += 1
                score.current += useCase.closeCallScoreBonus * mult
                blinkMeter      = min(1, blinkMeter + useCase.closeCallBlinkBonus)
                addPopup(String(localized: "CLOSE CALL +BLINK"), x: world.charX, y: y - 30, kind: .closeCall)
            } else {
                combo = 0
            }
        }

        // ── Eye Beam projectiles (before collision) ────────────────
        var newProj     = useCase.moveProjectiles(projectiles, sdt: sdt)
        var consumed    = Set<UUID>()
        var obsToRemove = IndexSet()
        for proj in newProj where !consumed.contains(proj.id) {
            for i in newObs.indices where !obsToRemove.contains(i) {
                if useCase.collidesWithProjectile(proj, obstacle: newObs[i]) {
                    addExplosion(x: newObs[i].x + world.obstacleWidth / 2,
                                 y: newObs[i].gapY + newObs[i].gapH / 2)
                    obsToRemove.insert(i)
                    consumed.insert(proj.id)
                    break
                }
            }
        }
        newObs.remove(atOffsets: obsToRemove)
        newProj    = newProj.filter { !consumed.contains($0.id) }
        projectiles = newProj

        // ── Collision ──────────────────────────────────────────────
        for o in newObs where useCase.collides(absY: y, with: o) { die(); return }

        obstacles = newObs

        // ── Pickups ────────────────────────────────────────────────
        var newPickups = useCase.movePickups(pickups, sdt: moveSdt)
        for i in newPickups.indices where !newPickups[i].collected {
            if useCase.collidesWithPickup(absY: y, pickup: newPickups[i], magnetBonus: hasCoinMagnet ? 22 : 0) {
                newPickups[i].collected = true
                switch newPickups[i].kind {
                case .coin:
                    score.coinsEarned += 1
                    addPopup("+1", x: newPickups[i].x, y: newPickups[i].y - 16, kind: .coin)
                case .shield:
                    shielded       = true
                    shieldHitsLeft = shieldMaxHits
                    addPopup(String(localized: "SHIELD!"), x: newPickups[i].x, y: newPickups[i].y - 20, kind: .shield)
                }
            }
        }
        pickups = newPickups.filter { !$0.collected }

        // ── Danger feedback ────────────────────────────────────────
        dangerLevel = useCase.dangerLevel(absY: y, obstacles: newObs)

        // ── Primary spawn ──────────────────────────────────────────
        spawnTimer -= Double(moveSdt)
        if spawnTimer <= 0 {
            spawnCount += 1
            spawnOne()
            spawnTimer = useCase.spawnInterval(score: score.current)

            if spawnCount % 4 == 0 {
                pendingDoubleSecs = useCase.spawnInterval(score: score.current) * 0.45
            }
        }

        // ── Pending double spawn ───────────────────────────────────
        if pendingDoubleSecs > 0 {
            pendingDoubleSecs -= Double(moveSdt)
            if pendingDoubleSecs <= 0 {
                pendingDoubleSecs = 0
                spawnOne()
            }
        }

        // ── Cleanup timed effects ──────────────────────────────────
        let now = Date()
        popups = popups.filter { now.timeIntervalSince($0.born) < 0.9 }
        rings  = rings.filter  { now.timeIntervalSince($0.born) < 0.45 }
    }

    // MARK: - Helpers

    private func spawnOne() {
        let (obs, newPickups) = useCase.spawnObstacle(score: score.current)
        obstacles.append(obs)
        pickups.append(contentsOf: newPickups)
    }

    private func doFlap() {
        ollie.vy        = useCase.jumpVelocityValue()
        ollie.wingPhase += .pi
        spawnRing()
    }

    private func fireBeam() {
        beamCharge = 0
        let proj   = ProjectileModel(x: world.charX + world.charSize, y: absY)
        projectiles.append(proj)
        addPopup(String(localized: "EYE BEAM!"), x: world.charX, y: absY - 50, kind: .beam)
        spawnRing()
    }

    private func addExplosion(x: CGFloat, y: CGFloat) {
        for offset: CGFloat in [-30, 0, 30] {
            let ring = RingModel(x: x, y: y + offset)
            rings.append(ring)
            let rid = ring.id
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                self.rings.removeAll { $0.id == rid }
            }
        }
        score.current += 2 * scoreMultiplier
        addPopup(String(format: String(localized: "SMASH! +%lld"), 2 * scoreMultiplier), x: x - 30, y: y - 44, kind: .beam)
    }

    private func die() {
        if shielded {
            shieldHitsLeft -= 1
            if shieldHitsLeft > 0 {
                flashActive = true
                addPopup(String(localized: "SHIELD HIT"), x: world.charX, y: absY - 30, kind: .shield)
            } else {
                shielded    = false
                flashActive = true
                addPopup(String(localized: "SHIELD BREAK"), x: world.charX, y: absY - 30, kind: .shield)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) { self.flashActive = false }
            return
        }
        phase = .dead
        flashActive = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) { self.flashActive = false }
        if score.current > score.best {
            score.best = score.current
            scoreRepo.saveBestScore(score.current)
        }
        score.coins += score.coinsEarned
        scoreRepo.saveCoins(score.coins)
        updateStreak()
    }

    private func updateStreak() {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let today = df.string(from: Date())
        let last  = scoreRepo.getLastPlayedDate()

        if let last {
            let yesterday = df.string(
                from: Calendar.current.date(byAdding: .day, value: -1, to: Date())!
            )
            if last == today {
                // already counted today
            } else if last == yesterday {
                streak += 1
            } else {
                streak = 1
            }
        } else {
            streak = 1
        }
        scoreRepo.saveStreak(streak)
        scoreRepo.saveLastPlayedDate(today)
    }

    private func spawnRing() {
        let ring = RingModel(x: world.charX + world.charSize / 2, y: absY)
        rings.append(ring)
        let rid = ring.id
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            self.rings.removeAll { $0.id == rid }
        }
    }

    private func addPopup(_ text: String, x: CGFloat, y: CGFloat, kind: PopupModel.Kind) {
        let p = PopupModel(text: text, x: x, y: y, kind: kind)
        popups.append(p)
        let pid = p.id
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            self.popups.removeAll { $0.id == pid }
        }
    }
}

// MARK: - CADisplayLink Driver

private final class DisplayLinkDriver: NSObject {
    private var link:    CADisplayLink?
    private let handler: (CFTimeInterval) -> Void

    init(handler: @escaping (CFTimeInterval) -> Void) {
        self.handler = handler
        super.init()
        link = CADisplayLink(target: self, selector: #selector(tick(_:)))
        link?.add(to: .main, forMode: .common)
    }

    deinit { link?.invalidate() }

    @objc private func tick(_ l: CADisplayLink) { handler(l.timestamp) }
}
