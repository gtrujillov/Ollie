import Foundation
import CoreGraphics
import SwiftUI
import UIKit

// MARK: - Game World

struct GameWorld {
    let width:  CGFloat
    let height: CGFloat

    var ceilingY:    CGFloat { height * 0.12 }
    var groundY:     CGFloat { height * 0.82 }   // top surface of ground
    var groundHeight: CGFloat { height - groundY }
    var playHeight:  CGFloat { groundY - ceilingY }
    var charSize:    CGFloat { min(width, height) * 0.082 }
    var charScreenX: CGFloat { width * 0.20 }    // player's fixed screen X

    /// Convert normY (0 = ceiling, 1 = ground surface) to screen Y
    func screenY(norm: CGFloat) -> CGFloat { ceilingY + norm * playHeight }

    init(width:  CGFloat = ScreenMetrics.bounds.width,
         height: CGFloat = ScreenMetrics.bounds.height) {
        self.width  = width
        self.height = height
    }
}

private enum ScreenMetrics {
    static var bounds: CGRect {
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.screen.bounds }
            .first ?? CGRect(x: 0, y: 0, width: 390, height: 844)
    }
}

// MARK: - Phases & Screens

enum GamePhase: Equatable { case idle, playing, levelComplete, dead }

enum AppScreen { case start, arenaSelect, gameplay, levelComplete, gameOver, shop }

// MARK: - Player

struct PlayerState {
    var worldX:         CGFloat = 300
    var screenY:        CGFloat = 0     // screen Y of center
    var vy:             CGFloat = 0     // positive = falling
    var isOnGround:     Bool    = false
    var isAttacking:    Bool    = false
    var attackTimer:    CGFloat = 0     // seconds remaining in attack
    var invincibleTimer: CGFloat = 0
    var runPhase:       CGFloat = 0     // 0…2π running animation
    var checkpointWorldX: CGFloat = 300
    var checkpointScreenY: CGFloat = 0  // set from world on spawn
    var flashVisible:   Bool    = true  // for invincibility flicker
    var coyoteTimer:    CGFloat = 0
    var jumpBufferTimer: CGFloat = 0
    var extraJumpsRemaining: Int = 1

    var isInvincible: Bool { invincibleTimer > 0 }
}

// MARK: - Platforms

struct PlatformModel: Identifiable {
    let id         = UUID()
    var worldX:    CGFloat    // left edge world X
    var normY:     CGFloat    // top surface normY (0=ceiling,1=ground)
    var width:     CGFloat
    var thickness: CGFloat    = 22
    var isMoving:  Bool       = false
    var moveRange: CGFloat    = 0     // world px amplitude
    var moveSpeed: CGFloat    = 1.2   // rad/s
    var movePhase: CGFloat    = 0

    var currentWorldX: CGFloat {
        isMoving ? worldX + sin(movePhase) * moveRange : worldX
    }
    var rightWorldX: CGFloat { currentWorldX + width }
}

// MARK: - Ground

struct GroundSegment {
    let startX: CGFloat
    let endX:   CGFloat
}

// MARK: - Enemies

enum EnemyType { case walker, cannon }

struct EnemyModel: Identifiable {
    let id   = UUID()
    let type: EnemyType
    var worldX:       CGFloat
    var normY:        CGFloat = 0.97   // vertical position
    var velocityX:    CGFloat = 90     // walker horizontal speed
    var patrolLeft:   CGFloat = 0
    var patrolRight:  CGFloat = 200
    var fireTimer:    CGFloat = 0
    var fireInterval: CGFloat = 3.0
    var isDead:       Bool    = false
    var deathTimer:   CGFloat = 0
}

// MARK: - Fireballs (cannon projectiles)

struct FireballModel: Identifiable {
    let id = UUID()
    var worldX:  CGFloat
    var screenY: CGFloat
    var speed:   CGFloat = 380         // always moves left (negative direction)
}

// MARK: - Pickups

struct PickupModel: Identifiable {
    enum Kind { case coin, heart }
    let id = UUID()
    var worldX:   CGFloat
    var normY:    CGFloat = 0.90
    let kind:     Kind
    var collected = false
}

// MARK: - Score

struct GameScore {
    var coinsEarned: Int = 0
    var coins:       Int = 0
}

// MARK: - Arenas

struct ArenaDefinition {
    let id:          Int
    let name:        String
    let emojiName:   String
    let accentColor: Color
    let bgColor:     Color
    let skyTop:      Color
    let skyBottom:   Color
    let glowColor:   Color
    let particleColor: Color
    let description: String
}

