import SwiftUI

struct WorkoutView: View {
    @StateObject private var viewModel: WorkoutViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let onComplete: (WorkoutSummary) -> Void

    init(config: WorkoutConfig, container: DIContainer, onComplete: @escaping (WorkoutSummary) -> Void) {
        self._viewModel = StateObject(wrappedValue: WorkoutViewModel(
            config: config,
            locationManager: container.locationManager,
            audioCue: container.audioCueManager
        ))
        self.onComplete = onComplete
    }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 24) {
                // Top: State badge + rep info
                headerSection

                Spacer()

                // Center: Rep progress bars
                repBarsSection

                Spacer()

                // Bottom: Controls or Start button
                bottomSection
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)

            // Countdown overlay
            if viewModel.isCountdown {
                countdownOverlay
            }
        }
        .onChange(of: viewModel.phase) { _, newPhase in
            if case .completed = newPhase {
                let summary = viewModel.buildSummary()
                onComplete(summary)
            }
        }
    }

    // MARK: - Bottom Section

    private var bottomSection: some View {
        Group {
            if viewModel.isIdle {
                startButton
            } else if !viewModel.isCountdown, !viewModel.isCompleted {
                WorkoutControlsView(
                    currentPace: viewModel.currentPace,
                    isPaused: viewModel.isPaused,
                    onTogglePause: { viewModel.togglePause() },
                    onEndWorkout: { viewModel.endWorkout() }
                )
            }
        }
    }

    // MARK: - Start Button

    private var startButton: some View {
        Button {
            viewModel.startWorkout()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "figure.run")
                    .font(.title2)
                Text("START")
                    .font(Theme.buttonText)
            }
            .foregroundColor(Theme.foreground)
            .frame(maxWidth: .infinity, minHeight: 60)
            .background(Theme.primary)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .accessibilityLabel("Start running")
    }

    // MARK: - Countdown Overlay

    private var countdownOverlay: some View {
        ZStack {
            Theme.background.opacity(0.85).ignoresSafeArea()

            VStack(spacing: 16) {
                Text("GET READY")
                    .font(Theme.stateLabel)
                    .foregroundColor(Theme.mutedForeground)

                Text(viewModel.countdownValue > 0 ? "\(viewModel.countdownValue)" : "GO!")
                    .font(.system(size: 120, weight: .bold, design: .rounded))
                    .foregroundColor(viewModel.countdownValue > 0 ? Theme.foreground : Theme.primary)
                    .contentTransition(.numericText())
                    .animation(
                        reduceMotion ? .none : .spring(response: 0.3, dampingFraction: 0.6),
                        value: viewModel.countdownValue
                    )
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 12) {
            if !viewModel.isIdle && !viewModel.isCountdown {
                stateBadge
            }

            if viewModel.isIdle {
                Text("\(viewModel.config.distance.rawValue) x \(viewModel.config.repCount)")
                    .font(Theme.stateLabel)
                    .foregroundColor(Theme.foreground)

                Text("3:00 rest between reps")
                    .font(Theme.secondaryLabel)
                    .foregroundColor(Theme.mutedForeground)
            } else {
                Text("Rep \(viewModel.currentRepNumber) of \(viewModel.config.repCount)")
                    .font(Theme.stateLabel)
                    .foregroundColor(Theme.foreground)
            }

            // Running: show live rep timer
            if isRunningPhase {
                Text(viewModel.formattedRepElapsed)
                    .font(.system(size: 64, weight: .bold, design: .monospaced))
                    .foregroundColor(Theme.foreground)
                    .monospacedDigit()
            }

            // Recovery: show countdown
            if isRecoveryPhase {
                Text(PaceCalculator.formatDuration(viewModel.recoveryRemaining))
                    .font(.system(size: 64, weight: .bold, design: .monospaced))
                    .foregroundColor(Theme.foreground)
                    .contentTransition(.numericText())
                    .animation(
                        reduceMotion ? .none : .easeOut(duration: 0.2),
                        value: viewModel.recoveryRemaining
                    )
            }
        }
    }

    private var stateBadge: some View {
        Text(stateBadgeText)
            .font(.caption.weight(.bold))
            .textCase(.uppercase)
            .foregroundColor(Theme.foreground)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(stateBadgeColor)
            .clipShape(Capsule())
    }

    private var stateBadgeText: String {
        switch viewModel.phase {
        case .runningRep:
            return "Running"
        case .recovery:
            return "Recovery"
        case .paused:
            return "Paused"
        case .completed:
            return "Complete"
        default:
            return ""
        }
    }

    private var stateBadgeColor: Color {
        switch viewModel.phase {
        case .runningRep:
            return Theme.primary
        case .recovery:
            return Theme.muted
        case .paused:
            return Theme.muted
        case .completed:
            return Theme.success
        default:
            return Theme.muted
        }
    }

    private var isRunningPhase: Bool {
        if case .runningRep = viewModel.phase { return true }
        if case .paused(let from) = viewModel.phase,
           case .running = from { return true }
        return false
    }

    private var isRecoveryPhase: Bool {
        if case .recovery = viewModel.phase { return true }
        if case .paused(let from) = viewModel.phase,
           case .recovery = from { return true }
        return false
    }

    // MARK: - Rep Bars Section

    private var repBarsSection: some View {
        VStack(spacing: 8) {
            ForEach(1...viewModel.config.repCount, id: \.self) { rep in
                RepProgressBar(
                    repNumber: rep,
                    state: viewModel.repBarState(for: rep)
                )
            }
        }
    }
}
