import Foundation

struct PaceCalculator {

    /// Format seconds-per-km as "X:XX /km"
    static func formatPace(_ secondsPerKm: TimeInterval) -> String {
        guard secondsPerKm.isFinite, secondsPerKm > 0 else { return "-:-- /km" }
        let totalSeconds = Int(secondsPerKm)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d /km", minutes, seconds)
    }

    /// Format duration as "M:SS" or "H:MM:SS"
    static func formatDuration(_ seconds: TimeInterval) -> String {
        let totalSeconds = Int(seconds)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let secs = totalSeconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%d:%02d", minutes, secs)
        }
    }

    /// Calculate pace from distance (meters) and duration (seconds)
    static func pacePerKm(distance: Double, duration: TimeInterval) -> TimeInterval {
        guard distance > 0 else { return 0 }
        return duration / (distance / 1000.0)
    }
}
