import CoreGraphics
import Foundation

// MARK: - Level Factory

enum LevelDefinitions {

    static func level(forArena id: Int) -> LevelData {
        switch id {
        case 1:  return arena1
        case 2:  return arena2
        case 3:  return arena3
        case 4:  return arena4
        case 5:  return arena5
        case 6:  return arena6
        case 7:  return arena7
        default: return arena1
        }
    }

    // MARK: - Helper builders

    private static func walker(x: CGFloat, left: CGFloat, right: CGFloat, speed: CGFloat = 90, normY: CGFloat = 0.97) -> EnemyModel {
        var e = EnemyModel(type: .walker, worldX: x, normY: normY)
        e.velocityX   = speed
        e.patrolLeft  = left
        e.patrolRight = right
        return e
    }

    private static func cannon(x: CGFloat, normY: CGFloat, interval: CGFloat = 3.0) -> EnemyModel {
        var e = EnemyModel(type: .cannon, worldX: x, normY: normY)
        e.fireInterval = interval
        e.fireTimer    = interval * 0.5   // offset so they don't all fire at once
        return e
    }

    private static func platform(_ x: CGFloat, _ normY: CGFloat, _ w: CGFloat) -> PlatformModel {
        PlatformModel(worldX: x, normY: normY, width: w)
    }

    private static func movingPlatform(_ x: CGFloat, _ normY: CGFloat, _ w: CGFloat, range: CGFloat, speed: CGFloat = 1.0) -> PlatformModel {
        PlatformModel(worldX: x, normY: normY, width: w, isMoving: true, moveRange: range, moveSpeed: speed)
    }

    private static func coin(_ x: CGFloat, _ normY: CGFloat = 0.90) -> PickupModel {
        PickupModel(worldX: x, normY: normY, kind: .coin)
    }

    private static func heart(_ x: CGFloat, _ normY: CGFloat = 0.90) -> PickupModel {
        PickupModel(worldX: x, normY: normY, kind: .heart)
    }

    // MARK: - Arena 1: Starter Meadow
    // Teaches bounce, double-jump rhythm and reward arcs with one big reveal jump.
    static let arena1 = LevelData(
        arenaId:    1,
        levelWidth: 4100,
        groundSegs: [
            .init(startX: 0,    endX: 760),
            .init(startX: 900,  endX: 1520),
            .init(startX: 1690, endX: 2280),
            .init(startX: 2460, endX: 3090),
            .init(startX: 3280, endX: 4100),
        ],
        platforms: [
            platform(1180, 0.70, 180),
            platform(1980, 0.63, 210),
            platform(2870, 0.58, 220),
            platform(3470, 0.68, 180),
        ],
        enemies: [],
        pickups: [
            coin(240), coin(360), coin(500), coin(640),
            coin(1010), coin(1130, 0.64), coin(1250, 0.60), coin(1370, 0.64),
            heart(1550, 0.84),
            coin(1820), coin(2060, 0.56), coin(2200, 0.52), coin(2340, 0.56),
            coin(2640), coin(2790), coin(2950, 0.50), coin(3110, 0.56),
            heart(3180, 0.84),
            coin(3380), coin(3510, 0.63), coin(3640, 0.60), coin(3770, 0.63),
            coin(3950),
        ],
        checkpoints: [1450, 3000],
        finishX: 3990
    )

