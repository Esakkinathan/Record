//
//  FormField.swift
//  record
//
//  Created by Esakkinathan B on 30/01/26.
//

import UIKit
import VTDB

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

enum FormFieldType {
    case text
    case password
    case date
    case select
    case textSelect
    case fileUpload
    case textView
    case button
}

struct FormField {
    let label: String
    let type: FormFieldType
    let validators: [ValidationRules]
    var gotoNextField: Bool
    var placeholder: String?
    var value: Any?
    var returnType: UIReturnKeyType?
    var keyboardMode: UIKeyboardType?

}

protocol FormFieldPresenterProtocol {
    var title: String {get}
    
    func field(at index: Int) -> FormField
    func numberOfFields() -> Int
    func updateValue(_ value: Any?, at index: Int)
    func viewDidLoad()
    func validateText(text: String, index: Int,rules: [ValidationRules]) -> ValidationResult
    
    func cancelClicked()
    func saveClicked()
    //func didSelectOption(at index: Int)
    func selectClicked(at index: Int)
    func formButtonClicked()
    
    func uploadDocument(at index: Int)
    func viewDocument(at index: Int)
    func removeDocument(at index: Int)
    func didPickDocument(url: URL)

}

    

protocol FormFieldViewDelegate: AnyObject {
    var onEdit: ((Persistable) -> Void)? { get set }
    var onAdd: ((Persistable) -> Void)? { get set}
    func showError(_ message: String?)
    func reloadData()
    func reloadField(at index: Int)
    func dismiss()
    func configureToOpenDocument(previewUrl: URL)
    //var previewurl: URL? {get}
}
