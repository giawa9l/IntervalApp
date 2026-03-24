import SwiftUI

final class SummaryViewModel: ObservableObject {
    let summary: WorkoutSummary

    init(summary: WorkoutSummary) {
        self.summary = summary
    }

    // MARK: - Header

    var workoutLabel: String {
        "\(summary.config.distance.rawValue) × \(summary.config.repCount)"
    }

    var formattedAveragePace: String {
        PaceCalculator.formatPace(summary.averagePace)
    }

    var formattedTotalTime: String {
        PaceCalculator.formatDuration(summary.totalDuration)
    }

    var formattedTotalDistance: String {
        let km = summary.totalDistance / 1000.0
        if km >= 1.0 {
            return String(format: "%.1fkm", km)
        }
        return String(format: "%.0fm", summary.totalDistance)
    }

    // MARK: - Per-Rep

    func formattedDuration(for rep: RepResult) -> String {
        PaceCalculator.formatDuration(rep.duration)
    }

    func formattedPace(for rep: RepResult) -> String {
        PaceCalculator.formatPace(rep.pacePerKm)
    }

    func isFastest(_ rep: RepResult) -> Bool {
        summary.reps.count > 1 && rep.id == summary.fastestRep?.id
    }

    func isSlowest(_ rep: RepResult) -> Bool {
        summary.reps.count > 1 && rep.id == summary.slowestRep?.id
    }

    /// Bar width ratio (0...1) — slowest rep = 1.0, fastest proportionally shorter
    func barRatio(for rep: RepResult) -> Double {
        guard let maxDuration = summary.reps.map(\.duration).max(), maxDuration > 0 else { return 1.0 }
        return rep.duration / maxDuration
    }

    func barColor(for rep: RepResult) -> Color {
        if isFastest(rep) { return Theme.success }
        if isSlowest(rep) { return Theme.secondary }
        return Theme.repInProgress
    }

    /// Pace difference from average, formatted as "+0:05" or "-0:03"
    func paceDelta(for rep: RepResult) -> String? {
        guard summary.reps.count > 1 else { return nil }
        let avg = summary.averagePace
        guard avg > 0 else { return nil }
        let delta = rep.pacePerKm - avg
        let absDelta = abs(delta)
        let mins = Int(absDelta) / 60
        let secs = Int(absDelta) % 60
        let sign = delta < 0 ? "-" : "+"
        if mins > 0 {
            return String(format: "%@%d:%02d", sign, mins, secs)
        }
        return String(format: "%@0:%02d", sign, secs)
    }
}
