import Foundation

struct RepResult: Identifiable {
    let id: Int
    let distance: Double
    let duration: TimeInterval

    var pacePerKm: TimeInterval {
        guard distance > 0 else { return 0 }
        return duration / (distance / 1000.0)
    }
}
