//
//  DeviceAuthenticationService.swift
//  record
//
//  Created by Esakkinathan B on 15/02/26.
//

import LocalAuthentication

enum AuthenticationError: Error {
    case notAvailable
    case notEnrolled
    case permissionDenied
    case cancelled
    case failed
}

final class DeviceAuthenticationService {

    static let shared = DeviceAuthenticationService()
    private init() {}

    func isDeviceSecured() -> Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
    }

    func authenticate(
        reason: String = "Unlock your personal data",
        onSuccess: @escaping () -> Void,
        onCancel: (() -> Void)? = nil,
        onFailure: ((AuthenticationError) -> Void)? = nil
    ) {
        let context = LAContext()
        var error: NSError?

        // Check permission first
        let canUseBiometrics = context.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            error: &error
        )

        if !canUseBiometrics, let error {
            switch error.code {
            case LAError.biometryNotAvailable.rawValue:
                onFailure?(.permissionDenied)
                return
            default:
                break
            }
        }

        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) else {
            onFailure?(.notAvailable)
            return
        }

        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                if success {
                    onSuccess()
                    return
                }

                guard let laError = error as? LAError else {
                    onFailure?(.failed)
                    return
                }

                switch laError.code {
                case .userCancel, .systemCancel, .appCancel:
                    onCancel?()
                default:
                    onFailure?(.failed)
                }
            }
        }
    }
}

/*
 //Mark in app usage
 // Example: protecting a sensitive settings screen
 DeviceAuthenticationService.shared.authenticate(
     reason: "Confirm your identity to view this",
     onSuccess: {
         // proceed — navigate, reveal data, etc.
     },
     onCancel: { [weak self] in
         self?.showToast(message: "Authentication cancelled", type: .info)
     },
     onFailure: { [weak self] error in
         switch error {
         case .permissionDenied:
             self?.showToast(message: "Enable Face ID in Settings", type: .error)
         case .notAvailable:
             self?.showToast(message: "No lock screen set up on this device", type: .error)
         default:
             self?.showToast(message: "Authentication failed", type: .error)
         }
     }
 )
 */
