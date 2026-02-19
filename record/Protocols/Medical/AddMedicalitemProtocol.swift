//
//  AddMedicalitemProtocol.swift
//  record
//
//  Created by Esakkinathan B on 10/02/26.
//
/*
protocol AddMedicalItemPresenterProtocol {
    var title: String {get}
    func field(at index: Int) -> MedicalItemFormField
    func numberOfFields() -> Int
    func updateValue(_ value: Any?, at index: Int)
    func saveClicked()
    func cancelClicked()
    func validateText(text: String, index: Int,rules: [ValidationRules]) -> ValidationResult
    func instructionOptionSelected(at index: Int)
    func scheduleOptionSelected(at index: Int)
}

protocol AddMedicalItemViewDelegate: AnyObject {
    var onEdit: ((MedicalItem) -> Void)? { get set }
    var onAdd: ((MedicalItem) -> Void)? { get set}
    func showError(_ message: String?)
    func reloadData()
    func reloadField(at index: Int)
    func dismiss()

}
*/
protocol AddMedicalItemRouterProtocol {
    func openSelectVC(options: [String], selected: String, addExtra: Bool,onSelect: @escaping (String) -> Void )
    
    func openMultiSelectVC(options: [String], selected: [String], onSelect: @escaping ([String]) -> Void)
}
