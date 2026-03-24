import CoreMotion

final class PedometerManager: LocationTracking {

    private let pedometer = CMPedometer()
    private var continuation: AsyncStream<Double>.Continuation?
    private var repStartDate: Date = .now
    private var accumulatedDistance: Double = 0
    private var lastSegmentDistance: Double = 0

    lazy var distanceStream: AsyncStream<Double> = {
        AsyncStream { [weak self] continuation in
            self?.continuation = continuation
        }
    }()

    // MARK: - LocationTracking

    func startTracking() {
        guard CMPedometer.isDistanceAvailable() else { return }

        lastSegmentDistance = 0
        repStartDate = .now
        pedometer.startUpdates(from: repStartDate) { [weak self] data, error in
            guard let self, let data, error == nil else { return }
            let meters = data.distance?.doubleValue ?? 0
            self.lastSegmentDistance = meters
            self.continuation?.yield(self.accumulatedDistance + meters)
        }
    }

    func stopTracking() {
        pedometer.stopUpdates()
        accumulatedDistance += lastSegmentDistance
        lastSegmentDistance = 0
    }

    func resetDistance() {
        pedometer.stopUpdates()
        accumulatedDistance = 0
        lastSegmentDistance = 0
        continuation?.yield(0)
    }
}
