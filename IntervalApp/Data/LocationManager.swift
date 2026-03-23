import CoreLocation

final class LocationManager: NSObject, CLLocationManagerDelegate, LocationTracking {

    private let clManager: CLLocationManager
    private var continuation: AsyncStream<Double>.Continuation?
    private var lastLocation: CLLocation?
    private var cumulativeDistance: Double = 0

    lazy var distanceStream: AsyncStream<Double> = {
        AsyncStream { [weak self] continuation in
            self?.continuation = continuation
        }
    }()

    override init() {
        clManager = CLLocationManager()
        super.init()
        clManager.desiredAccuracy = kCLLocationAccuracyBest
        clManager.distanceFilter = 5
        clManager.activityType = .fitness
        clManager.delegate = self
    }

    // MARK: - LocationTracking

    func startTracking() {
        clManager.requestWhenInUseAuthorization()
        clManager.startUpdatingLocation()
    }

    func stopTracking() {
        clManager.stopUpdatingLocation()
        lastLocation = nil
    }

    func resetDistance() {
        cumulativeDistance = 0
        lastLocation = nil
        continuation?.yield(0)
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            guard location.horizontalAccuracy <= 20 else { continue }

            if let last = lastLocation {
                cumulativeDistance += location.distance(from: last)
                continuation?.yield(cumulativeDistance)
            }

            lastLocation = location
        }
    }
}
