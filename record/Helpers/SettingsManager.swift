//
//  SettingsManager.swift
//  record
//
//  Created by Esakkinathan B on 19/02/26.
//

import UIKit

enum AppTheme: String {
    case system
    case light
    case dark
}

enum PDFCompressionLevel: String {
    case low
    case medium
    case high
    var value: CGFloat {
        switch self {
        case .low:
            return 0.8
        case .medium:
            return 0.5
        case .high:
            return 0.3
        }
    }
    static var `default`: PDFCompressionLevel {
        return .medium
    }
}
enum AppAccent: String, CaseIterable {
    case blue
    case emerald
    case violet
    case coral
    case amber
    
    var color: UIColor {
        switch self {
        case .blue:
            return UIColor { trait in
                trait.userInterfaceStyle == .dark ?
                UIColor(red: 0.35, green: 0.65, blue: 0.9, alpha: 1) :
                UIColor(red: 0.25, green: 0.55, blue: 1.0, alpha: 1)
            }
//        case .emerald:
//            return UIColor { trait in
//                trait.userInterfaceStyle == .dark ?
//                UIColor(red: 0.2, green: 0.85, blue: 0.6, alpha: 1) :
//                UIColor(red: 0.0, green: 0.6, blue: 0.4, alpha: 1)
//            }
        case .emerald:
            return UIColor { trait in
                trait.userInterfaceStyle == .dark ? UIColor(red: 0.28, green: 0.76, blue: 0.53, alpha: 1.0) :
                UIColor(red: 0.18, green: 0.66, blue: 0.43, alpha: 1.0) 
                
            }
        case .violet:
            return UIColor { trait in
                trait.userInterfaceStyle == .dark ?
                UIColor(red: 0.7, green: 0.5, blue: 1.0, alpha: 1) :
                UIColor(red: 0.6, green: 0.4, blue: 0.9, alpha: 1)
            }
//        case .coral:
//            return UIColor { trait in
//                trait.userInterfaceStyle == .dark ?
//                UIColor(red: 1.0, green: 0.45, blue: 0.45, alpha: 1) :
//                UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1)
//            }
        case .coral:
            return UIColor { trait in
                trait.userInterfaceStyle == .dark ?
                UIColor(red: 0.89, green: 0.4, blue: 0.4, alpha: 1) :
                UIColor(red: 0.95, green: 0.31, blue: 0.31, alpha: 1.0)
            }
        case .amber:
            return UIColor { trait in
                trait.userInterfaceStyle == .dark ? UIColor(red: 0.37, green: 0.72, blue: 0.76, alpha: 1)
                 : UIColor(red: 0.27, green: 0.62, blue: 0.66, alpha: 1.0)
                
            }
        }
    }
}

extension Notification.Name {
    static let accentChanged = Notification.Name("accentChanged")
}

class SettingsManager {
    static let shared = SettingsManager()
    static let accentKey = "accent"
    static let themeKey = "theme"
    static let faceIdKey = "faceIdEnabled"
    static let compressionKey = "pdfCompressionLevel"
    var accent: AppAccent {
        get {
            let value = UserDefaults.standard.string(forKey: SettingsManager.accentKey) ?? AppAccent.blue.rawValue
            let accent = AppAccent(rawValue: value) ?? .blue
            AppColor.primaryColor = accent.color
            return accent
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: SettingsManager.accentKey)
            AppColor.primaryColor = newValue.color
        }
    }
    
    var theme: AppTheme {
        get {
            let value = UserDefaults.standard.string(forKey: SettingsManager.themeKey) ?? AppTheme.system.rawValue
            return AppTheme(rawValue: value) ?? .system
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: SettingsManager.themeKey)
        }
    }
    
    var faceId: Bool {
        get {
            let value: Bool = UserDefaults.standard.bool(forKey: SettingsManager.faceIdKey)
            return value
        }
        set(newValue) {
            UserDefaults.standard.set(newValue, forKey: SettingsManager.faceIdKey)
        }
    }
    
    var compressionLevel: PDFCompressionLevel {
        get {
            guard let value = UserDefaults.standard.string(forKey: SettingsManager.compressionKey),
                  let level = PDFCompressionLevel(rawValue: value) else {
                return .default
            }
            return level

        } set(newValue) {
            UserDefaults.standard.set(newValue.rawValue, forKey: SettingsManager.compressionKey)
        }
    }
}

extension SettingsManager {
    func scheduleTime(for schedule: MedicalSchedule) -> MedicalScheduleTime {
        let defaults = UserDefaults.standard
        let hour   = defaults.object(forKey: schedule.hourKey)   as? Int ?? schedule.defaultHour
        let minute = defaults.object(forKey: schedule.minuteKey) as? Int ?? 0
        return MedicalScheduleTime(schedule: schedule, hour: hour, minute: minute)
    }
 
    func allScheduleTime() -> [MedicalScheduleTime] {
        MedicalSchedule.allCases.map { scheduleTime(for: $0) }
    }
 
    func saveScheduleTime(_ medicalSchedule: MedicalScheduleTime) {
        UserDefaults.standard.set(medicalSchedule.hour,   forKey: medicalSchedule.schedule.hourKey)
        UserDefaults.standard.set(medicalSchedule.minute, forKey: medicalSchedule.schedule.minuteKey)
    }

}
