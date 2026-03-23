import SwiftUI
import Combine

@MainActor
final class WorkoutViewModel: ObservableObject {
    // MARK: - Published State

    @Published var phase: WorkoutPhase = .idle
    @Published var currentDistance: Double = 0
    @Published var repStartTime: Date = .now
    @Published var recoveryRemaining: TimeInterval = 0
    @Published var elapsedTime: TimeInterval = 0
    @Published private(set) var repResults: [RepResult] = []

    // MARK: - Configuration

    let config: WorkoutConfig

    // MARK: - Dependencies

    private let locationManager: LocationTracking
    private let audioCue: AudioCuePlayer

    // MARK: - Internal State

    private var distanceTask: Task<Void, Never>?
    private var timerTask: Task<Void, Never>?
    private var recoveryTask: Task<Void, Never>?
    private var workoutStartTime: Date = .now
    private var pausedRepElapsed: TimeInterval = 0

    // MARK: - Init

    init(config: WorkoutConfig, locationManager: LocationTracking, audioCue: AudioCuePlayer) {
        self.config = config
        self.locationManager = locationManager
        self.audioCue = audioCue
    }

    deinit {
        distanceTask?.cancel()
        timerTask?.cancel()
        recoveryTask?.cancel()
    }

    // MARK: - Actions

    func startWorkout() {
        workoutStartTime = .now
        phase = WorkoutStateMachine.transition(from: phase, event: .start, totalReps: config.repCount)
        beginRep()
        startElapsedTimer()
    }

    func completeRep() {
        let repNumber = currentRepNumber
        guard repNumber > 0 else { return }

        let duration = Date().timeIntervalSince(repStartTime)
        let result = RepResult(
            id: repNumber,
            distance: config.distance.meters,
            duration: duration
        )
        repResults.append(result)

        // Stop location tracking for this rep
        locationManager.stopTracking()
        cancelDistanceTask()

        let newPhase = WorkoutStateMachine.transition(
            from: phase,
            event: .repCompleted,
            totalReps: config.repCount
        )
        phase = newPhase

        if case .completed = newPhase {
            audioCue.playWorkoutComplete()
            cancelAllTasks()
        } else if case .recovery = newPhase {
            audioCue.playRepComplete()
            startRecoveryTimer()
        }
    }

    func togglePause() {
        switch phase {
        case .runningRep:
            // Store elapsed time for this rep before pausing
            pausedRepElapsed = Date().timeIntervalSince(repStartTime)
            phase = WorkoutStateMachine.transition(from: phase, event: .pause, totalReps: config.repCount)
            locationManager.stopTracking()
            cancelDistanceTask()
            cancelTimerTask()

        case .recovery(_, let remaining):
            recoveryRemaining = remaining
            phase = WorkoutStateMachine.transition(from: phase, event: .pause, totalReps: config.repCount)
            cancelRecoveryTask()
            cancelTimerTask()

        case .paused(let from):
            phase = WorkoutStateMachine.transition(from: phase, event: .resume, totalReps: config.repCount)
            startElapsedTimer()

            switch from {
            case .running:
                // Restore rep start time accounting for already-elapsed time
                repStartTime = Date().addingTimeInterval(-pausedRepElapsed)
                startDistanceMonitoring()
                locationManager.startTracking()

            case .recovery(_, let remaining):
                recoveryRemaining = remaining
                startRecoveryCountdown(from: remaining)
            }

        default:
            break
        }
    }

    func endWorkout() {
        phase = WorkoutStateMachine.transition(from: phase, event: .endWorkout, totalReps: config.repCount)
        locationManager.stopTracking()
        cancelAllTasks()
        audioCue.playWorkoutComplete()
    }

    // MARK: - Computed Properties

    var currentPace: String {
        let elapsed = Date().timeIntervalSince(repStartTime)
        guard currentDistance > 0, elapsed > 0 else { return PaceCalculator.formatPace(0) }
        let pace = PaceCalculator.pacePerKm(distance: currentDistance, duration: elapsed)
        return PaceCalculator.formatPace(pace)
    }

    var isPaused: Bool {
        if case .paused = phase { return true }
        return false
    }

    var currentRepNumber: Int {
        switch phase {
        case .runningRep(let n):
            return n
        case .recovery(let n, _):
            return n
        case .paused(let from):
            switch from {
            case .running(let n):
                return n
            case .recovery(let n, _):
                return n
            }
        default:
            return 0
        }
    }

    func repBarState(for rep: Int) -> RepBarState {
        let completedIds = Set(repResults.map(\.id))

        if completedIds.contains(rep) {
            return .completed
        }

        if case .runningRep(let n) = phase, rep == n {
            let target = config.distance.meters
            let progress = target > 0 ? currentDistance / target : 0
            return .inProgress(progress: progress)
        }

        return .notStarted
    }

    func buildSummary() -> WorkoutSummary {
        WorkoutSummary(
            config: config,
            reps: repResults,
            totalDuration: Date().timeIntervalSince(workoutStartTime)
        )
    }

    // MARK: - Private: Rep Management

    private func beginRep() {
        currentDistance = 0
        repStartTime = .now
        pausedRepElapsed = 0
        locationManager.resetDistance()
        locationManager.startTracking()
        startDistanceMonitoring()
    }

    // MARK: - Private: Distance Monitoring

    private func startDistanceMonitoring() {
        cancelDistanceTask()
        distanceTask = Task { [weak self] in
            guard let self else { return }
            for await distance in self.locationManager.distanceStream {
                guard !Task.isCancelled else { return }
                self.currentDistance = distance
                if distance >= self.config.distance.meters {
                    self.completeRep()
                    return
                }
            }
        }
    }

    // MARK: - Private: Recovery Timer

    private func startRecoveryTimer() {
        let seconds = TimeInterval(config.recoverySeconds)
        recoveryRemaining = seconds
        startRecoveryCountdown(from: seconds)
    }

    private func startRecoveryCountdown(from remaining: TimeInterval) {
        cancelRecoveryTask()
        recoveryTask = Task { [weak self] in
            guard let self else { return }
            var timeLeft = remaining

            while timeLeft > 0 {
                guard !Task.isCancelled else { return }

                if timeLeft <= 3 && timeLeft > 0 {
                    self.audioCue.playCountdown()
                }

                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard !Task.isCancelled else { return }

                timeLeft -= 1
                self.recoveryRemaining = max(0, timeLeft)

                // Update the phase with new remaining time
                if case .recovery(let n, _) = self.phase {
                    self.phase = .recovery(n, max(0, timeLeft))
                }
            }

            // Recovery complete - start next rep
            guard !Task.isCancelled else { return }
            self.phase = WorkoutStateMachine.transition(
                from: self.phase,
                event: .recoveryDone,
                totalReps: self.config.repCount
            )
            self.beginRep()
        }
    }

    // MARK: - Private: Elapsed Timer

    private func startElapsedTimer() {
        cancelTimerTask()
        timerTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard !Task.isCancelled else { return }
                self.elapsedTime = Date().timeIntervalSince(self.workoutStartTime)
            }
        }
    }

    // MARK: - Private: Task Cancellation

    private func cancelDistanceTask() {
        distanceTask?.cancel()
        distanceTask = nil
    }

    private func cancelTimerTask() {
        timerTask?.cancel()
        timerTask = nil
    }

    private func cancelRecoveryTask() {
        recoveryTask?.cancel()
        recoveryTask = nil
    }

    private func cancelAllTasks() {
        cancelDistanceTask()
        cancelTimerTask()
        cancelRecoveryTask()
    }
}
