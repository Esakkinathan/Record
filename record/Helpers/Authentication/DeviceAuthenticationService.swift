//
//  DeviceAuthenticationService.swift
//  record
//
//  Created by Esakkinathan B on 15/02/26.
//

import LocalAuthentication

final class DeviceAuthenticationService {

    static let shared = DeviceAuthenticationService()
    private init() {}

    func isDeviceSecured() -> Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
    }

    func authenticate(completion: @escaping (Bool) -> Void) {

        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            completion(true)
            return
        }

        let reason = "Unlock your personal data"

        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, _ in
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }
}