    // MARK: - Arena 2: Misty Valley
    // Introduces split-path routing, ambush walkers and the first cannon finale.
    static let arena2 = LevelData(
        arenaId:    2,
        levelWidth: 5750,
        groundSegs: [
            .init(startX: 0,    endX: 620),
            .init(startX: 790,  endX: 1420),
            .init(startX: 1600, endX: 2180),
            .init(startX: 2350, endX: 2870),
            .init(startX: 3080, endX: 3600),
            .init(startX: 3790, endX: 4410),
            .init(startX: 4630, endX: 5150),
            .init(startX: 5340, endX: 5750),
        ],
        platforms: [
            platform(980, 0.73, 220),
            platform(1270, 0.60, 170),
            platform(2550, 0.72, 220),
            movingPlatform(3320, 0.62, 180, range: 90, speed: 0.9),
            platform(4060, 0.68, 190),
            platform(4860, 0.58, 180),
        ],
        enemies: [
            walker(x: 1100, left: 860,  right: 1400),
            walker(x: 2080, left: 1760, right: 2230),
            walker(x: 3450, left: 3150, right: 3650, speed: 100),
            walker(x: 4400, left: 4040, right: 4480, speed: 105),
            cannon(x: 5230, normY: 0.97, interval: 2.8),
        ],
        pickups: [
            coin(280), coin(430), coin(580),
            coin(880, 0.67), coin(1130, 0.55), coin(1360, 0.48),
            heart(1510, 0.84),
            coin(1760), coin(1970), coin(2170),
            coin(2550, 0.66), coin(2810, 0.63),
            heart(3020),
            coin(3330, 0.54), coin(3560, 0.60),
            coin(3900), coin(4130, 0.61), coin(4370),
            heart(4620, 0.82),
            coin(4890, 0.50), coin(5120), coin(5490),
        ],
        checkpoints: [1700, 3350, 5000],
        finishX: 5650
    )

    // MARK: - Arena 3: Crystal Caves
    // A vertical crystal chamber with artillery choke points and a late dramatic ascent.
    static let arena3 = LevelData(
        arenaId:    3,
        levelWidth: 7600,
        groundSegs: [
            .init(startX: 0,    endX: 520),
            .init(startX: 700,  endX: 1270),
            .init(startX: 1460, endX: 2010),
            .init(startX: 2210, endX: 2730),
            .init(startX: 2940, endX: 3520),
            .init(startX: 3740, endX: 4310),
            .init(startX: 4550, endX: 5090),
            .init(startX: 5320, endX: 5900),
            .init(startX: 6140, endX: 6760),
            .init(startX: 6990, endX: 7600),
        ],
        platforms: [
            platform(810,  0.71, 190),
            platform(1540, 0.57, 180),
            platform(2360, 0.66, 200),
            movingPlatform(3180, 0.55, 170, range: 110, speed: 0.95),
            platform(4020, 0.62, 200),
            platform(4860, 0.52, 190),
            movingPlatform(5660, 0.64, 170, range: 120, speed: 1.0),
            platform(6460, 0.56, 200),
        ],
        enemies: [
            walker(x: 860,  left: 730,  right: 1120, speed: 100),
            walker(x: 1830, left: 1550, right: 2050, speed: 110),
            walker(x: 3320, left: 3000, right: 3540, speed: 115),
            walker(x: 5090, left: 4700, right: 5220, speed: 115),
            walker(x: 6800, left: 6490, right: 7110, speed: 120),
            cannon(x: 2140, normY: 0.97, interval: 2.9),
            cannon(x: 4300, normY: 0.97, interval: 2.6),
            cannon(x: 6210, normY: 0.97, interval: 2.4),
        ],
        pickups: [
            coin(260), coin(430), coin(620),
            coin(850, 0.63), coin(1100),
            heart(1460, 0.81),
            coin(1590, 0.48), coin(1810, 0.54), coin(2050),
            coin(2400, 0.58), coin(2610, 0.63),
            heart(2940),
            coin(3200, 0.46), coin(3450, 0.53), coin(3700),
            coin(4040, 0.55), coin(4300), coin(4540),
            heart(4910, 0.78),
            coin(4870, 0.44), coin(5180), coin(5480), coin(5700, 0.57),
            heart(6060),
            coin(6470, 0.48), coin(6720, 0.52), coin(6980), coin(7310),
        ],
        checkpoints: [2100, 4550, 6350],
        finishX: 7480
    )

