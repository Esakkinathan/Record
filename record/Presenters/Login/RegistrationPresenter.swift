//
//  RegistrationPresenter.swift
//  record
//
//  Created by Esakkinathan B on 17/02/26.
//
import UIKit

struct LoginFormField {
    let label: String
    let type: FormFieldType
    let validators: [ValidationRules]
    var gotoNextField: Bool
    var placeholder: String?
    var value: Any?
    var returnType: UIReturnKeyType?
    var keyboardMode: UIKeyboardType?
    var imageName: String
}
class RegistrationPresenter: RegistrationFormPresenterProtocol {
    
    weak var view: RegistrationFormViewDelegate?
    let router: RegistrationRouterProtocol
    var fields: [LoginFormField] = []
    
    let getUseCase: GetUserUseCaseProtocol
    init(view: RegistrationFormViewDelegate? = nil, router: RegistrationRouterProtocol, getUseCase: GetUserUseCaseProtocol) {
        self.view = view
        self.router = router
        self.getUseCase = getUseCase
    }
    
    func viewDidLoad() {
        buildFields()
    }
    func buildFields() {
        fields = [
            LoginFormField(label: "Email", type: .text, validators: [.required, .email], gotoNextField: true, placeholder: "Enter Email Address", returnType: .next, keyboardMode: .emailAddress, imageName: "mail"),
            LoginFormField(label: "Name", type: .text, validators: [.required, .alphanumeric, .maxLength(30)], gotoNextField: true, placeholder: "Enter Name", returnType: .next, keyboardMode: .alphabet, imageName: "person.fill"),
            LoginFormField(label: "Password", type: .password, validators: [.required, .minLength(4), .maxLength(12),], gotoNextField: true,placeholder: "Enter Password", returnType: .next, keyboardMode: .alphabet,imageName: ""),
            LoginFormField(label: "Confirm Password", type: .password, validators: [.required, .minLength(4), .maxLength(12),], gotoNextField: true,placeholder: "Enter Confirm Password", returnType: .next, keyboardMode: .alphabet,imageName: ""),
            LoginFormField(label: "Create Account", type: .button, validators: [], gotoNextField: false, imageName: "save" ),
            LoginFormField(label: "Back to Login", type: .button, validators: [], gotoNextField: false, imageName: "navigation")
            
        ]
        view?.reloadData()
    }
    

    func numberOfFields() -> Int {
        print("number of field is asked \(fields.count)")
        return fields.count
    }
    
    func field(at index: Int) -> LoginFormField {
        print("return fields")
        return fields[index]
    }
    
    func validateText(text: String, index: Int, rules: [ValidationRules]) -> ValidationResult {
        let result = Validator.Validate(input: text, rules: rules)
        let isEmail = rules.contains(.email)
        if result.isValid {
            if isEmail {
                let emailUser: User? = getUseCase.execute(email: text)
                if emailUser != nil {
                    return ValidationResult(isValid: false, errorMessage: "Email Address already exists")
                }
            }
            updateValue(text, at: index)
        }
        return result

    }
    func updateValue(_ value: Any?, at index: Int) {
        fields[index].value = value
    }

    func getSaveButtonText() -> String {
        "Create Account"
    }
    
    func getNavigationButtonText() -> String {
        "Back to Login"
    }
    func validateFields() -> Bool{
        for field in fields {
            let result = Validator.Validate(input: field.value as? String ?? "" , rules: field.validators)
            if !result.isValid {
                let msg = "\(field.label) \(result.errorMessage?.replacingOccurrences(of: "This", with: "") ?? "")"
                view?.showToastVC(message: msg, type: .error)
                return result.isValid
            }
        }
        return true
    }

    func saveButtonClicked() {
        //
    }
    
    func navigationButtonClicked() {
        //
    }
    
    func getTitle() -> String {
        return "REGISTRATION"
    }
    
    
}
