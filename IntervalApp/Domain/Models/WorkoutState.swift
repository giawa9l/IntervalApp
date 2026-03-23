import Foundation

enum WorkoutPhase: Equatable {
    case idle
    case runningRep(Int)
    case recovery(Int, TimeInterval)
    case paused(from: PausedFrom)
    case completed
}

enum PausedFrom: Equatable {
    case running(Int)
    case recovery(Int, TimeInterval)
}

enum WorkoutEvent {
    case start
    case repCompleted
    case recoveryDone
    case pause
    case resume
    case endWorkout
}
