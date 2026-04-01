//
//  PasswordSessionManager.swift
//  record
//
//  Created by Esakkinathan B on 06/02/26.
//

import Foundation
import UIKit
/*
class PasswordSessionManager {
    static let shared = PasswordSessionManager()
    private init() {}
    var timer: Timer?
    let sessionDuration: TimeInterval = TimeInterval(AppConstantData.passwordSession)
    var onSessionExpired: (() -> Void)?
    var isAuthenticated: Bool = false
    
    func authenticate() {
        isAuthenticated = true
        startTimer()
    }
    
    func logout() {
        isAuthenticated = false
        invalidateTimer()

    }
    
    func startTimer() {
        invalidateTimer()
        timer = Timer.scheduledTimer(withTimeInterval: sessionDuration, repeats: false) { [weak self] _ in
            self?.onSessionExpired?()
        }
    }
    
    func extendSession() {
        startTimer()
    }
    
    func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    func triggerExpiry() {
        onSessionExpired?() // existing callback
        NotificationCenter.default.post(name: .passwordSessionExpired, object: nil)
    }

}
 */

/*
class PasswordSessionManager {
    static let shared = PasswordSessionManager()
    private init() {}
    
    private var sessionTimer: Timer?
    private var countdownTimer: Timer?
    
    let sessionDuration: TimeInterval = TimeInterval(AppConstantData.passwordSession)
    var onSessionExpired: (() -> Void)?
    var onTickUpdate: ((String) -> Void)?   // ← add this
    var isAuthenticated: Bool = false
    var remainingTime: Int = AppConstantData.passwordSession  // ← add this

    func authenticate() {
        isAuthenticated = true
        startTimer()
    }
    
    func logout() {
        isAuthenticated = false
        invalidateTimers()
    }
    
    func startTimer() {
        invalidateTimers()
        remainingTime = AppConstantData.passwordSession
        
        // Session expiry timer
        sessionTimer = Timer.scheduledTimer(withTimeInterval: sessionDuration, repeats: false) { [weak self] _ in
            self?.triggerExpiry()
        }
        
        // UI countdown timer
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    func extendSession() {
        startTimer()
    }
    
    func invalidateTimers() {
        sessionTimer?.invalidate()
        sessionTimer = nil
        countdownTimer?.invalidate()
        countdownTimer = nil
    }
    
    private func tick() {
        guard remainingTime > 0 else { return }
        remainingTime -= 1
        let min = remainingTime / 60
        let sec = remainingTime % 60
        onTickUpdate?(String(format: "%02d:%02d", min, sec))
    }
    
    func triggerExpiry() {
        invalidateTimers()
        onSessionExpired?()
        NotificationCenter.default.post(name: .passwordSessionExpired, object: nil)
    }
}



class PasswordSessionManager {
    static let shared = PasswordSessionManager()
    private init() {}
    
    private var sessionTimer: Timer?
    private var countdownTimer: Timer?
    
    let sessionDuration: TimeInterval = TimeInterval(AppConstantData.passwordSession)
    var onTickUpdate: ((String) -> Void)?
    var isAuthenticated: Bool = false
    var remainingTime: Int = AppConstantData.passwordSession

    func authenticate() {
        isAuthenticated = true
        startTimer()
    }
    
    func logout() {
        isAuthenticated = false
        invalidateTimers()
    }
    
    func startTimer() {
        invalidateTimers()
        remainingTime = AppConstantData.passwordSession
        
        sessionTimer = Timer.scheduledTimer(withTimeInterval: sessionDuration, repeats: false) { [weak self] _ in
            self?.triggerExpiry()  // ← use triggerExpiry, not onSessionExpired directly
        }
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    func extendSession() {
        startTimer()
    }
    
    func invalidateTimers() {
        sessionTimer?.invalidate()
        sessionTimer = nil
        countdownTimer?.invalidate()
        countdownTimer = nil
    }
    
    private func tick() {
        guard remainingTime > 0 else { return }
        remainingTime -= 1
        let min = remainingTime / 60
        let sec = remainingTime % 60
        onTickUpdate?(String(format: "%02d:%02d", min, sec))
    }
    
    func triggerExpiry() {
        invalidateTimers()
        // Only notification — no onSessionExpired callback
        NotificationCenter.default.post(name: .passwordSessionExpired, object: nil)
    }
}

*/

