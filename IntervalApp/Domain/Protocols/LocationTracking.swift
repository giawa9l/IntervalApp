import CoreLocation

protocol LocationTracking: AnyObject {
    var distanceStream: AsyncStream<Double> { get }
    func startTracking()
    func stopTracking()
    func resetDistance()
}
