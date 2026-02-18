//
//  SceneDelegate.swift
//  record
//
//  Created by Esakkinathan B on 28/01/26.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var isLocked = true


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
//        let appearance = UINavigationBarAppearance()
//        appearance.configureWithOpaqueBackground()
//        appearance.backgroundColor = AppColor.primaryColor
//        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
//        UINavigationBar.appearance().standardAppearance = appearance
//        UINavigationBar.appearance().scrollEdgeAppearance = appearance
//        UINavigationBar.appearance().compactAppearance = appearance
        
//        let vc = RegisterScreenAssembler.make()
//        
//        window?.rootViewController = vc
        showLockScreen()
        window?.makeKeyAndVisible()

        window?.overrideUserInterfaceStyle = .unspecified
        UINavigationBar.appearance().tintColor = AppColor.primaryColor
        UITabBar.appearance().tintColor = AppColor.primaryColor
        window?.tintColor = AppColor.primaryColor
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        guard isLocked == false else { return }
        showLockScreen()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        isLocked = true

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



}