class PasswordSessionManager {
    static let shared = PasswordSessionManager()
    private init() {}
    
    private var sessionTimer: Timer?
    private var countdownTimer: Timer?
    private var autoExitTimer: Timer?       // ← add this
    var isAutoExitAlertShowing: Bool = false

    let sessionDuration: TimeInterval = TimeInterval(AppConstantData.passwordSession)
    var onTickUpdate: ((String) -> Void)?
    var onAutoExit: (() -> Void)?           // ← add this
    var isAuthenticated: Bool = false
    var remainingTime: Int = AppConstantData.passwordSession

    func authenticate() {
        isAuthenticated = true
        startTimer()
    }
    
    func logout() {
        isAuthenticated = false
        invalidateAllTimers()
    }
    
    func startTimer() {
        invalidateAllTimers()
        remainingTime = AppConstantData.passwordSession
        
        sessionTimer = Timer.scheduledTimer(withTimeInterval: sessionDuration, repeats: false) { [weak self] _ in
            self?.triggerExpiry()
        }
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    func extendSession() {
        startTimer()
    }
    
    // Called when alert is shown — start 10 sec auto-exit countdown
    func startAutoExitTimer() {
        autoExitTimer?.invalidate()
        autoExitTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { [weak self] _ in
            self?.logout()
            self?.onAutoExit?()
        }
    }
    
    // Called when user taps Stay or Exit — cancel the 10 sec timer
    func cancelAutoExitTimer() {
        autoExitTimer?.invalidate()
        autoExitTimer = nil
    }
    
    func triggerExpiry() {
        invalidateAllTimers()
        NotificationCenter.default.post(name: .passwordSessionExpired, object: nil)
    }
    
    private func tick() {
        guard remainingTime > 0 else { return }
        remainingTime -= 1
        let min = remainingTime / 60
        let sec = remainingTime % 60
        onTickUpdate?(String(format: "%02d:%02d", min, sec))
    }
    
    private func invalidateAllTimers() {
        sessionTimer?.invalidate();  sessionTimer = nil
        countdownTimer?.invalidate(); countdownTimer = nil
        autoExitTimer?.invalidate();  autoExitTimer = nil
    }
}
extension Notification.Name {
    static let passwordSessionExpired = Notification.Name("passwordSessionExpired")
}

class PasswordSessionAwareViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.removeObserver(self, name: .passwordSessionExpired, object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSessionExpired),
            name: .passwordSessionExpired,
            object: nil
        )
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .passwordSessionExpired, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    

    @objc private func handleSessionExpired() {
        // If exit alert is showing, dismiss it first then show session expired
        if PasswordSessionManager.shared.isAutoExitAlertShowing,
           let existingAlert = presentedViewController as? UIAlertController {
            PasswordSessionManager.shared.isAutoExitAlertShowing = false
            existingAlert.dismiss(animated: false) { [weak self] in
                self?.showSessionExpiredAlert()
            }
            return
        }
        
        if presentedViewController is UIAlertController {
            PasswordSessionManager.shared.startAutoExitTimer()
            return
        }
        
        showSessionExpiredAlert()
    }

    private func showSessionExpiredAlert() {
        let alert = UIAlertController(
            title: "Session Expired",
            message: "Do you want to stay for another \(AppConstantData.passwordSession / 60) minutes?\nAuto exit in 10 seconds.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Stay", style: .default) { _ in
            PasswordSessionManager.shared.cancelAutoExitTimer()
            PasswordSessionManager.shared.extendSession()
        })

        alert.addAction(UIAlertAction(title: "Exit", style: .destructive) { [weak self] _ in
            PasswordSessionManager.shared.cancelAutoExitTimer()
            PasswordSessionManager.shared.logout()
            self?.navigationController?.dismiss(animated: true)
        })

        PasswordSessionManager.shared.onAutoExit = { [weak self] in
            DispatchQueue.main.async {
                self?.presentedViewController?.dismiss(animated: false) {
                    self?.navigationController?.dismiss(animated: true)
                }
            }
        }

        present(alert, animated: true) {
            PasswordSessionManager.shared.startAutoExitTimer()
        }
    }
}
