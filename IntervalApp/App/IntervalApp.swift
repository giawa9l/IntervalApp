import SwiftUI

enum AppScreen {
    case setup
    case workout(WorkoutConfig)
    case summary(WorkoutSummary)
}

@main
struct IntervalApp: App {
    @StateObject private var container = DIContainer()
    @State private var currentScreen: AppScreen = .setup

    var body: some Scene {
        WindowGroup {
            Group {
                switch currentScreen {
                case .setup:
                    SetupView { config in
                        currentScreen = .workout(config)
                    }

                case .workout(let config):
                    WorkoutView(config: config, container: container) { summary in
                        currentScreen = .summary(summary)
                    }

                case .summary(let summary):
                    SummaryView(summary: summary) {
                        currentScreen = .setup
                    }
                }
            }
            .background(Theme.background.ignoresSafeArea())
            .environmentObject(container)
        }
    }
}
