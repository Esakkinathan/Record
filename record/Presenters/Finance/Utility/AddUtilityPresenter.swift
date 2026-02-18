//
//  AddUtilityPresenter.swift
//  record
//
//  Created by Esakkinathan B on 11/02/26.
//
import UIKit

class AddUtilityPresenter: FormFieldPresenterProtocol {
    func selectClicked(at index: Int) {
        //
    }
    
    func formButtonClicked() {
        //
    }
    
    func uploadDocument(at index: Int) {
        //
    }
    
    func viewDocument(at index: Int) {
        //
    }
    
    func removeDocument(at index: Int) {
        //
    }
    
    func didPickDocument(url: URL) {
        //
    }
    
    
    weak var view: FormFieldViewDelegate?
    let mode: UtilityFormMode
    var fields: [FormField] = []
    init(view: FormFieldViewDelegate? = nil, mode: UtilityFormMode) {
        self.view = view
        self.mode = mode
    }
    
    var title: String {
        mode.navigationTitle
    }
    func buildFields() {
        let existing = existingUtility()
        fields = [
            FormField(label: "Utility", type: .text, validators: [.required, .maxLength(20)], gotoNextField: false, placeholder: "Enter Utility", value: existing?.name, returnType: .done, keyboardMode: .alphabet)
        ]
    }

    func field(at index: Int) -> FormField {
        return fields[index]
    }
    
    func numberOfFields() -> Int {
        fields.count
    }
    
    func updateValue(_ value: Any?, at index: Int) {
        fields[index].value = value
    }
    
    func validateFields() -> Bool{
        for field in fields {
            let result = Validator.Validate(input: field.value as? String ?? "" , rules: field.validators)
            if !result.isValid {
                view?.showError(result.errorMessage)
                return result.isValid
            }
        }
        return true
    }

    func validateText(text: String, index: Int, rules: [ValidationRules]) -> ValidationResult {
        let result = Validator.Validate(input: text, rules: rules)
        if result.isValid {
            updateValue(text, at: index)
        }
        return result

    }
    
    func cancelClicked() {
        view?.dismiss()
    }
    
    func saveClicked() {
        if validateFields() {
            let utility = buildUtility()
            
            switch mode {
            case .add:
                view?.onAdd?(utility)
            case .edit:
                view?.onEdit?(utility)
            }
            view?.dismiss()
        }

    }
    
    func buildUtility() -> Utility {
        let name = field(at: 0).value as? String ?? "Utility"
        switch mode {
        case .add:
            return Utility(id: 1, name: name)
        case .edit(let utility):
            utility.update(name: name)
            return utility
        }
    }
    
    
    func viewDidLoad() {
        buildFields()
    }
    
    
    func existingUtility() -> Utility? {
        if case let .edit(utility) = mode {
            return utility
        }
        return nil
    }
    
    
}
