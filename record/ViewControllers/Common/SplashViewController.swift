//
//  SplashViewController.swift
//  record
//
//  Created by Esakkinathan B on 04/03/26.
//
/*
import UIKit
//import Lottie_Lottie

class SplashViewController: UIViewController {

    private var animationView: LottieAnimationView!
    private let titleLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupUI()
        playAnimation()
    }

    private func setupUI() {
        animationView = LottieAnimationView(name: "launch_animation")
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        
        titleLabel.text = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
        titleLabel.font = UIFont.systemFont(ofSize: 26, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(animationView)
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalToConstant: 180),
            animationView.heightAnchor.constraint(equalToConstant: 180),
            animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: animationView.bottomAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func playAnimation() {
        animationView.play { [weak self] _ in
            self?.goToMain()
        }
    }

    private func goToMain() {
        let mainVC = MainTabBarController()
        let nav = UINavigationController(rootViewController: mainVC)
        
        UIView.transition(with: view.window!,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: {
            self.view.window?.rootViewController = nav
        })
    }
}
*/
