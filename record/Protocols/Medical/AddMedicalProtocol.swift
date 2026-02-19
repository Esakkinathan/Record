//
//  AddMedicalProtocol.swift
//  record
//
//  Created by Esakkinathan B on 09/02/26.
//
/*
protocol AddMedicalPresenterProtocol {
    var title: String {get}
    func field(at index: Int) -> MedicalFormField
    func numberOfFields() -> Int
    func updateValue(_ value: Any?, at index: Int)
    func saveClicked()
    func cancelClicked()
    func selectClicked(at index: Int)
    func validateText(text: String, index: Int,rules: [ValidationRules]) -> ValidationResult
}

protocol AddMedicalViewDelegate: AnyObject {
    var onEdit: ((Medical) -> Void)? { get set }
    var onAdd: ((Medical) -> Void)? { get set}
    func showError(_ message: String?)
    func reloadData()
    func reloadField(at index: Int)
    func dismiss()
}
*/
protocol AddMedicalRouterProtocol {
    func openSelectVC(options: [String], selected: String, addExtra: Bool, onSelect: @escaping (String) -> Void )
}
