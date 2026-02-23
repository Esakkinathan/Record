//
//  SceneDelegate.swift
//  record
//
//  Created by Esakkinathan B on 28/01/26.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var isLocked = SettingsManager.shared.faceId


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        
        applyTheme()
        applyAccent()
        setUpNavigation()
        window?.makeKeyAndVisible()
        if isLocked == false {
            showMainInterface()
            return
        }
        showLockScreen()


    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
//        if isLocked == false {
//            showMainInterface()
//            return
//        }
//        showLockScreen()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        //isLocked = true

    }
    func showLockScreen() {

        isLocked = true
        let lockVC = LockViewController()
        window?.rootViewController = lockVC
    }
    
    func showMainInterface() {

        isLocked = false

        let mainVC = TabBarController()

        UIView.transition(with: window!,
                          duration: 0.25,
                          options: .transitionCrossDissolve,
                          animations: {
            self.window?.rootViewController = mainVC
        })
    }
    
    func applyTheme(animated: Bool = false) {
        
        guard let window = self.window else { return }
        
        let theme = SettingsManager.shared.theme
        
        let style: UIUserInterfaceStyle
        
        switch theme {
        case .system:
            style = .unspecified
        case .light:
            style = .light
        case .dark:
            style = .dark
        }
        
        if animated {
            UIView.transition(
                with: window,
                duration: 0.3,
                options: .transitionCrossDissolve,
                animations: {
                    window.overrideUserInterfaceStyle = style
                }
            )
        } else {
            window.overrideUserInterfaceStyle = style
        }
    }
    
    func setUpNavigation() {
        let accent = SettingsManager.shared.accent
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = accent.color
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
    
    func applyAccent() {
        let accent: AppAccent = SettingsManager.shared.accent

        UINavigationBar.appearance().tintColor = accent.color
        UITabBar.appearance().tintColor = accent.color
        window?.tintColor = accent.color

        updateVisibleControllers(with: accent.color)
        setUpNavigation()
    }
    private func updateVisibleControllers(with color: UIColor) {
        guard let window = window,
              let root = window.rootViewController else { return }

        updateController(root, color: color)
    }

    private func updateController(_ vc: UIViewController, color: UIColor) {
        vc.view.tintColor = color
        
        if let nav = vc as? UINavigationController {
            nav.navigationBar.tintColor = color
            nav.viewControllers.forEach { updateController($0, color: color) }
        }

        if let tab = vc as? UITabBarController {
            tab.tabBar.tintColor = color
            tab.viewControllers?.forEach { updateController($0, color: color) }
        }

        vc.children.forEach { updateController($0, color: color) }
    }

}

