import SwiftUI

enum RepBarState: Equatable {
    case notStarted
    case inProgress(progress: Double)
    case completed(pace: String)
}

struct RepProgressBar: View {
    let repNumber: Int
    let state: RepBarState

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: 12) {
            Text("\(repNumber)")
                .font(.subheadline.weight(.semibold).monospacedDigit())
                .foregroundColor(labelColor)
                .frame(width: 24, alignment: .center)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 8)
                        .fill(trackColor)

                    // Fill
                    if case .inProgress(let progress) = state {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Theme.repInProgress)
                            .frame(width: geometry.size.width * max(0, min(progress, 1.0)))
                            .animation(
                                reduceMotion ? .none : .easeOut(duration: 0.2),
                                value: progress
                            )
                    } else if case .completed = state {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Theme.success)
                    }
                }
            }
            .frame(height: 32)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(borderColor, lineWidth: isActive ? 2 : 0)
            )
            .shadow(
                color: isActive ? Theme.ring.opacity(0.4) : .clear,
                radius: isActive ? 6 : 0
            )

            // Pace label for completed reps
            if case .completed(let pace) = state {
                Text(pace)
                    .font(.caption.weight(.semibold).monospacedDigit())
                    .foregroundColor(Theme.success)
                    .frame(width: 80, alignment: .trailing)
            } else {
                Color.clear
                    .frame(width: 80)
            }
        }
    }

    // MARK: - Computed Properties

    private var isActive: Bool {
        if case .inProgress = state { return true }
        return false
    }

    private var trackColor: Color {
        switch state {
        case .notStarted:
            return Theme.repNotStarted
        case .inProgress:
            return Theme.repNotStarted
        case .completed:
            return Theme.success
        }
    }

    private var borderColor: Color {
        isActive ? Theme.ring : .clear
    }

    private var labelColor: Color {
        switch state {
        case .notStarted:
            return Theme.mutedForeground
        case .inProgress:
            return Theme.foreground
        case .completed:
            return Theme.success
        }
    }
}
