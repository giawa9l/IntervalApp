# IntervalApp

A minimal iOS interval running timer for 400m/800m track repeats. Built with SwiftUI.

## Features

- **400m / 800m intervals** with configurable rep count (1-8)
- **Pedometer distance tracking** via CMPedometer — auto-completes reps when distance is reached (works indoors)
- **5-second countdown** before first rep starts
- **Live rep timer** with 1/10s precision while running
- **3-minute recovery timer** between reps with audio countdown
- **Progress bars** showing rep status (not started / in progress / completed)
- **Pace display** (min/km) updated in real-time, accurate across pause/resume
- **Per-rep pace labels** on completed progress bars
- **Haptic feedback** on rep complete and workout complete
- **Post-workout summary** with hero average pace, per-rep splits with visual pace bars, fastest/slowest highlighting

## Screenshots

| Setup | Workout | Summary |
|-------|---------|---------|
| Distance & rep picker | Live timer + progress bars | Per-rep splits & stats |

## Architecture

4-layer clean architecture with MVVM:

```
IntervalApp/
  App/           # Entry point, DI container, theme
  Domain/
    Models/      # WorkoutConfig, WorkoutState, RepResult, WorkoutSummary
    Engine/      # WorkoutStateMachine (pure), PaceCalculator
    Protocols/   # LocationTracking, AudioCuePlayer
  Data/          # PedometerManager (CMPedometer), AudioCueManager
  Presentation/
    Setup/       # Distance picker, rep stepper
    Workout/     # Live workout screen, progress bars, controls
    Summary/     # Results display
```

**Key design decisions:**
- Pure state machine (`WorkoutStateMachine`) with no side effects — all transitions are deterministic
- Protocol-first hardware abstraction (`LocationTracking`, `AudioCuePlayer`)
- `AsyncStream<Double>` for reactive pedometer distance updates
- No persistence for MVP — summary lives in memory only

## State Machine

```
idle ──start──► countdown(5)
countdown(0) ──countdownDone──► runningRep(1)
runningRep(n) ──repCompleted──► recovery(n)       [n < totalReps]
runningRep(n) ──repCompleted──► completed          [n == totalReps]
recovery(n) ──recoveryDone──► runningRep(n+1)
any ──pause/resume──► paused ↔ previous state
any ──endWorkout──► completed
```

## Design System

- **Dark OLED theme** (`#0F172A` background) with orange (`#EA580C`) accent
- SF Pro with Dynamic Type support
- 60pt minimum touch targets (designed for use while running)
- SF Symbols only — no emoji icons
- Haptic feedback via `UIImpactFeedbackGenerator`

## Requirements

- iOS 17.0+
- Xcode 16+
- Physical device required for pedometer distance tracking

## Build

```bash
xcodebuild -scheme IntervalApp \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  build
```

## License

MIT
