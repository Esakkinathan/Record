//
//  NotificationManager.swift
//  record
//
//  Created by Esakkinathan B on 19/02/26.
//
import Foundation
import UserNotifications

final class NotificationManager {
    
    static let shared = NotificationManager()
    
    private init() {}
    
    
    func syncMedicalNotifications() {
        self.clearMedicalNotifications()
        RemainderScheduler().scheduleNextSevenDays()
    }
    
        
    private func clearMedicalNotifications() {
        UNUserNotificationCenter.current()
            .removeAllPendingNotificationRequests()
    }
}

