import SwiftUI

struct WorkoutControlsView: View {
    let currentPace: String
    let isPaused: Bool
    let onTogglePause: () -> Void
    let onEndWorkout: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            // Current pace
            Text(currentPace)
                .font(Theme.paceDisplay)
                .foregroundColor(Theme.foreground)
                .accessibilityLabel("Current pace: \(currentPace)")

            // Pause / Resume button
            Button(action: onTogglePause) {
                Image(systemName: isPaused ? "play.fill" : "pause.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Theme.foreground)
                    .frame(width: 72, height: 72)
                    .background(Theme.primary)
                    .clipShape(Circle())
            }
            .accessibilityLabel(isPaused ? "Resume workout" : "Pause workout")

            // End workout button
            Button(action: onEndWorkout) {
                Text("End Workout")
                    .font(Theme.secondaryLabel.weight(.semibold))
                    .foregroundColor(Theme.destructive)
            }
            .frame(minHeight: 44)
            .accessibilityLabel("End workout")
        }
        .padding(.bottom, 8)
    }
}
