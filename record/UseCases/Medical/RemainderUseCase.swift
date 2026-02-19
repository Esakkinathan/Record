//
//  RemainderUseCase.swift
//  record
//
//  Created by Esakkinathan B on 19/02/26.
//
import Foundation
import UserNotifications

class RemainderUseCase {
    let itemRepository: MedicalItemRepositoryProtocol = MedicalItemRepository()
    
    func activeMedicalItems(from items: [MedicalItem], for date: Date) -> [MedicalItem] {
        
        let calendar = Calendar.current
        let target = calendar.startOfDay(for: date)
        
        return items.filter {
            calendar.startOfDay(for: $0.startDate) <= target &&
            calendar.startOfDay(for: $0.endDate) >= target
        }
    }

    
    func execute() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let end = today.end

        
        let medicalItems = itemRepository.fetchMedicalItemsByDate(from: today, to: end)
        
        for offset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: offset, to: today) else {
                continue
            }

            let activeItems = activeMedicalItems(from: medicalItems,for: date)
            if activeItems.isEmpty { continue }
            
            var scheduleCount: [MedicalSchedule: Int] = [:]
            
            for item in activeItems {
                for schedule in item.shedule {
                    scheduleCount[schedule, default: 0] += 1
                }
            }
            for (schedule, count) in scheduleCount where count > 0 {
                scheduleNotification(date: date,schedule: schedule,count: count)
            }
        }
    }
    
    func scheduleNotification(date: Date, schedule: MedicalSchedule, count: Int) {
        
        let calendar = Calendar.current
        
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        
        switch schedule {
        case .morning:
            components.hour = 8
        case .afternoon:
            components.hour = 13
        case .evening:
            components.hour = 18
        case .night:
            components.hour = 21
        }
        
        components.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: false
        )
        
        let content = UNMutableNotificationContent()
        content.title = "\(schedule.rawValue) Remainder"
        content.body = "You have \(count) medicines to take."
        content.sound = .default
        
        let identifier = "\(date.timeIntervalSince1970)_\(schedule.rawValue)"
        
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }

}
