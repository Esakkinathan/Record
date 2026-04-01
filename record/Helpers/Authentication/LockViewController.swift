//
//  LockViewController.swift
//  record
//
//  Created by Esakkinathan B on 15/02/26.
//

import UIKit

import UIKit

final class LockViewController: UIViewController {

    private var didAuthenticateOnce = false

    // MARK: Logo

    private let logoView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "Image2"))
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: App Name

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Record"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
        
    }
    
    override var shouldAutorotate: Bool {
        return true
    }

    // MARK: Unlock Button

    private let unlockButton: UIButton = {
        let button = UIButton(type: .system)

        button.setTitle(" Unlock with Face ID", for: .normal)
        button.setImage(UIImage(systemName: "faceid"), for: .normal)

        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)

        button.backgroundColor = .label
        button.tintColor = .systemBackground

        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true

        return button
    }()

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        setupUI()

        unlockButton.addTarget(self, action: #selector(unlockTapped), for: .touchUpInside)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !didAuthenticateOnce {
            didAuthenticateOnce = true
            authenticate()
        }
    }

    // MARK: Layout

    private func setupUI() {

        view.addSubview(logoView)
        view.addSubview(titleLabel)
        view.addSubview(unlockButton)

        NSLayoutConstraint.activate([

            // Logo
            logoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -120),
            logoView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75),
            logoView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75),

            // Title
            titleLabel.topAnchor.constraint(equalTo: logoView.bottomAnchor, constant: 32),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            unlockButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            unlockButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75),
            unlockButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -64)
        ])
    }

    // MARK: Actions

    @objc private func unlockTapped() {
        authenticate()
    }

    // MARK: Face ID

    private func authenticate() {

        DeviceAuthenticationService.shared.authenticate(
            onSuccess: { [weak self] in
                self?.dismiss(animated: true)
            },
            onCancel: {
                // stay on lock screen
            },
            onFailure: { error in
                print(error)
            }
        )
    }
}


import UIKit

class PrivacyProtection {

    static let shared = PrivacyProtection()

    private var blurView: UIVisualEffectView?

    func enable() {

        guard
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = windowScene.windows.first
        else { return }

        let blurEffect = UIBlurEffect(style: .systemMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)

        blurView.frame = window.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        window.addSubview(blurView)

        self.blurView = blurView
    }

    func disable() {
        blurView?.removeFromSuperview()
        blurView = nil
    }
}
