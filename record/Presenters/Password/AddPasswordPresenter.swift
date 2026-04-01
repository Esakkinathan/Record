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
            FormField(label: "Title", type: .text, validators: [.required,.maxLength(50), .singleAlphanumberAllowed], gotoNextField: true, placeholder: "Enter Title", value: existing?.title,returnType: .next),
            FormField(label: "Username", type: .text, validators: [.required, .maxLength(30), .singleAlphanumberAllowed], gotoNextField: true, placeholder: "Enter Username",value: existing?.username, returnType: .next, keyboardMode: .emailAddress),
            FormField(label: "Url", type: .text, validators: [.maxLength(100), .url], gotoNextField: true, placeholder: "Enter Url",value: existing?.url, returnType: .next, keyboardMode: .URL),
            FormField(label: "Password", type: .password, validators: [.required, .minLength(4), .maxLength(20),], gotoNextField: false, placeholder: "Enter Password", value: existing?.password,returnType: .done),
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
        let url = field(at: 2).value as? String
        let passwordValue = field(at: 3).value as? String ?? DefaultDocument.defaultValue.rawValue
        //print(url ?? "nothing found")
        switch mode {
        case .add:
            return Password(id: 1, title: title, username: username, password: passwordValue, url: url)
        case .edit(let password):
            password.update(title: title, username: username, password: passwordValue, url: url)
            return password
        }

    }
    override func saveClicked() {
        if validateFields() {
            let password = buildPassword()

            switch mode {
            case .add:
                view?.onAdd?(password)
                view?.showToastVc(message: "Data added successfully", type: .success)
            case .edit:
                view?.onEdit?(password)
                view?.showToastVc(message: "Data modified successfully", type: .success)

            }
            view?.dismiss()
        }
    }
    func updatePasswordField(_ suggested: String) {
        isEdited = true
        let field = fields.firstIndex(where: { $0.type == .password }) ?? 3
        fields[field].value = suggested
        view?.reloadData()
    }

    override func formButtonClicked() {
        router.openSuggestPasswordScreen() { [weak self] suggested in
            self?.updatePasswordField(suggested)
        }
    }

}
