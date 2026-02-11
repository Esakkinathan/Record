//
//  AddPasswordPresenter.swift
//  record
//
//  Created by Esakkinathan B on 03/02/26.
//

import UIKit

class AddPasswordPresenter: AddPasswordPresenterProtocol {
    var title: String {
        return mode.navigationTitle
    }
    
    
    weak var view: AddPasswordViewDelegate?
    
    var fields: [PasswordFormField] = []
    var router: AddPasswordRouterProtocol
    var mode: PasswordFormMode
    init(view: AddPasswordViewDelegate? = nil, router: AddPasswordRouterProtocol,mode: PasswordFormMode) {
        self.view = view
        self.mode = mode
        self.router = router
        
        buildFields()
    }
    

}

extension AddPasswordPresenter {
    func numberOfFields() -> Int {
        return fields.count
    }
    
    func field(at index: Int) -> PasswordFormField {
        return fields[index]
    }
    
    func updateValue(_ value: Any?, at index: Int) {
        fields[index].value = value
    }
        
    func updatePasswordField(_ suggested: String) {
        let field = fields.firstIndex(where: { $0.type == .password }) ?? 2
        let result = validateText(text: suggested, index: field, rules: fields[field].validators)
        if result.isValid {
            fields[field].value = suggested
            view?.reloadData()
        }
    }

}

extension AddPasswordPresenter {
    func suggesPasswordClicked() {
        router.openSuggestPasswordScreen() { [weak self] suggested in
            self?.updatePasswordField(suggested)
        }
    }
    func cancelClicked() {
        view?.dismiss()
    }

}

extension AddPasswordPresenter {
    func validateText(text: String, index: Int,rules: [ValidationRules] = []) -> ValidationResult {
        let result = Validator.Validate(input: text, rules: rules)
        if result.isValid {
            updateValue(text, at: index)
        }
        return result
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
}

extension AddPasswordPresenter {
    func buildFields() {
        let existing = existingPassword()

        fields = [
            PasswordFormField(label: "Title", placeholder: "Enter Title", type: .title, validators: [.required,.maxLength(20)], value: existing?.title, returnType: .next, keyboardMode: .default),
            PasswordFormField(label: "Username", placeholder: "Enter Username", type: .username, validators: [.required], value: existing?.username, returnType: .next, keyboardMode: .emailAddress),
            PasswordFormField(label: "Password", placeholder: "Enter Password", type: .password, validators: [.required,.minLength(6),.maxLength(14)], value: existing?.password, returnType: .done, keyboardMode: .default),
            PasswordFormField(label: "Suggest Password", placeholder: nil,type: .button, validators: [], returnType: .continue, keyboardMode: .default)
        ]
    }
    
    func existingPassword() -> Password? {
        if case let .edit(password) = mode {
            return password
        }
        return nil
    }



}
extension AddPasswordPresenter {
    
    func saveClicked() {
        if validateFields() {
            let password = buildPassword()

            switch mode {
            case .add:
                view?.onAdd?(password)
            case .edit:
                view?.onEdit?(password)
            }
            view?.dismiss()
        }
    }

    func buildPassword() -> Password {
        let title = field(at: 0).value as? String ?? DefaultDocument.adhar.rawValue
        let username = field(at: 1).value as? String ?? DefaultDocument.adhar.rawValue
        let passwordValue = field(at: 2).value as? String ?? DefaultDocument.adhar.rawValue
        
        switch mode {
        case .add:
            return Password(id: 1, title: title, username: username, password: passwordValue)
        case .edit(let password):
            password.update(title: title, username: username, password: passwordValue)
            return password
        }
    }

}
