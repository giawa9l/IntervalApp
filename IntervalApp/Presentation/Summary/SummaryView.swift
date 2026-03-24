import SwiftUI

struct SummaryView: View {
    @StateObject private var viewModel: SummaryViewModel

    let onDone: () -> Void

    init(summary: WorkoutSummary, onDone: @escaping () -> Void) {
        self._viewModel = StateObject(wrappedValue: SummaryViewModel(summary: summary))
        self.onDone = onDone
    }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    heroSection
                    statsRow
                    splitsSection
                    doneButton
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 24)
            }
        }
    }

    // MARK: - Hero: Average Pace

    private var heroSection: some View {
        VStack(spacing: 8) {
            Text(viewModel.workoutLabel)
                .font(.callout.weight(.semibold))
                .foregroundColor(Theme.mutedForeground)
                .textCase(.uppercase)
                .tracking(1.5)

            Text(viewModel.formattedAveragePace)
                .font(.system(size: 56, weight: .bold, design: .monospaced))
                .foregroundColor(Theme.foreground)

            Text("avg pace")
                .font(.caption)
                .foregroundColor(Theme.mutedForeground)
                .textCase(.uppercase)
                .tracking(1)
        }
        .padding(.top, 16)
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: 0) {
            miniStat(value: viewModel.formattedTotalTime, label: "Time")
            divider
            miniStat(value: viewModel.formattedTotalDistance, label: "Distance")
            divider
            miniStat(value: "\(viewModel.summary.reps.count)", label: "Reps")
        }
        .padding(.vertical, 16)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func miniStat(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(.title3, design: .monospaced).weight(.semibold))
                .foregroundColor(Theme.foreground)
            Text(label)
                .font(.caption2)
                .foregroundColor(Theme.mutedForeground)
                .textCase(.uppercase)
                .tracking(0.5)
        }
        .frame(maxWidth: .infinity)
    }

    private var divider: some View {
        Rectangle()
            .fill(Theme.border)
            .frame(width: 1, height: 32)
    }

    // MARK: - Splits

    private var splitsSection: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Splits")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(Theme.foreground)
                Spacer()
            }
            .padding(.bottom, 16)

            // Column headers
            HStack(spacing: 0) {
                Text("#")
                    .frame(width: 28, alignment: .leading)
                Text("Pace")
                    .frame(width: 76, alignment: .leading)
                // Bar takes remaining space
                Spacer()
                Text("Time")
                    .frame(width: 52, alignment: .trailing)
            }
            .font(.caption2.weight(.medium))
            .foregroundColor(Theme.mutedForeground)
            .textCase(.uppercase)
            .tracking(0.5)
            .padding(.bottom, 8)

            // Rows
            ForEach(viewModel.summary.reps) { rep in
                splitRow(rep)
            }
        }
    }

    private func splitRow(_ rep: RepResult) -> some View {
        let color = viewModel.barColor(for: rep)

        return HStack(spacing: 0) {
            // Rep number
            Text("\(rep.id)")
                .font(.subheadline.weight(.semibold).monospacedDigit())
                .foregroundColor(color)
                .frame(width: 28, alignment: .leading)

            // Pace
            Text(viewModel.formattedPace(for: rep))
                .font(.subheadline.weight(.medium).monospacedDigit())
                .foregroundColor(Theme.foreground)
                .frame(width: 76, alignment: .leading)

            // Bar
            GeometryReader { geo in
                RoundedRectangle(cornerRadius: 4)
                    .fill(color.opacity(0.8))
                    .frame(width: geo.size.width * viewModel.barRatio(for: rep))
            }
            .frame(height: 20)

            // Duration
            Text(viewModel.formattedDuration(for: rep))
                .font(.subheadline.monospacedDigit())
                .foregroundColor(Theme.mutedForeground)
                .frame(width: 52, alignment: .trailing)
        }
        .padding(.vertical, 6)
    }

    // MARK: - Done Button

    private var doneButton: some View {
        Button(action: onDone) {
            Text("DONE")
                .font(Theme.buttonText)
                .foregroundColor(Theme.foreground)
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(Theme.primary)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .accessibilityLabel("Done, return to setup")
        .padding(.top, 8)
    }
}
