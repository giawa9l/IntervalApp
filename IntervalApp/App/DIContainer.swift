import SwiftUI

final class DIContainer: ObservableObject {
    let locationManager: LocationTracking
    let audioCueManager: AudioCuePlayer

    init() {
        self.locationManager = LocationManager()
        self.audioCueManager = AudioCueManager()
    }
}
