//
//  SettingsPresenter.swift
//  record
//
//  Created by Esakkinathan B on 19/02/26.
//

import UIKit

final class SettingsPresenter: SettingsPresenterProtocol {
    
    weak var view: SettingsViewDelegate?
    init(view: SettingsViewDelegate? = nil) {
        self.view = view
    }

    
    var currentTheme: AppTheme {
        SettingsManager.shared.theme
    }
    
    var currentAccent: AppAccent {
        SettingsManager.shared.accent
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
}
