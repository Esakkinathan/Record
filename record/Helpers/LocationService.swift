//
//  LocationService.swift
//  record
//
//  Created by Esakkinathan B on 10/03/26.
//

import CoreLocation

final class LocationService: NSObject, CLLocationManagerDelegate {

    static let shared = LocationService()

    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocationCoordinate2D?, Never>?

    func getLocation() async -> CLLocationCoordinate2D? {

        let status = manager.authorizationStatus

        if status == .denied || status == .restricted {
            return nil
        }

        manager.delegate = self
        manager.requestWhenInUseAuthorization()

        return await withCheckedContinuation { continuation in
            self.continuation = continuation
            manager.requestLocation()
        }
    }

    // MARK: Delegate

    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {

        continuation?.resume(returning: locations.first?.coordinate)
        continuation = nil
    }

    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {

        continuation?.resume(returning: nil)
        continuation = nil
    }
}
