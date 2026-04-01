//
//  LocationService.swift
//  record
//
//  Created by Esakkinathan B on 10/03/26.
//

import CoreLocation

struct HospitalCache: Codable {
    let lat: Double
    let lng: Double
    let hospitals: [String]
}

class HospitalCacheManager {

    static let shared = HospitalCacheManager()
    private let key = "hospital_cache"

    func save(lat: Double, lng: Double, hospitals: [String]) {
        let cache = HospitalCache(lat: lat, lng: lng, hospitals: hospitals)

        if let data = try? JSONEncoder().encode(cache) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func load() -> HospitalCache? {
        guard let data = UserDefaults.standard.data(forKey: key),
              let cache = try? JSONDecoder().decode(HospitalCache.self, from: data)
        else { return nil }

        return cache
    }
}

final class LocationService: NSObject, CLLocationManagerDelegate {

    static let shared = LocationService()

    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocationCoordinate2D?, Never>?
    
    // Cache the last known location to avoid repeated GPS fixes
    private var cachedLocation: CLLocationCoordinate2D?
    private var cacheDate: Date?
    private let cacheMaxAge: TimeInterval = 300 // 5 minutes

    private override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer // Coarse = faster fix
        // Pre-request authorization at init so it's ready when needed
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
    }

    func getLocation() async -> CLLocationCoordinate2D? {
        // 1. Return cached location if fresh
        if let cached = cachedLocation, let date = cacheDate,
           Date().timeIntervalSince(date) < cacheMaxAge {
            return cached
        }

        let status = manager.authorizationStatus

        guard status == .authorizedWhenInUse || status == .authorizedAlways else {
            return nil
        }

        // 2. Use last known location instantly if available (often accurate enough)
        if let last = manager.location,
           Date().timeIntervalSince(last.timestamp) < cacheMaxAge {
            let coord = last.coordinate
            cachedLocation = coord
            cacheDate = Date()
            return coord
        }

        // 3. Request fresh location with a hard timeout
        return await withCheckedContinuation { continuation in
            self.continuation = continuation
            manager.requestLocation()

            // Timeout after 4s — don't let a slow GPS fix block the whole flow
            Task {
                try? await Task.sleep(nanoseconds: 4_000_000_000)
                if let cont = self.continuation {
                    cont.resume(returning: self.manager.location?.coordinate)
                    self.continuation = nil
                }
            }
        }
    }

    // MARK: - Delegate

    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        let coord = locations.first?.coordinate
        cachedLocation = coord
        cacheDate = Date()
        continuation?.resume(returning: coord)
        continuation = nil
    }

    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        // Fall back to last known on error
        let fallback = manager.location?.coordinate
        continuation?.resume(returning: fallback)
        continuation = nil
    }
}
