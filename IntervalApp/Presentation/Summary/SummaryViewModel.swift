import SwiftUI

final class SummaryViewModel: ObservableObject {
    let summary: WorkoutSummary

    init(summary: WorkoutSummary) {
        self.summary = summary
    }

    var formattedTotalTime: String {
        PaceCalculator.formatDuration(summary.totalDuration)
    }

    var formattedTotalDistance: String {
        String(format: "%.0fm", summary.totalDistance)
    }

    var formattedAveragePace: String {
        PaceCalculator.formatPace(summary.averagePace)
    }

    func formattedDuration(for rep: RepResult) -> String {
        PaceCalculator.formatDuration(rep.duration)
    }

    func formattedPace(for rep: RepResult) -> String {
        PaceCalculator.formatPace(rep.pacePerKm)
    }

    func isFastest(_ rep: RepResult) -> Bool {
        rep.id == summary.fastestRep?.id
    }

    func isSlowest(_ rep: RepResult) -> Bool {
        rep.id == summary.slowestRep?.id
    }
}
