import Foundation

struct WorkoutStateMachine {

    static func transition(
        from state: WorkoutPhase,
        event: WorkoutEvent,
        totalReps: Int
    ) -> WorkoutPhase {
        switch (state, event) {
        case (.idle, .start):
            return .countdown(5)

        case (.countdown, .countdownDone):
            return .runningRep(1)

        case (.runningRep(let n), .repCompleted):
            if n < totalReps {
                return .recovery(n, 180)
            } else {
                return .completed
            }

        case (.recovery(let n, _), .recoveryDone):
            return .runningRep(n + 1)

        case (.runningRep(let n), .pause):
            return .paused(from: .running(n))

        case (.recovery(let n, let remaining), .pause):
            return .paused(from: .recovery(n, remaining))

        case (.paused(from: .running(let n)), .resume):
            return .runningRep(n)

        case (.paused(from: .recovery(let n, let remaining)), .resume):
            return .recovery(n, remaining)

        case (_, .endWorkout):
            return .completed

        default:
            return state
        }
    }
}
