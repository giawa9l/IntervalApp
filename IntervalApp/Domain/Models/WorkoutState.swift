import Foundation

enum WorkoutPhase: Equatable {
    case idle
    case countdown(Int)        // 5, 4, 3, 2, 1 warmup countdown
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
    case countdownDone
    case repCompleted
    case recoveryDone
    case pause
    case resume
    case endWorkout
}
