import SwiftUI
import Foundation
internal import Combine

final class GameViewModel: ObservableObject {

    // MARK: - Published state

    @Published var phase:       GamePhase = .idle
    @Published var player       = PlayerState()
    @Published var platforms:   [PlatformModel] = []
    @Published var groundSegs:  [GroundSegment] = []
    @Published var enemies:     [EnemyModel]    = []
    @Published var fireballs:   [FireballModel] = []
    @Published var pickups:     [PickupModel]   = []
    @Published var rings:       [RingModel]     = []
    @Published var hearts:      Int             = 3
    @Published var score:       GameScore       = GameScore()
    @Published var cameraX:     CGFloat         = 0
    @Published var arenaId:     Int             = 1
    @Published var finishX:     CGFloat         = 3500
    @Published var levelWidth:  CGFloat         = 3600
    @Published var highestArena: Int            = 1
    @Published var flashActive: Bool            = false
    @Published var shieldCharges: Int           = 0
    @Published var bannerText: String?          = nil
    @Published var bannerAccent: Color          = .ollie_coral
    @Published var tutorialEnabled: Bool        = true

    // MARK: - Dependencies

    let world:      GameWorld
    private let useCase:    GameUseCase
    private let scoreRepo:  ScoreRepositoryProtocol
    private let shopRepo:   ShopRepositoryProtocol
    private let shopCase =  ShopUseCase()
    @Published var inventory: PlayerInventory = PlayerInventory()

    // MARK: - Private state

    private var loopDriver:  DisplayLinkDriver?
    private var lastTS:      CFTimeInterval = 0
    private var checkpoints: [CGFloat]      = []
    private var passedCheckpoints = Set<CGFloat>()

    // MARK: - Init

    init(
        world:     GameWorld               = GameWorld(),
        scoreRepo: ScoreRepositoryProtocol = UserDefaultsScoreRepository(),
        shopRepo:  ShopRepositoryProtocol  = UserDefaultsShopRepository()
    ) {
        self.world     = world
        self.useCase   = GameUseCase(world: world)
        self.scoreRepo = scoreRepo
        self.shopRepo  = shopRepo
        highestArena   = scoreRepo.getHighestArenaUnlocked()
        score.coins    = scoreRepo.getCoins()
        inventory      = shopRepo.getInventory()
    }

    // MARK: - Computed

    var selectedOllieColor:      Color { shopCase.ollieColor(for: inventory) }
    var selectedBackgroundColor: Color {
        ArenaRegistry.definition(id: arenaId)?.bgColor ?? Color.ollie_cream
    }
    var selectedLashColor: Color { shopCase.lashColor(for: inventory) }
    var currentArena: ArenaDefinition { ArenaRegistry.arena(id: arenaId) }

    // MARK: - Public API

    func refreshInventory() {
        inventory   = shopRepo.getInventory()
        score.coins = scoreRepo.getCoins()
        highestArena = scoreRepo.getHighestArenaUnlocked()
        shieldCharges = startingShieldCharges()
    }

    func loadArena(_ id: Int) {
        arenaId = id
        let levelData  = LevelDefinitions.level(forArena: id)
        groundSegs     = levelData.groundSegs
        platforms      = levelData.platforms
        enemies        = levelData.enemies
        pickups        = levelData.pickups
        checkpoints    = levelData.checkpoints
        finishX        = levelData.finishX
        levelWidth     = levelData.levelWidth
        hearts         = 3
        score.coinsEarned = 0
        fireballs      = []
        rings          = []
        cameraX        = 0
        flashActive    = false
        shieldCharges  = startingShieldCharges()
        passedCheckpoints = []
        tutorialEnabled = id == 1

        let startScreenY = world.groundY - world.charSize * 0.5
        player = PlayerState(
            worldX:          300,
            screenY:         startScreenY,
            checkpointWorldX: 300,
            checkpointScreenY: startScreenY,
            extraJumpsRemaining: 1
        )
        showBanner("\(currentArena.name) • \(currentArena.description)", accent: currentArena.accentColor, duration: 2.0)
        phase = .idle
    }

    func startPlay() {
        guard phase == .idle else { return }
        phase = .playing
        tutorialEnabled = false
    }

    func onJump() {
        guard phase == .playing else { return }
        player = useCase.jump(player)
    }

    func onAttack() {
        guard phase == .playing else { return }
        player = useCase.attack(player)
        if player.isAttacking { spawnRingAt(player.screenY) }
    }

    func startLoop() {
        lastTS = 0
        loopDriver = DisplayLinkDriver { [weak self] ts in self?.tick(ts) }
    }

    func stopLoop() { loopDriver = nil }

    // MARK: - Game loop

    private func tick(_ ts: CFTimeInterval) {
        guard lastTS != 0 else { lastTS = ts; return }
        let dt = CGFloat(min(0.04, ts - lastTS))
        lastTS = ts

        switch phase {
        case .idle:    idleTick(dt: dt)
        case .playing: simulateTick(dt: dt)
        default:       break
        }
    }

    private func idleTick(dt: CGFloat) {
        // Gentle bob while idle (waiting to start)
        player.screenY = world.groundY - world.charSize * 0.5 + sin(lastTS) * 4
        player.runPhase += dt * 6
    }

