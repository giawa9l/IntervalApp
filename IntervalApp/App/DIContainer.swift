import SwiftUI

final class DIContainer: ObservableObject {
    let locationManager: LocationTracking
    let audioCueManager: AudioCuePlayer

    init() {
        self.locationManager = PedometerManager()
        self.audioCueManager = AudioCueManager()
    }
}
