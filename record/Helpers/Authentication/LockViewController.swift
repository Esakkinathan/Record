//
//  LockViewController.swift
//  record
//
//  Created by Esakkinathan B on 15/02/26.
//

import UIKit

final class LockViewController: UIViewController {

    private let unlockButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Unlock", for: .normal)
        b.titleLabel?.font = .boldSystemFont(ofSize: 22)
        return b
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.background
        
        title = "Unlock"
        view.addSubview(unlockButton)
        unlockButton.center = view.center

        unlockButton.addTarget(self, action: #selector(unlockTapped), for: .touchUpInside)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        authenticate()
    }

    @objc private func unlockTapped() {
        authenticate()
    }

    private func authenticate() {

        DeviceAuthenticationService.shared.authenticate { success in
            if success {
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?
                    .showMainInterface()
            }
        }
    }
}
