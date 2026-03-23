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

                // Bottom: Controls
                WorkoutControlsView(
                    currentPace: viewModel.currentPace,
                    isPaused: viewModel.isPaused,
                    onTogglePause: { viewModel.togglePause() },
                    onEndWorkout: { viewModel.endWorkout() }
                )
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
        .onAppear {
            if case .idle = viewModel.phase {
                viewModel.startWorkout()
            }
        }
        .onChange(of: viewModel.phase) { _, newPhase in
            if case .completed = newPhase {
                let summary = viewModel.buildSummary()
                onComplete(summary)
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 12) {
            stateBadge

            Text("Rep \(viewModel.currentRepNumber) of \(viewModel.config.repCount)")
                .font(Theme.stateLabel)
                .foregroundColor(Theme.foreground)

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
        case .paused(let from):
            switch from {
            case .running:
                return "Paused"
            case .recovery:
                return "Paused"
            }
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
