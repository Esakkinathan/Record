//
//  Validator.swift
//  record
//
//  Created by Esakkinathan B on 29/01/26.
//

import Foundation

class Validator {
    static func Validate(input: String?, rules: [ValidationRules]) -> ValidationResult{
        let value = input?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        for rule in rules {
            switch rule {
            case .required:
                if value.isEmpty {
                    return .init(isValid: false, errorMessage: "This field is required")
                }
                
            case .minLength(let length):
                if value.count < length {
                    return .init(isValid: false, errorMessage: "Minimum \(length) characters required")
                }
                
            case .maxLength(let length):
                if value.count > length {
                    return .init(isValid: false, errorMessage: "Maximum \(length) characters allowed")
                }
                
            case .exactLength(let length):
                if value.count != length {
                    return .init(isValid: false, errorMessage: "Must be exactly \(length) characters")
                }
                
            case .numeric:
                if !CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: value)) {
                    return .init(isValid: false, errorMessage: "Only numbers allowed")
                }
            case .alphabetic:
                if !CharacterSet.letters.isSuperset(of: CharacterSet(charactersIn: value)) {
                    return .init(isValid: false, errorMessage: "Only alphabets allowed")
                }
                
            case .alphanumeric:
                let allowed = CharacterSet.alphanumerics
                if !allowed.isSuperset(of: CharacterSet(charactersIn: value)) {
                    return .init(isValid: false, errorMessage: "Only letters and numbers allowed")
                }
                
            case .email:
                let regex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
                if !NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: value) {
                    return .init(isValid: false, errorMessage: "Invalid email address")
                }
                
            case .phone:
                if value.count != 10 {
                    return .init(isValid: false, errorMessage: "Invalid phone number")
                }
            case .regex(let pattern, let message):
                if !NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: value) {
                    return .init(isValid: false, errorMessage: message)
                }
                
            case .minValue(let min):
                if Double(value) ?? 0 < min {
                    return .init(isValid: false, errorMessage: "Minimum value is \(min)")
                }
                
            case .maxValue(let max):
                if Double(value) ?? 0 > max {
                    return .init(isValid: false, errorMessage: "Maximum value is \(max)")
                }
                
            case .noSpaces:
                if value.contains(" ") {
                    return .init(isValid: false, errorMessage: "Spaces are not allowed")
                }
            case .allowedCharacters(let allowedSet, let message):
                let inputSet = CharacterSet(charactersIn: value)
                if !allowedSet.isSuperset(of: inputSet) {
                    return .init(isValid: false, errorMessage: message)
                }

            case .disallowedCharacters(let blockedSet, let message):
                let inputSet = CharacterSet(charactersIn: value)
                if !blockedSet.isDisjoint(with: inputSet) {
                    return .init(isValid: false, errorMessage: message)
                }

            }
        }
        return .success
    }
}
