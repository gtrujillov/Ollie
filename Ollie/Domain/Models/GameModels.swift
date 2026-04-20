import Foundation
import CoreGraphics
import UIKit

// MARK: - Game World

struct GameWorld {
    let width: CGFloat
    let height: CGFloat

    var groundHeight: CGFloat  { height * 0.160 }
    var ceilingHeight: CGFloat { height * 0.126 }
    var charX: CGFloat         { width  * 0.274 }
    var charSize: CGFloat      { width  * 0.174 }
    var obstacleWidth: CGFloat { width  * 0.169 }
    var centerY: CGFloat       { (height - groundHeight - ceilingHeight) / 2 + ceilingHeight }

    init(
        width:  CGFloat = UIScreen.main.bounds.width,
        height: CGFloat = UIScreen.main.bounds.height
    ) {
        self.width  = width
        self.height = height
    }
}

// MARK: - Game Phase

enum GamePhase: Equatable {
    case idle, playing, dead
}

// MARK: - App Screen

enum AppScreen {
    case start, gameplay, gameOver, shop
}

// MARK: - Ollie Physics

struct OlliePhysics {
    var y:         CGFloat = 0
    var vy:        CGFloat = 0
    var rotation:  CGFloat = 0
    var wingPhase: CGFloat = 0
}

// MARK: - Obstacle

struct ObstacleModel: Identifiable {
    let id       = UUID()
    var x:       CGFloat
    var gapY:    CGFloat        // mutable – oscillating obstacles update this each frame
    let gapH:    CGFloat
    var baseGapY: CGFloat       // oscillation centre
    var oscillating: Bool = false
    var oscPhase: CGFloat = 0   // current sine phase
    var scored   = false

    init(x: CGFloat, gapY: CGFloat, gapH: CGFloat) {
        self.x       = x
        self.gapY    = gapY
        self.gapH    = gapH
        self.baseGapY = gapY
    }
}

// MARK: - Pickup

struct PickupModel: Identifiable {
    enum Kind { case coin, shield }

    let id        = UUID()
    var x:        CGFloat
    let y:        CGFloat
    let kind:     Kind
    var collected = false

    init(x: CGFloat, y: CGFloat, kind: Kind = .coin) {
        self.x    = x
        self.y    = y
        self.kind = kind
    }
}

// MARK: - Popup

// MARK: - Projectile (Eye Beam)

struct ProjectileModel: Identifiable {
    let id   = UUID()
    var x:   CGFloat
    let y:   CGFloat
    let born = Date()

    init(x: CGFloat, y: CGFloat) {
        self.x = x
        self.y = y
    }
}

// MARK: - Popup

struct PopupModel: Identifiable {
    enum Kind { case coin, closeCall, shield, speedUp, beam }

    let id   = UUID()
    let text: String
    let x:    CGFloat
    let y:    CGFloat
    let kind: Kind
    let born = Date()

    init(text: String, x: CGFloat, y: CGFloat, kind: Kind) {
        self.text = text
        self.x    = x
        self.y    = y
        self.kind = kind
    }
}

// MARK: - Ring Effect

struct RingModel: Identifiable {
    let id   = UUID()
    let x:   CGFloat
    let y:   CGFloat
    let born = Date()

    init(x: CGFloat, y: CGFloat) {
        self.x = x
        self.y = y
    }
}

// MARK: - Score

struct GameScore {
    var current:     Int = 0
    var best:        Int = 0
    var coins:       Int = 0
    var coinsEarned: Int = 0
}
