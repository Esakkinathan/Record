//
//  AddPasswordProtocol.swift
//  record
//
//  Created by Esakkinathan B on 03/02/26.
//

protocol AddPasswordPresenterProtocol {
    var title: String {get}
    func field(at index: Int) -> PasswordFormField
    func numberOfFields() -> Int
    func updateValue(_ value: Any?, at index: Int)
    func saveClicked()
    func cancelClicked()
    func validateText(text: String, index: Int,rules: [ValidationRules]) -> ValidationResult
    func suggesPasswordClicked()
}

protocol AddPasswordViewDelegate: AnyObject {
    var onEdit: ((Password) -> Void)? { get set }
    var onAdd: ((Password) -> Void)? { get set}
    func showError(_ message: String?) 
    func reloadData()
    func dismiss()
}

protocol AddPasswordRouterProtocol {
    func openSuggestPasswordScreen(onApply: ((String) -> Void)?)
}
