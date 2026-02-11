//
//  FormField.swift
//  record
//
//  Created by Esakkinathan B on 30/01/26.
//

import UIKit

enum DocumentFormFieldType {
    case select
    case number
    case fileUpload
    case expiryDate
}

struct DocumentFormField {
    let label: String
    let placeholder: String?
    let type: DocumentFormFieldType
    let validators: [ValidationRules]
    var value: Any?
}

enum PasswordFormFieldType {
    case title
    case username
    case password
    case button
}

struct PasswordFormField {
    let label: String
    let placeholder: String?
    let type: PasswordFormFieldType
    let validators: [ValidationRules]
    var value: Any?
    var returnType: UIReturnKeyType
    var keyboardMode: UIKeyboardType
}

enum MedicalFormFieldType {
    case title
    case type
    case hospital
    case doctor
    case date
}

struct MedicalFormField {
    let label: String
    let placeholder: String?
    let type: MedicalFormFieldType
    let validators: [ValidationRules]
    var value: Any?
    var returnType: UIReturnKeyType
    var keyboardMode: UIKeyboardType
}

enum MedicalItemFormFieldType {
    case name
    case instruction
    case dosage
    case schedule
    case duration
}

struct MedicalItemFormField {
    let label: String
    let placeholder: String?
    let type: MedicalItemFormFieldType
    let validators: [ValidationRules]
    var value: Any?
    var returnType: UIReturnKeyType
    var keyboardMode: UIKeyboardType
}
