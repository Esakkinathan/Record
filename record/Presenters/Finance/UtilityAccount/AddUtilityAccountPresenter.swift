//
//  AddUtilityAccountPresenter.swift
//  record
//
//  Created by Esakkinathan B on 11/02/26.
//

import UIKit

class AddUtilityAccountPresenter: FormFieldPresenterProtocol {
    func didPickDocuments(urls: [URL]) {
        //
    }
    
    func uploadDocument(at index: Int, type: DocumentType) {
        //
    }
    
    func processImages(from images: [UIImage]) {
        //
    }
    
    func exitScreen() {
        //
    }
    
    func recognizeText(from image: UIImage) {
        //
    }
    
    func saveImage(_ image: UIImage) {
        //
    }
    
    func openCameraClicked() {
        //
    }
    
    func didSelectOption(at index: Int) {
        //
    }
    
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
    let mode: UtilityAccountFormMode
    let utility: Utility
    var fields: [FormField] = []
    init(view: FormFieldViewDelegate? = nil, mode: UtilityAccountFormMode, utility: Utility) {
        self.view = view
        self.mode = mode
        self.utility = utility
    }
    
    var title: String {
        mode.navigationTitle
    }
    
    func buildFields() {
        let existing = existingUtilityAccount()
        fields = [
            FormField(label: "Title", type: .text, validators: [.required, .maxLength(30)], gotoNextField: true, placeholder: "Enter Title",value: existing?.title, returnType: .next),
            FormField(label: "Account Number", type: .text, validators: [.required], gotoNextField: true, placeholder: "Enter Account Number", value: existing?.accountNumber, returnType: .next),
            FormField(label: "Provider", type: .text, validators: [.required, .maxLength(30)], gotoNextField: false, placeholder: "Enter Provider", value: existing?.provider, returnType: .done)
        ]
    }
    
    func existingUtilityAccount() -> UtilityAccount? {
        if case let .edit(utilityAccount) = mode {
            return utilityAccount
        }
        return nil
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
    
    func viewDidLoad() {
        buildFields()
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

    
    func saveClicked() {
        if validateFields() {
            let utilityAccount = buildUtilityAccount()
            
            switch mode {
            case .add:
                view?.onAdd?(utilityAccount)
            case .edit:
                view?.onEdit?(utilityAccount)
            }
            view?.dismiss()
        }

    }
    func buildUtilityAccount() -> UtilityAccount {
        let replacer = "Utility Account"
        let title = field(at: 0).value as? String ?? replacer
        let account = field(at: 1).value as? String ?? replacer
        let provider = field(at: 2).value as? String ?? replacer
        switch mode {
        case .add:
            return UtilityAccount(id: 1, utilityId: utility.id, title: title, accountNumber: account, provider: provider)
        case .edit(let utilityAccount):
            utilityAccount.update(title: title, accountNumber: account, provider: provider)
            return utilityAccount
        }
    }
}
