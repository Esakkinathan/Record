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
                UIColor(red: 0.35, green: 0.65, blue: 1.0, alpha: 1) :
                UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1)
            }
        case .emerald:
            return UIColor { trait in
                trait.userInterfaceStyle == .dark ?
                UIColor(red: 0.2, green: 0.85, blue: 0.6, alpha: 1) :
                UIColor(red: 0.0, green: 0.6, blue: 0.4, alpha: 1)
            }
        case .violet:
            return UIColor { trait in
                trait.userInterfaceStyle == .dark ?
                UIColor(red: 0.7, green: 0.5, blue: 1.0, alpha: 1) :
                UIColor(red: 0.5, green: 0.3, blue: 0.9, alpha: 1)
            }
        case .coral:
            return UIColor { trait in
                trait.userInterfaceStyle == .dark ?
                UIColor(red: 1.0, green: 0.45, blue: 0.45, alpha: 1) :
                UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1)
            }
        case .amber:
            return UIColor { trait in
                trait.userInterfaceStyle == .dark ?
                UIColor(red: 1.0, green: 0.7, blue: 0.3, alpha: 1) :
                UIColor(red: 1.0, green: 0.55, blue: 0.0, alpha: 1)
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
            print("value is",value)
            return value
        }
        set(newValue) {
            print("value is", newValue)
            UserDefaults.standard.set(newValue, forKey: SettingsManager.faceIdKey)
        }
    }
}
