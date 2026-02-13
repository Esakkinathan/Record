//
//  PasswordSessionManager.swift
//  record
//
//  Created by Esakkinathan B on 06/02/26.
//

import Foundation

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
}
