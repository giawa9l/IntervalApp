import CoreMotion

final class PedometerManager: LocationTracking {

    private let pedometer = CMPedometer()
    private var continuation: AsyncStream<Double>.Continuation?
    private var repStartDate: Date = .now
    private var accumulatedDistance: Double = 0
    private var lastSegmentDistance: Double = 0

    private(set) var distanceStream: AsyncStream<Double> = AsyncStream { _ in }

    // MARK: - LocationTracking

    func startTracking() {
        guard CMPedometer.isDistanceAvailable() else { return }

        // Fresh stream each session so new `for await` loops always receive values
        let (stream, continuation) = AsyncStream.makeStream(of: Double.self)
        self.distanceStream = stream
        self.continuation = continuation

        lastSegmentDistance = 0
        let startDate = Date.now
        pedometer.startUpdates(from: startDate) { [weak self] data, error in
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
    }
}
