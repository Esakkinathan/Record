//
//  LockViewController.swift
//  record
//
//  Created by Esakkinathan B on 15/02/26.
//

import UIKit
final class LockViewController: UIViewController {

    private var didAuthenticateOnce = false

    // ... your UI setup ...

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !didAuthenticateOnce {
            didAuthenticateOnce = true
            authenticate()
        }
    }

    @objc private func unlockTapped() {
        authenticate()
    }

    private func authenticate() {
        DeviceAuthenticationService.shared.authenticate(
            onSuccess: {
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?
                    .showMainInterface()
            },
            onCancel: {
                // App launch cancel = exit app
                UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { exit(0) }
            },
            onFailure: { [weak self] error in
                switch error {
                case .permissionDenied:
                    self?.showPermissionDeniedAlert()
                case .notAvailable:
                    self?.showToast(message: "Device has no lock screen set up", type: .error)
                default:
                    break
                }
            }
        )
    }

    private func showPermissionDeniedAlert() {
        let alert = UIAlertController(
            title: "Face ID Permission Required",
            message: "Enable Face ID in Settings to unlock the app.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            // Treated same as cancel — exit app
            UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { exit(0) }
        })
        present(alert, animated: true)
    }
}
