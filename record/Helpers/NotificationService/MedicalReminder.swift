//
//  MedicalReminder.swift
//  record
//
//  Created by Esakkinathan B on 19/02/26.
//


import Foundation
import UserNotifications

final class RemainderScheduler {
    
    private let itemRepository: MedicalItemRepositoryProtocol = MedicalItemRepository()
    
    func scheduleNextSevenDays() {
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let endDate = calendar.date(byAdding: .day, value: 7, to: today)!
        
        let medicalItems = itemRepository.fetchMedicalItemsByDate(from: today, to: endDate)
        
        for offset in 0..<7 {
            
            guard let date = calendar.date(byAdding: .day, value: offset, to: today) else { continue }
            
            let activeItems = activeMedicalItems(from: medicalItems, for: date)
            if activeItems.isEmpty { continue }
            
            var scheduleCount: [MedicalSchedule: Int] = [:]
            
            for item in activeItems {
                for schedule in item.shedule {
                    scheduleCount[schedule, default: 0] += 1
                }
            }
            print("fetching medicines")
            
            for (schedule, count) in scheduleCount where count > 0 {
                scheduleNotification(date: date, schedule: schedule, count: count)
            }
        }
    }
    private func activeMedicalItems(from items: [MedicalItem], for date: Date) -> [MedicalItem] {
        
        let calendar = Calendar.current
        let target = calendar.startOfDay(for: date)
        
        return items.filter {
            calendar.startOfDay(for: $0.startDate) <= target &&
            calendar.startOfDay(for: $0.endDate) >= target
        }
    }
    private func scheduleNotification(date: Date,
                                      schedule: MedicalSchedule,
                                      count: Int) {
        
        let calendar = Calendar.current
        
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        
        switch schedule {
        case .morning:
            components.hour = AppConstantData.morningRemainder
        case .afternoon:
            components.hour = AppConstantData.afternoonRemainder
        case .evening:
            components.hour = AppConstantData.eveningRemainder
        case .night:
            components.hour = AppConstantData.nightRemainder
        }
        print("scheduling medicines")
        components.minute = 0
        
        guard let triggerDate = calendar.date(from: components),
              triggerDate > Date() else { return } // prevent past notifications
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: false
        )
        
        let content = UNMutableNotificationContent()
        content.title = "\(schedule.rawValue) Reminder"
        content.body = "You have \(count) medicines to take."
        content.sound = .default
        
        let identifier = "medical_\(date.timeIntervalSince1970)_\(schedule.rawValue)"
        
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
        print("scheduled succefully")
    }


}
