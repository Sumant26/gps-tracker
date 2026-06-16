import CoreLocation
import UIKit

private let kLocationIntervalSeconds: TimeInterval = 60

/**
 * Manages background GPS location updates on iOS.
 *
 * Configured with:
 * - `allowsBackgroundLocationUpdates = true`
 * - `pausesLocationUpdatesAutomatically = false`
 * - Significant location changes as a fallback
 *
 * Requires the "Location Updates" background mode in Info.plist and
 * "Always" location authorisation from the user.
 */
class LocationTrackingManager: NSObject {

    // MARK: - Singleton

    static let shared = LocationTrackingManager()

    // MARK: - Properties

    private let locationManager = CLLocationManager()
    private var timer: Timer?
    private(set) var isTracking = false
    private(set) var currentSessionId: String?

    /// Called with each captured location. Set by the Flutter layer via a MethodChannel if needed.
    var onLocationCaptured: ((CLLocation, String) -> Void)?

    // MARK: - Init

    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter  = kCLDistanceFilterNone
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
    }

    // MARK: - Public API

    /**
     * Begins capturing a location every 60 seconds for the given session.
     * Requests "Always" authorisation if not already granted.
     */
    func startTracking(sessionId: String) {
        currentSessionId = sessionId
        isTracking = true

        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()

        // Timed captures in addition to CLLocationManager delegate calls.
        timer = Timer.scheduledTimer(
            withTimeInterval: kLocationIntervalSeconds,
            repeats: true
        ) { [weak self] _ in
            self?.captureCurrentLocation()
        }

        captureCurrentLocation()
    }

    /** Stops all location updates and invalidates the timer. */
    func stopTracking() {
        isTracking = false
        currentSessionId = nil
        timer?.invalidate()
        timer = nil
        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()
    }

    // MARK: - Private

    private func captureCurrentLocation() {
        guard isTracking, let sessionId = currentSessionId else { return }
        if let location = locationManager.location {
            onLocationCaptured?(location, sessionId)
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationTrackingManager: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard isTracking, let sessionId = currentSessionId,
              let location = locations.last else { return }
        onLocationCaptured?(location, sessionId)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NSLog("[LocationTrackingManager] didFailWithError: %@", error.localizedDescription)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        NSLog("[LocationTrackingManager] Authorization changed: %ld", status.rawValue)
    }
}
