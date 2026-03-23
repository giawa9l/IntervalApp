import Foundation

struct WorkoutSummary {
    let config: WorkoutConfig
    let reps: [RepResult]
    let totalDuration: TimeInterval

    var totalDistance: Double {
        reps.reduce(0) { $0 + $1.distance }
    }

    var averagePace: TimeInterval {
        let total = totalDistance
        guard total > 0 else { return 0 }
        let totalRepDuration = reps.reduce(0) { $0 + $1.duration }
        return totalRepDuration / (total / 1000.0)
    }

    var fastestRep: RepResult? {
        reps.min(by: { $0.pacePerKm < $1.pacePerKm })
    }

    var slowestRep: RepResult? {
        reps.max(by: { $0.pacePerKm < $1.pacePerKm })
    }
}