enum ArenaRegistry {
    static let all: [ArenaDefinition] = [
        .init(id:1, name:"Starter Meadow", emojiName:"leaf",            accentColor:Color(red:0.35,green:0.70,blue:0.35), bgColor:Color(red:0.87,green:0.96,blue:0.87), skyTop:Color(red:0.56,green:0.83,blue:0.96), skyBottom:Color(red:0.95,green:0.98,blue:0.82), glowColor:Color(red:0.98,green:0.92,blue:0.67), particleColor:Color(red:0.96,green:0.98,blue:0.88), description:"A lush opening sprint full of bounce and reward."),
        .init(id:2, name:"Misty Valley",   emojiName:"cloud.fog",       accentColor:Color(red:0.45,green:0.58,blue:0.82), bgColor:Color(red:0.84,green:0.90,blue:0.97), skyTop:Color(red:0.42,green:0.53,blue:0.76), skyBottom:Color(red:0.86,green:0.92,blue:0.99), glowColor:Color(red:0.82,green:0.91,blue:1.0), particleColor:Color.white.opacity(0.9), description:"Soft fog, risky split routes and ambush silhouettes."),
        .init(id:3, name:"Crystal Caves",  emojiName:"sparkles",        accentColor:Color(red:0.60,green:0.38,blue:0.92), bgColor:Color(red:0.91,green:0.85,blue:0.99), skyTop:Color(red:0.20,green:0.17,blue:0.36), skyBottom:Color(red:0.63,green:0.52,blue:0.86), glowColor:Color(red:0.76,green:0.62,blue:1.0), particleColor:Color(red:0.86,green:0.74,blue:1.0), description:"Crystal light, vertical routes and artillery drama."),
        .init(id:4, name:"Storm Heights",  emojiName:"bolt.fill",       accentColor:Color(red:0.88,green:0.70,blue:0.08), bgColor:Color(red:0.97,green:0.95,blue:0.80), skyTop:Color(red:0.29,green:0.35,blue:0.53), skyBottom:Color(red:0.92,green:0.88,blue:0.67), glowColor:Color(red:0.96,green:0.91,blue:0.52), particleColor:Color(red:0.98,green:0.98,blue:0.82), description:"Moving platforms cut through electric skies."),
        .init(id:5, name:"Volcanic Peak",  emojiName:"flame.fill",      accentColor:Color(red:0.92,green:0.28,blue:0.06), bgColor:Color(red:0.99,green:0.88,blue:0.80), skyTop:Color(red:0.35,green:0.14,blue:0.10), skyBottom:Color(red:0.99,green:0.50,blue:0.26), glowColor:Color(red:1.0,green:0.72,blue:0.36), particleColor:Color(red:1.0,green:0.84,blue:0.52), description:"Molten pressure with relentless tempo."),
        .init(id:6, name:"Neon Circuit",   emojiName:"cpu",             accentColor:Color(red:0.12,green:0.88,blue:0.65), bgColor:Color(red:0.80,green:0.97,blue:0.92), skyTop:Color(red:0.05,green:0.10,blue:0.22), skyBottom:Color(red:0.11,green:0.39,blue:0.34), glowColor:Color(red:0.22,green:1.0,blue:0.77), particleColor:Color(red:0.50,green:1.0,blue:0.91), description:"Laser-clean reads at outrageous speed."),
        .init(id:7, name:"Celestial Void", emojiName:"moon.stars.fill", accentColor:Color(red:0.50,green:0.38,blue:0.92), bgColor:Color(red:0.88,green:0.84,blue:0.99), skyTop:Color(red:0.04,green:0.05,blue:0.13), skyBottom:Color(red:0.24,green:0.18,blue:0.42), glowColor:Color(red:0.86,green:0.82,blue:1.0), particleColor:Color(red:0.93,green:0.92,blue:1.0), description:"A cosmic endurance run with no wasted motion."),
    ]

    static func definition(id: Int) -> ArenaDefinition? { all.first { $0.id == id } }
    static func arena(id: Int) -> ArenaDefinition { all.first { $0.id == id } ?? all[0] }
}

// MARK: - Level Data

struct LevelData {
    let arenaId:     Int
    let levelWidth:  CGFloat
    let groundSegs:  [GroundSegment]
    let platforms:   [PlatformModel]
    let enemies:     [EnemyModel]
    let pickups:     [PickupModel]
    let checkpoints: [CGFloat]          // world X positions
    let finishX:     CGFloat
}

// MARK: - In-game ring effect (reused from old game for sword hit)

struct RingModel: Identifiable {
    let id   = UUID()
    let x:   CGFloat
    let y:   CGFloat
    let born = Date()
}
