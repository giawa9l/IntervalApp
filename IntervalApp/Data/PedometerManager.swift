import CoreMotion

final class PedometerManager: LocationTracking {

    private let pedometer = CMPedometer()
    private var continuation: AsyncStream<Double>.Continuation?
    private var repStartDate: Date = .now

    lazy var distanceStream: AsyncStream<Double> = {
        AsyncStream { [weak self] continuation in
            self?.continuation = continuation
        }
    }()

    // MARK: - LocationTracking

    func startTracking() {
        guard CMPedometer.isDistanceAvailable() else { return }

        repStartDate = .now
        pedometer.startUpdates(from: repStartDate) { [weak self] data, error in
            guard let self, let data, error == nil else { return }
            let meters = data.distance?.doubleValue ?? 0
            self.continuation?.yield(meters)
        }
    }

    func stopTracking() {
        pedometer.stopUpdates()
    }

    func resetDistance() {
        pedometer.stopUpdates()
        continuation?.yield(0)
    }
}