    // MARK: - Arena 4: Storm Heights
    // Moving platforms, 5 walkers, 3 cannons.
    static let arena4 = LevelData(
        arenaId:    4,
        levelWidth: 8500,
        groundSegs: [
            .init(startX: 0,    endX: 500),
            .init(startX: 690,  endX: 1200),
            .init(startX: 1400, endX: 2000),
            .init(startX: 2220, endX: 2800),
            .init(startX: 3050, endX: 3600),
            .init(startX: 3850, endX: 4500),
            .init(startX: 4750, endX: 5400),
            .init(startX: 5680, endX: 6300),
            .init(startX: 6560, endX: 7200),
            .init(startX: 7450, endX: 8500),
        ],
        platforms: [
            platform(700,  0.74, 210),
            platform(1600, 0.68, 200),
            movingPlatform(2500, 0.70, 200, range: 130, speed: 0.9),
            platform(3300, 0.65, 220),
            movingPlatform(4200, 0.68, 180, range: 100, speed: 1.1),
            platform(5100, 0.72, 210),
            movingPlatform(6000, 0.66, 200, range: 140, speed: 1.0),
            platform(6900, 0.70, 200),
        ],
        enemies: [
            walker(x: 900,  left: 750,  right: 1200),
            walker(x: 1800, left: 1600, right: 2100),
            walker(x: 3200, left: 3000, right: 3700),
            walker(x: 5000, left: 4850, right: 5500),
            walker(x: 6700, left: 6500, right: 7100),
            cannon(x: 2900, normY: 0.97, interval: 2.8),
            cannon(x: 4600, normY: 0.97, interval: 2.5),
            cannon(x: 7300, normY: 0.97, interval: 2.5),
        ],
        pickups: [
            coin(300), coin(600),
            coin(800, 0.66),
            coin(1300), coin(1700, 0.60),
            heart(1500),
            coin(2000), coin(2200),
            coin(2700, 0.62), coin(3100),
            heart(3400),
            coin(3800), coin(4200),
            coin(4600, 0.60),
            heart(5200),
            coin(5500), coin(5900),
            coin(6200, 0.58), coin(6600),
            heart(7000),
            coin(7500), coin(8000),
        ],
        checkpoints: [2000, 4500, 6500],
        finishX: 8400
    )

    // MARK: - Arena 5: Volcanic Peak
    // Faster enemies, fast cannons, complex layout.
    static let arena5 = LevelData(
        arenaId:    5,
        levelWidth: 10500,
        groundSegs: [
            .init(startX: 0,     endX: 450),
            .init(startX: 660,   endX: 1100),
            .init(startX: 1320,  endX: 1850),
            .init(startX: 2080,  endX: 2600),
            .init(startX: 2840,  endX: 3400),
            .init(startX: 3660,  endX: 4200),
            .init(startX: 4470,  endX: 5050),
            .init(startX: 5320,  endX: 5900),
            .init(startX: 6170,  endX: 6800),
            .init(startX: 7080,  endX: 7700),
            .init(startX: 7990,  endX: 8600),
            .init(startX: 8900,  endX: 9500),
            .init(startX: 9780,  endX: 10500),
        ],
        platforms: [
            platform(600,   0.74, 200),
            platform(1100,  0.66, 200),
            movingPlatform(1900, 0.68, 180, range: 120, speed: 1.3),
            platform(2700,  0.70, 200),
            movingPlatform(3500, 0.65, 180, range: 140, speed: 1.2),
            platform(4300,  0.68, 210),
            movingPlatform(5100, 0.66, 180, range: 130, speed: 1.4),
            platform(5950,  0.72, 200),
            movingPlatform(6900, 0.65, 190, range: 150, speed: 1.3),
            platform(7800,  0.70, 200),
            movingPlatform(8700, 0.67, 180, range: 120, speed: 1.5),
            platform(9600,  0.68, 200),
        ],
        enemies: [
            walker(x: 800,  left: 650,  right: 1050,  speed: 120),
            walker(x: 1500, left: 1320, right: 1850,  speed: 120),
            walker(x: 2400, left: 2200, right: 2700,  speed: 130),
            walker(x: 3200, left: 3000, right: 3500,  speed: 120),
            walker(x: 4600, left: 4450, right: 5000,  speed: 130),
            walker(x: 5700, left: 5500, right: 6000,  speed: 140),
            walker(x: 7200, left: 7000, right: 7700,  speed: 130),
            walker(x: 8500, left: 8300, right: 8800,  speed: 140),
            cannon(x: 1900, normY: 0.97, interval: 2.5),
            cannon(x: 3600, normY: 0.97, interval: 2.2),
            cannon(x: 5500, normY: 0.97, interval: 2.0),
            cannon(x: 7700, normY: 0.97, interval: 2.0),
            cannon(x: 9500, normY: 0.97, interval: 1.8),
        ],
        pickups: [
            coin(250), coin(500),
            coin(700, 0.66), coin(1000),
            heart(1200),
            coin(1400), coin(1700, 0.60),
            coin(2000), coin(2400), coin(2700),
            heart(2900),
            coin(3200), coin(3500),
            coin(3900, 0.60), coin(4200),
            heart(4600),
            coin(5000), coin(5300, 0.60),
            coin(5700), coin(6100),
            heart(6400),
            coin(6700), coin(7000),
            coin(7400, 0.62), coin(7800),
            heart(8200),
            coin(8600), coin(9000),
            coin(9400, 0.60), coin(9800),
        ],
        checkpoints: [2500, 5000, 7800],
        finishX: 10400
    )

