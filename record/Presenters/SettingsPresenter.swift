//
//  SettingsPresenter.swift
//  record
//
//  Created by Esakkinathan B on 19/02/26.
//

import UIKit

final class SettingsPresenter: SettingsPresenterProtocol {
    
    weak var view: SettingsViewDelegate?
    var router: SettingsRouterProtocol
    init(view: SettingsViewDelegate? = nil, router: SettingsRouterProtocol) {
        self.view = view
        self.router = router
    }

    
    var currentTheme: AppTheme {
        SettingsManager.shared.theme
    }
    
    var currentAccent: AppAccent {
        SettingsManager.shared.accent
    }
    var compressionLevel: PDFCompressionLevel {
        SettingsManager.shared.compressionLevel
    }
    var isFaceIdEnabled: Bool {
        UserDefaults.standard.bool(forKey: "faceIdEnabled")
    }
    
    
    func selectTheme(_ theme: AppTheme) {
        SettingsManager.shared.theme = theme
        if let sceneDelegate = UIApplication.shared.connectedScenes
            .first?.delegate as? SceneDelegate {
            sceneDelegate.applyTheme(animated: false)
        }

        view?.reload()
    }
    
    func selectAccent(_ accent: AppAccent) {
        SettingsManager.shared.accent = accent
        NotificationCenter.default.post(name: .accentChanged, object: nil)
        if let sceneDelegate = UIApplication.shared.connectedScenes
            .first?.delegate as? SceneDelegate {
            sceneDelegate.applyAccent()
            sceneDelegate.setUpNavigation()
        }
        
        view?.reload()
    }
    
    func toggleFaceId(_ isOn: Bool) {
        SettingsManager.shared.faceId = isOn
    }
    
    func openSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(settingsURL) {
                UIApplication.shared.open(settingsURL, options: [:]) { success in
                }
            }
        }

    }
    
    func didClickedResentPin() {
        DeviceAuthenticationService.shared.authenticate(onSuccess: { [weak self] in
            self?.openResetPassword()
        },onFailure: { [weak self] error in
            switch error {
            case .permissionDenied:
                self?.view?.showToastVC(message: "Enable Face ID in Settings", type: .error)
            case .notAvailable:
                self?.view?.showToastVC(message: "No lock screen set up on this device", type: .error)
            default:
                self?.view?.showToastVC(message: "Authentication failed", type: .error)
            }

        })
    }
    
    func updateCompresseion(level: PDFCompressionLevel) {
        SettingsManager.shared.compressionLevel = level
    }
    
    func openResetPassword() {
        router.openResetPasswordScreen()
    }
    
}
