//
//  FormFieldPresenter.swift
//  record
//
//  Created by Esakkinathan B on 05/03/26.
//
import UIKit

class FormFieldPresenter: FormFieldPresenterProtocol {
    
    weak var view: FormFieldViewDelegate?
    var fields: [FormField] = []
    var isEdited: Bool = false
    init(view: FormFieldViewDelegate? = nil, ) {
        self.view = view
    }
    
    var title: String { "" }
    var maxFiles: Int  = 5
    func field(at index: Int) -> FormField {
        return fields[index]
    }
    
    func field(of type: FormFieldType) -> FormField? {
        fields.first { $0.type == type }
    }

    func numberOfFields() -> Int {
        return fields.count
    }
    
    func updateValue(_ value: Any?, at index: Int) {
        isEdited = true
        fields[index].value = value
    }
    func updateValueAt(_ value: Any?, at index: Int) {
        isEdited = true
        fields[index].value = value
        view?.reloadField(at: index)
    }
    
    func viewDidLoad() {
        //
    }
    
    
    
    func validateText(text: String, index: Int, rules: [ValidationRules]) -> ValidationResult {
        isEdited = true
        let result = Validator.Validate(input: text, rules: rules)
        if result.isValid {
            updateValue(text, at: index)
        }
        return result
    }
    func recognizeText(from image: UIImage){}
    
    func cancelClicked() {
        if isEdited{
            view?.showExitAlert()
        } else {
            exitScreen()
        }
        
    }
    
    func exitScreen() {
        view?.dismiss()
    }
    
    func saveClicked() {
        //
    }
    
    func validateFields() -> Bool{
        for field in fields {
            if field.type == .date {
                let input = field.value as? Date
                let result = Validator.Validate(input: input?.toString() ?? "" , rules: field.validators)
                if !result.isValid {
                    view?.showError( "\(field.label) \(result.errorMessage?.replacingOccurrences(of: "This", with: "") ?? "")")
                    return result.isValid
                }
            } else {
                let result = Validator.Validate(input: field.value as? String ?? "" , rules: field.validators)
                if !result.isValid {
                    view?.showError( "\(field.label) \(result.errorMessage?.replacingOccurrences(of: "This", with: "") ?? "")")
                    return result.isValid
                }
            }
        }
        return true
    }
    
    func didSelectOption(at index: Int,_ value: String){}
    func selectClicked(at index: Int){
    }
    func formButtonClicked(){}
    
    func uploadDocument(at index: Int, type: DocumentType){}
    func viewDocument(at index: Int){}
    func removeDocument(at index: Int){}
    func openCameraClicked() {}
    func processImages(from images: [UIImage]) {}
    func processFile(urls: [URL]) {}
}
