//
//  AddPasswordPresenter.swift
//  record
//
//  Created by Esakkinathan B on 03/02/26.
//

import UIKit

class AddPasswordPresenter: FormFieldPresenter {
    var router: AddPasswordRouterProtocol
    var mode: PasswordFormMode
    
    init(view: FormFieldViewDelegate? = nil, router: AddPasswordRouterProtocol, mode: PasswordFormMode) {
        self.router = router
        self.mode = mode
        super.init(view: view)
    }

    func existing() -> Password? {
        if case let .edit(password) = mode {
            return password
        }
        return nil
    }
    func buildFields() {
        let existing = existing()
        fields = [
            FormField(label: "Title", type: .text, validators: [.required,.maxLength(30)], gotoNextField: true, placeholder: "Enter Title", value: existing?.title,returnType: .next),
            FormField(label: "Username", type: .text, validators: [.required, .maxLength(30)], gotoNextField: true, placeholder: "Enter Username",value: existing?.username, returnType: .next, keyboardMode: .emailAddress),
            FormField(label: "Password", type: .password, validators: [.required, .minLength(4), .maxLength(20)], gotoNextField: false, placeholder: "Enter Password", value: existing?.password,returnType: .done),
            FormField(label: "Suggest Password", type: .button, validators: [], gotoNextField: false),
        ]
    }
    override var title: String {
        return mode.navigationTitle
    }
    
    override func viewDidLoad() {
        buildFields()
    }
    func buildPassword() -> Password {
        let title = field(at: 0).value as? String ?? DefaultDocument.defaultValue.rawValue
        let username = field(at: 1).value as? String ?? DefaultDocument.defaultValue.rawValue
        let passwordValue = field(at: 2).value as? String ?? DefaultDocument.defaultValue.rawValue
        
        switch mode {
        case .add:
            return Password(id: 1, title: title, username: username, password: passwordValue)
        case .edit(let password):
            password.update(title: title, username: username, password: passwordValue)
            return password
        }

    }
    override func saveClicked() {
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
    func updatePasswordField(_ suggested: String) {
        let field = fields.firstIndex(where: { $0.type == .password }) ?? 2
        fields[field].value = suggested
        view?.reloadData()
    }

    override func formButtonClicked() {
        router.openSuggestPasswordScreen() { [weak self] suggested in
            self?.updatePasswordField(suggested)
        }
    }

}
