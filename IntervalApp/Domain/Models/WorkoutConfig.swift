import Foundation

enum IntervalDistance: String, CaseIterable {
    case fourHundred = "400m"
    case eightHundred = "800m"

    var meters: Double {
        switch self {
        case .fourHundred: return 400.0
        case .eightHundred: return 800.0
        }
    }
}

struct WorkoutConfig {
    let distance: IntervalDistance
    let repCount: Int
    let recoverySeconds: Int

    init(distance: IntervalDistance, repCount: Int, recoverySeconds: Int = 180) {
        self.distance = distance
        self.repCount = max(1, min(repCount, 8))
        self.recoverySeconds = recoverySeconds
    }
}