    private func simulateTick(dt: CGFloat) {
        // ── Physics ──────────────────────────────────────────────────
        var p = useCase.applyGravity(to: player, dt: dt)

        // Update camera
        cameraX = max(0, min(p.worldX - world.charScreenX, levelWidth - world.width))

        // Ground & platform collision
        p = useCase.resolveGround(player: p, groundSegs: groundSegs)
        p = useCase.resolvePlatforms(player: p, platforms: platforms)
        p = useCase.consumeBufferedJumpIfPossible(p)

        // ── Fell off ─────────────────────────────────────────────────
        if useCase.playerFellOff(player: p) {
            takeDamage(player: &p, respawn: true)
        }

        // ── Checkpoint ───────────────────────────────────────────────
        if let newCP = useCase.checkpointPassed(player: p, checkpoints: checkpoints) {
            p.checkpointWorldX  = newCP
            p.checkpointScreenY = world.groundY - world.charSize * 0.5
            if !passedCheckpoints.contains(newCP) {
                passedCheckpoints.insert(newCP)
                showBanner("Checkpoint secured", accent: currentArena.accentColor)
            }
        }

        // ── Moving platforms ─────────────────────────────────────────
        platforms = useCase.updateMovingPlatforms(platforms, dt: dt)

        // ── Enemies ──────────────────────────────────────────────────
        enemies = useCase.updateEnemies(enemies, dt: dt)
        enemies.removeAll { $0.isDead && $0.deathTimer > 0.6 }

        let newFireballs = useCase.spawnFireballs(from: enemies)
        enemies = useCase.consumeFireballTimers(enemies)
        fireballs.append(contentsOf: newFireballs)
        fireballs = useCase.moveFireballs(fireballs, dt: dt, cameraX: cameraX)

        // ── Sword hits ───────────────────────────────────────────────
        let killed = useCase.enemiesKilledBySword(player: p, enemies: enemies)
        if !killed.isEmpty {
            for i in enemies.indices where killed.contains(enemies[i].id) {
                enemies[i].isDead = true
                spawnRingAt(world.screenY(norm: enemies[i].normY))
            }
            score.coinsEarned += killed.count
        }

        let deflected = useCase.fireballsDeflectedBySword(player: p, fireballs: fireballs)
        fireballs.removeAll { deflected.contains($0.id) }

        // ── Damage from enemies ──────────────────────────────────────
        if useCase.playerHitByEnemy(player: p, enemies: enemies) {
            takeDamage(player: &p, respawn: false)
        } else if useCase.playerHitByFireball(player: p, fireballs: fireballs) {
            fireballs.removeAll { useCase.playerHitByFireball(player: p, fireballs: [$0]) }
            takeDamage(player: &p, respawn: false)
        }

        // ── Pickups ──────────────────────────────────────────────────
        let collected = useCase.collectPickups(
            player: p,
            pickups: pickups,
            radiusMultiplier: inventory.activeUpgrades.contains("pw_magnet") ? 1.55 : 1.0
        )
        for i in pickups.indices where collected.contains(pickups[i].id) {
            pickups[i].collected = true
            switch pickups[i].kind {
            case .coin:
                score.coinsEarned += 1
            case .heart:
                hearts = min(3, hearts + 1)
                showBanner("Heart recovered", accent: .red, duration: 1.1)
            }
        }
        pickups.removeAll { $0.collected }

        // ── Finish line ──────────────────────────────────────────────
        if useCase.reachedFinish(player: p, finishX: finishX) {
            winLevel()
        }

        // ── Cleanup ──────────────────────────────────────────────────
        let now = Date()
        rings = rings.filter { now.timeIntervalSince($0.born) < 0.45 }

        player = p
    }

    // MARK: - Helpers

    private func takeDamage(player p: inout PlayerState, respawn: Bool) {
        guard !p.isInvincible else { return }

        if shieldCharges > 0 {
            shieldCharges -= 1
            p = useCase.applyInvincibility(p)
            flashActive = true
            showBanner("Shield absorbed the hit", accent: .ollie_sky, duration: 1.0)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { self.flashActive = false }
            return
        }

        hearts -= 1
        flashActive = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) { self.flashActive = false }

        if hearts <= 0 {
            phase = .dead
            return
        }

        p = useCase.applyInvincibility(p)
        if respawn {
            p.worldX  = p.checkpointWorldX
            p.screenY = p.checkpointScreenY
            p.vy      = 0
            p.isOnGround = true
            p.extraJumpsRemaining = 1
        }
    }

    private func winLevel() {
        phase = .levelComplete
        score.coins += score.coinsEarned
        scoreRepo.saveCoins(score.coins)
        if arenaId + 1 > highestArena && arenaId < 7 {
            highestArena = arenaId + 1
            scoreRepo.saveHighestArenaUnlocked(highestArena)
        }
    }

    private func spawnRingAt(_ y: CGFloat) {
        let r = RingModel(x: world.charScreenX, y: y)
        rings.append(r)
        let rid = r.id
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            self.rings.removeAll { $0.id == rid }
        }
    }

    private func startingShieldCharges() -> Int {
        if inventory.activeUpgrades.contains("pw_rookie") { return 2 }
        if inventory.activeUpgrades.contains("pw_iron") { return 1 }
        return 0
    }

    private func showBanner(_ text: String, accent: Color, duration: TimeInterval = 1.4) {
        bannerText = text
        bannerAccent = accent
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            if self.bannerText == text {
                self.bannerText = nil
            }
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
