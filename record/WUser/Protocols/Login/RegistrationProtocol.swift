//
//  RegistrationProtocol.swift
//  record
//
//  Created by Esakkinathan B on 17/02/26.
//
protocol RegistrationFormPresenterProtocol {
    func numberOfFields() -> Int
    func field(at index: Int) -> LoginFormField
    func validateText(text: String, index: Int,rules: [ValidationRules]) -> ValidationResult
    func getSaveButtonText() -> String
    func getNavigationButtonText() -> String
    func saveButtonClicked()
    func navigationButtonClicked()
    func getTitle() -> String
    func viewDidLoad()
}


protocol RegistrationFormViewDelegate: AnyObject {
    func reloadData()
    func showToastVC(message: String, type: ToastType)
    func reloadField(at index: Int) 
    func dismiss()

}

protocol RegistrationRouterProtocol {
    
}
