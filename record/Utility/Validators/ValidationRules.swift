//
//  ValidationRules.swift
//  record
//
//  Created by Esakkinathan B on 29/01/26.
//
import Foundation
enum ValidationRules: Equatable {
    case required
    case minLength(Int)
    case maxLength(Int)
    case exactLength(Int)
    
    case numeric
    case alphabetic
    case alphanumeric
    case email
    case phone
    
    case regex(String, message: String)
    
    case minValue(Double)
    case maxValue(Double)
    
    case noSpaces
    case allowedCharacters(CharacterSet, message: String)
    case disallowedCharacters(CharacterSet, message: String)

}

struct ValidationResult {
    let isValid: Bool
    let errorMessage: String?
    
    static let success = ValidationResult(isValid: true, errorMessage: nil)
}
