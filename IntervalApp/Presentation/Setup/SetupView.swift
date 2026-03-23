import SwiftUI

struct SetupView: View {
    @StateObject private var viewModel = SetupViewModel()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let onStart: (WorkoutConfig) -> Void

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                distanceSelector

                repCounter

                infoText

                Spacer()

                startButton
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
    }

    // MARK: - Distance Selector

    private var distanceSelector: some View {
        HStack(spacing: 16) {
            ForEach(IntervalDistance.allCases, id: \.self) { distance in
                Button {
                    let anim: Animation = reduceMotion ? .default : .easeOut(duration: 0.2)
                    withAnimation(anim) {
                        viewModel.selectedDistance = distance
                    }
                } label: {
                    Text(distance.rawValue)
                        .font(Theme.buttonText)
                        .foregroundColor(Theme.foreground)
                        .frame(maxWidth: .infinity, minHeight: 60)
                        .background(
                            viewModel.selectedDistance == distance
                                ? Theme.primary
                                : Theme.card
                        )
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .strokeBorder(
                                    viewModel.selectedDistance == distance
                                        ? Theme.ring
                                        : Theme.border,
                                    lineWidth: viewModel.selectedDistance == distance ? 2 : 1
                                )
                        )
                }
                .accessibilityLabel("\(distance.rawValue) interval distance")
                .accessibilityAddTraits(viewModel.selectedDistance == distance ? .isSelected : [])
            }
        }
    }

    // MARK: - Rep Counter

    private var repCounter: some View {
        HStack(spacing: 24) {
            Button {
                let anim: Animation = reduceMotion ? .default : .easeOut(duration: 0.2)
                withAnimation(anim) {
                    viewModel.decrementReps()
                }
            } label: {
                Image(systemName: "minus")
                    .font(.title2.weight(.bold))
                    .foregroundColor(Theme.foreground)
                    .frame(width: 60, height: 60)
                    .background(Theme.card)
                    .clipShape(Circle())
            }
            .accessibilityLabel("Decrease rep count")
            .disabled(viewModel.repCount <= 1)
            .opacity(viewModel.repCount <= 1 ? 0.4 : 1.0)

            Text("\(viewModel.repCount)")
                .font(Theme.repCounter)
                .foregroundColor(Theme.foreground)
                .frame(minWidth: 80)
                .contentTransition(.numericText())

            Button {
                let anim: Animation = reduceMotion ? .default : .easeOut(duration: 0.2)
                withAnimation(anim) {
                    viewModel.incrementReps()
                }
            } label: {
                Image(systemName: "plus")
                    .font(.title2.weight(.bold))
                    .foregroundColor(Theme.foreground)
                    .frame(width: 60, height: 60)
                    .background(Theme.card)
                    .clipShape(Circle())
            }
            .accessibilityLabel("Increase rep count")
            .disabled(viewModel.repCount >= 8)
            .opacity(viewModel.repCount >= 8 ? 0.4 : 1.0)
        }
    }

    // MARK: - Info Text

    private var infoText: some View {
        Text("3:00 rest between reps")
            .font(Theme.secondaryLabel)
            .foregroundColor(Theme.mutedForeground)
    }

    // MARK: - Start Button

    private var startButton: some View {
        Button {
            onStart(viewModel.config)
        } label: {
            Text("START WORKOUT")
                .font(Theme.buttonText)
                .foregroundColor(Theme.foreground)
                .frame(maxWidth: .infinity, minHeight: 60)
                .background(Theme.primary)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .accessibilityLabel("Start workout")
    }
}
