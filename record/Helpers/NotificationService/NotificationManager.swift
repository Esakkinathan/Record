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
    
    let document = "document"
    func syncMedicalNotifications() {
        self.clearMedicalNotifications()
        RemainderScheduler().scheduleNextSevenDays()
    }
    
        
    private func clearMedicalNotifications() {
        UNUserNotificationCenter.current()
            .removeAllPendingNotificationRequests()
    }
    func setRemainderNotification(document: Document, remainderId: Int,date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Document Expiring Soon"
        content.body = "\(document.name) will expire on \(document.expiryDate?.toString() ?? "" )."
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute,],
                from: date
            ),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "\(self.document)_\(document.id)_\(remainderId)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
        print("Notification Added")
    }
    
    func removeRemainderNotification(documentId: Int,remainderId: Int) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["\(document)_\(documentId)_\(remainderId)"])
    }
    
}

