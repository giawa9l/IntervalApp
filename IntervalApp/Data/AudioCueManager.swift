import AudioToolbox
import UIKit

final class AudioCueManager: AudioCuePlayer {

    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)

    func playRepComplete() {
        AudioServicesPlaySystemSound(1025)
        mediumImpact.impactOccurred()
    }

    func playWorkoutComplete() {
        AudioServicesPlaySystemSound(1025)
        heavyImpact.impactOccurred()
    }

    func playCountdown() {
        AudioServicesPlaySystemSound(1057)
    }
}