    // MARK: - Arena 6: Neon Circuit
    // Very fast walkers, fast cannons, many moving platforms, dense layout.
    static let arena6 = LevelData(
        arenaId:    6,
        levelWidth: 13000,
        groundSegs: [
            .init(startX: 0,     endX: 400),
            .init(startX: 620,   endX: 1000),
            .init(startX: 1240,  endX: 1700),
            .init(startX: 1960,  endX: 2400),
            .init(startX: 2680,  endX: 3100),
            .init(startX: 3380,  endX: 3800),
            .init(startX: 4090,  endX: 4500),
            .init(startX: 4800,  endX: 5250),
            .init(startX: 5540,  endX: 6000),
            .init(startX: 6300,  endX: 6750),
            .init(startX: 7050,  endX: 7500),
            .init(startX: 7800,  endX: 8300),
            .init(startX: 8610,  endX: 9100),
            .init(startX: 9400,  endX: 9900),
            .init(startX: 10200, endX: 10700),
            .init(startX: 11000, endX: 11500),
            .init(startX: 11800, endX: 13000),
        ],
        platforms: [
            movingPlatform(600,   0.72, 180, range: 100, speed: 1.4),
            platform(1100,  0.65, 190),
            movingPlatform(1800, 0.68, 180, range: 120, speed: 1.5),
            platform(2550,  0.65, 190),
            movingPlatform(3200, 0.70, 170, range: 130, speed: 1.6),
            platform(3900,  0.65, 190),
            movingPlatform(4700, 0.68, 180, range: 110, speed: 1.5),
            platform(5400,  0.62, 190),
            movingPlatform(6150, 0.66, 180, range: 140, speed: 1.7),
            platform(6900,  0.63, 190),
            movingPlatform(7700, 0.67, 170, range: 130, speed: 1.6),
            platform(8500,  0.65, 190),
            movingPlatform(9300, 0.65, 180, range: 120, speed: 1.8),
            platform(10100, 0.62, 190),
            movingPlatform(10900, 0.66, 170, range: 140, speed: 1.7),
            platform(11700, 0.64, 190),
        ],
        enemies: [
            walker(x: 700,  left: 620,  right: 1050, speed: 150),
            walker(x: 1400, left: 1240, right: 1750, speed: 150),
            walker(x: 2100, left: 1960, right: 2450, speed: 160),
            walker(x: 2850, left: 2680, right: 3150, speed: 150),
            walker(x: 3550, left: 3380, right: 3850, speed: 160),
            walker(x: 4250, left: 4090, right: 4550, speed: 160),
            walker(x: 5000, left: 4800, right: 5300, speed: 170),
            walker(x: 5700, left: 5540, right: 6050, speed: 160),
            walker(x: 6450, left: 6300, right: 6800, speed: 170),
            walker(x: 7200, left: 7050, right: 7550, speed: 170),
            walker(x: 8000, left: 7800, right: 8350, speed: 180),
            walker(x: 9600, left: 9400, right: 9950, speed: 180),
            cannon(x: 1250,  normY: 0.97, interval: 2.2),
            cannon(x: 2500,  normY: 0.97, interval: 2.0),
            cannon(x: 4100,  normY: 0.97, interval: 1.8),
            cannon(x: 5750,  normY: 0.97, interval: 1.8),
            cannon(x: 7300,  normY: 0.97, interval: 1.7),
            cannon(x: 9100,  normY: 0.97, interval: 1.6),
            cannon(x: 10800, normY: 0.97, interval: 1.6),
            cannon(x: 12500, normY: 0.97, interval: 1.5),
        ],
        pickups: [
            coin(200), coin(400),
            coin(650, 0.64), coin(900),
            heart(1100),
            coin(1300), coin(1600, 0.57),
            coin(2000), coin(2300),
            heart(2600),
            coin(2900), coin(3200),
            coin(3550, 0.57),
            heart(3900),
            coin(4200), coin(4550),
            coin(4900, 0.60),
            heart(5300),
            coin(5600), coin(5900),
            coin(6250, 0.58),
            heart(6600),
            coin(7000), coin(7300),
            coin(7700, 0.59),
            heart(8100),
            coin(8700), coin(9200),
            coin(9600, 0.57),
            heart(10000),
            coin(10400), coin(10800),
            coin(11200, 0.58),
            heart(11600),
            coin(12000), coin(12500),
        ],
        checkpoints: [3000, 6000, 9500],
        finishX: 12900
    )

