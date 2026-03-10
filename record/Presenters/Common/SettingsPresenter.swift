//
//  SettingsPresenter.swift
//  record
//
//  Created by Esakkinathan B on 19/02/26.
//

import UIKit
enum SettingsSection: String {
    case appearance = "Appearance"
    case system = "System"
}

enum SettingsItem {
    case theme
    case accent
    case appLock
    case systemSettings
    case resetPin
    case compression
}

struct SettingsSectionView {
    let section: SettingsSection
    var rows: [SettingsItem]
}


final class SettingsPresenter: SettingsPresenterProtocol {
    
    weak var view: SettingsViewDelegate?
    var router: SettingsRouterProtocol
    init(view: SettingsViewDelegate? = nil, router: SettingsRouterProtocol) {
        self.view = view
        self.router = router
        if let _ = KeychainManager.shared.getPin() {
            sections[1].rows.append(.resetPin)
        }
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
    
    var hasPin: Bool {
        KeychainManager.shared.getPin() != nil
    }

    
    var sections: [SettingsSectionView] = [
        .init(section: .appearance, rows: [.theme, .accent]),
        .init(section: .system, rows: [.appLock, .systemSettings, .compression])
    ]
    
    func selectTheme(_ theme: AppTheme) {
        SettingsManager.shared.theme = theme
        if let sceneDelegate = UIApplication.shared.connectedScenes
            .first?.delegate as? SceneDelegate {
            sceneDelegate.applyTheme(animated: false)
        }

        //view?.reload()
    }
    
    func numberOfSections() -> Int {
        return sections.count
    }
    
    func numberOfRows(section: Int) -> Int {
        return sections[section].rows.count
    }
    
    func sectionRowAt(_ indexPath: IndexPath) -> SettingsItem {
        return sections[indexPath.section].rows[indexPath.row]
    }
    
    func titleForSection(at section: Int) -> String {
        return sections[section].section.rawValue
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
    
    func toggleFaceId(_ isOn: Bool, completion: @escaping (Bool) -> Void) {
        DeviceAuthenticationService.shared.authenticate(
            onSuccess: { [weak self] in
                SettingsManager.shared.faceId = isOn
                self?.view?.reload()
                completion(true)
            }, onCancel: {
                completion(false)
            }
            ,
            onFailure: { [weak self] error in
                self?.handleAppLockError(error: error)
                completion(false)
            }
            
        )
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
            self?.handleAppLockError(error: error)
        })
    }
    
    func handleAppLockError(error: AuthenticationError) {
        switch error {
        case .permissionDenied:
            view?.showToastVC(message: "Enable Face ID in Settings", type: .error)
        case .notAvailable:
            view?.showToastVC(message: "No lock screen set up on this device", type: .error)
        default:
            view?.showToastVC(message: "Authentication failed", type: .error)
        }

    }
    
    func updateCompresseion(level: PDFCompressionLevel) {
        SettingsManager.shared.compressionLevel = level
    }
    
    func openResetPassword() {
        router.openResetPasswordScreen()
    }
    
}
