import SwiftUI

final class SetupViewModel: ObservableObject {
    @Published var selectedDistance: IntervalDistance = .fourHundred
    @Published var repCount: Int = 4

    var config: WorkoutConfig {
        WorkoutConfig(distance: selectedDistance, repCount: repCount, recoverySeconds: 180)
    }

    func incrementReps() {
        if repCount < 8 { repCount += 1 }
    }

    func decrementReps() {
        if repCount > 1 { repCount -= 1 }
    }
}