    // MARK: - Arena 7: Celestial Void
    // Maximum difficulty. Very few ground sections, mostly platform-based routing.
    static let arena7 = LevelData(
        arenaId:    7,
        levelWidth: 16000,
        groundSegs: [
            .init(startX: 0,     endX: 350),
            .init(startX: 580,   endX: 900),
            .init(startX: 1150,  endX: 1500),
            .init(startX: 1780,  endX: 2100),
            .init(startX: 2400,  endX: 2700),
            .init(startX: 3000,  endX: 3300),
            .init(startX: 3620,  endX: 3950),
            .init(startX: 4300,  endX: 4650),
            .init(startX: 5000,  endX: 5350),
            .init(startX: 5700,  endX: 6050),
            .init(startX: 6400,  endX: 6750),
            .init(startX: 7100,  endX: 7450),
            .init(startX: 7800,  endX: 8150),
            .init(startX: 8500,  endX: 8850),
            .init(startX: 9200,  endX: 9550),
            .init(startX: 9900,  endX: 10250),
            .init(startX: 10600, endX: 10950),
            .init(startX: 11300, endX: 11650),
            .init(startX: 12000, endX: 12350),
            .init(startX: 12700, endX: 13050),
            .init(startX: 13400, endX: 13750),
            .init(startX: 14100, endX: 14450),
            .init(startX: 14800, endX: 16000),
        ],
        platforms: [
            movingPlatform(700,   0.72, 160, range: 120, speed: 1.8),
            movingPlatform(1100,  0.65, 160, range: 140, speed: 2.0),
            movingPlatform(1650,  0.68, 160, range: 130, speed: 1.9),
            movingPlatform(2200,  0.64, 160, range: 150, speed: 2.0),
            movingPlatform(2800,  0.68, 160, range: 130, speed: 1.8),
            movingPlatform(3400,  0.65, 160, range: 140, speed: 2.1),
            movingPlatform(4000,  0.68, 160, range: 120, speed: 2.0),
            movingPlatform(4700,  0.64, 160, range: 150, speed: 2.2),
            movingPlatform(5400,  0.67, 160, range: 140, speed: 2.0),
            movingPlatform(6100,  0.64, 160, range: 150, speed: 2.1),
            movingPlatform(6800,  0.67, 160, range: 140, speed: 2.3),
            movingPlatform(7500,  0.63, 160, range: 160, speed: 2.2),
            movingPlatform(8200,  0.66, 160, range: 145, speed: 2.1),
            movingPlatform(8900,  0.63, 160, range: 155, speed: 2.3),
            movingPlatform(9600,  0.66, 155, range: 140, speed: 2.2),
            movingPlatform(10300, 0.63, 155, range: 160, speed: 2.4),
            movingPlatform(11000, 0.66, 155, range: 145, speed: 2.3),
            movingPlatform(11700, 0.63, 155, range: 155, speed: 2.4),
            movingPlatform(12400, 0.65, 155, range: 150, speed: 2.3),
            movingPlatform(13100, 0.63, 155, range: 160, speed: 2.5),
            movingPlatform(13800, 0.65, 155, range: 145, speed: 2.4),
            movingPlatform(14500, 0.63, 155, range: 155, speed: 2.5),
        ],
        enemies: [
            walker(x: 700,  left: 580,  right: 950,  speed: 190),
            walker(x: 1300, left: 1150, right: 1550, speed: 190),
            walker(x: 1950, left: 1780, right: 2150, speed: 200),
            walker(x: 2600, left: 2400, right: 2750, speed: 190),
            walker(x: 3200, left: 3000, right: 3350, speed: 200),
            walker(x: 3800, left: 3620, right: 4000, speed: 200),
            walker(x: 4500, left: 4300, right: 4700, speed: 210),
            walker(x: 5200, left: 5000, right: 5400, speed: 200),
            walker(x: 5900, left: 5700, right: 6100, speed: 210),
            walker(x: 6600, left: 6400, right: 6800, speed: 210),
            walker(x: 7300, left: 7100, right: 7500, speed: 220),
            walker(x: 8000, left: 7800, right: 8200, speed: 210),
            walker(x: 8700, left: 8500, right: 8900, speed: 220),
            walker(x: 9400, left: 9200, right: 9600, speed: 220),
            walker(x: 10100, left: 9900, right: 10300, speed: 230),
            walker(x: 11500, left: 11300, right: 11700, speed: 230),
            walker(x: 13200, left: 13000, right: 13400, speed: 240),
            walker(x: 14900, left: 14700, right: 15200, speed: 240),
            cannon(x: 1000,  normY: 0.97, interval: 2.0),
            cannon(x: 2300,  normY: 0.97, interval: 1.8),
            cannon(x: 3700,  normY: 0.97, interval: 1.7),
            cannon(x: 5100,  normY: 0.97, interval: 1.6),
            cannon(x: 6500,  normY: 0.97, interval: 1.5),
            cannon(x: 7900,  normY: 0.97, interval: 1.5),
            cannon(x: 9300,  normY: 0.97, interval: 1.4),
            cannon(x: 10700, normY: 0.97, interval: 1.4),
            cannon(x: 12100, normY: 0.97, interval: 1.3),
            cannon(x: 13500, normY: 0.97, interval: 1.3),
            cannon(x: 14900, normY: 0.97, interval: 1.2),
        ],
        pickups: (stride(from: 600.0, to: 16000.0, by: 600.0).map { x in
            x.truncatingRemainder(dividingBy: 2400) == 0
                ? heart(x, 0.85)
                : coin(x, 0.88)
        }),
        checkpoints: [3500, 7000, 10500, 14000],
        finishX: 15900
    )
}
