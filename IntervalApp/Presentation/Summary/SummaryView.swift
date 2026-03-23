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
                VStack(spacing: 24) {
                    headerCard

                    repList

                    doneButton
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
            }
        }
    }

    // MARK: - Header Card

    private var headerCard: some View {
        HStack(spacing: 0) {
            statColumn(label: "Total Time", value: viewModel.formattedTotalTime)
            Spacer()
            statColumn(label: "Distance", value: viewModel.formattedTotalDistance)
            Spacer()
            statColumn(label: "Avg Pace", value: viewModel.formattedAveragePace)
        }
        .padding(24)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func statColumn(label: String, value: String) -> some View {
        VStack(spacing: 8) {
            Text(label)
                .font(Theme.secondaryLabel)
                .foregroundColor(Theme.mutedForeground)

            Text(value)
                .font(Theme.paceDisplay)
                .foregroundColor(Theme.foreground)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Rep List

    private var repList: some View {
        VStack(spacing: 8) {
            ForEach(viewModel.summary.reps) { rep in
                repRow(rep)
            }
        }
    }

    private func repRow(_ rep: RepResult) -> some View {
        HStack {
            Text("Rep \(rep.id)")
                .font(.body.weight(.semibold))
                .foregroundColor(accentColor(for: rep))

            Spacer()

            Text(viewModel.formattedDuration(for: rep))
                .font(.body.monospacedDigit())
                .foregroundColor(Theme.foreground)

            Text(viewModel.formattedPace(for: rep))
                .font(Theme.secondaryLabel.monospacedDigit())
                .foregroundColor(Theme.mutedForeground)
                .frame(width: 100, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(accentBorderColor(for: rep), lineWidth: isFastestOrSlowest(rep) ? 1.5 : 0)
        )
    }

    private func accentColor(for rep: RepResult) -> Color {
        if viewModel.isFastest(rep) { return Theme.success }
        if viewModel.isSlowest(rep) { return Theme.secondary }
        return Theme.foreground
    }

    private func accentBorderColor(for rep: RepResult) -> Color {
        if viewModel.isFastest(rep) { return Theme.success.opacity(0.5) }
        if viewModel.isSlowest(rep) { return Theme.secondary.opacity(0.5) }
        return .clear
    }

    private func isFastestOrSlowest(_ rep: RepResult) -> Bool {
        viewModel.isFastest(rep) || viewModel.isSlowest(rep)
    }

    // MARK: - Done Button

    private var doneButton: some View {
        Button(action: onDone) {
            Text("DONE")
                .font(Theme.buttonText)
                .foregroundColor(Theme.foreground)
                .frame(maxWidth: .infinity, minHeight: 60)
                .background(Theme.primary)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .accessibilityLabel("Done, return to setup")
        .padding(.top, 8)
    }
}
