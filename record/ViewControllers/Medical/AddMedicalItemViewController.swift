//
//  A.swift
//  record
//
//  Created by Esakkinathan B on 10/02/26.
//

import UIKit
/*
class AddMedicalItemViewController: UIViewController {
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.keyboardDismissMode = .onDrag
        tableView.estimatedRowHeight = 40
        tableView.rowHeight = UITableView.automaticDimension
        return tableView
    }()
    
    var onEdit: ((MedicalItem) -> Void)?
    var onAdd: ((MedicalItem) -> Void)?
    var presenter: AddMedicalItemPresenterProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.background
        setUpNavigationBar()
        setUpContents()
        hideKeyboardWhenTappedAround()
    }
    
    func setUpNavigationBar() {
        title = presenter.title
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: IconName.cancel), style: AppConstantData.buttonStyle, target: self, action: #selector(cancelClicked))
        navigationItem .rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: IconName.checkmark), style: AppConstantData.buttonStyle, target: self, action: #selector(saveClicked))
    }
    
    func setUpContents() {
        
        view.add(tableView)
        
        tableView.dataSource = self
        
        tableView.register(FormTextField.self, forCellReuseIdentifier: FormTextField.identifier)
        tableView.register(FormTextFieldPickerField.self, forCellReuseIdentifier: FormTextFieldPickerField.identifier)
        tableView.register(FormSelectField.self, forCellReuseIdentifier: FormSelectField.identifier)
        
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

    }

    
    @objc func cancelClicked() {
        presenter.cancelClicked()
    }
    
    @objc func saveClicked() {
        presenter.saveClicked()
    }

}

extension AddMedicalItemViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfFields()
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let field = presenter.field(at: indexPath.row)
        var cell: UITableViewCell
        switch field.type {
        case .name:
            cell = textTableViewCell(indexPath: indexPath,field)
        case .instruction:
            let newCell = tableView.dequeueReusableCell(withIdentifier: FormSelectField.identifier, for: indexPath) as! FormSelectField
            newCell.configure(title: field.label, text: field.value as? String, isRequired: true)
            newCell.onSelectClicked = { [weak self] in
                self?.presenter.instructionOptionSelected(at: indexPath.row)
            }
            cell = newCell

        case .dosage:
            cell = textTableViewCell(indexPath: indexPath, field)
        case .schedule:
            let newCell = tableView.dequeueReusableCell(withIdentifier: FormSelectField.identifier, for: indexPath) as! FormSelectField
            newCell.configure(title: field.label, text: field.value as? String, isRequired: true)
            newCell.onSelectClicked = { [weak self] in
                self?.presenter.scheduleOptionSelected(at: indexPath.row)
            }
            cell = newCell
        case .duration:
            let newCell = tableView.dequeueReusableCell(withIdentifier: FormTextFieldPickerField.identifier, for: indexPath) as! FormTextFieldPickerField
            newCell.textField.returnKeyType = field.returnType
            newCell.textField.keyboardType = field.keyboardMode
            let durationTypeVaule = presenter.field(at: indexPath.row+1).value as? String ?? DurationType.day.rawValue
            newCell.configure(title: field.label, text: field.value as? String, placeholder: field.placeholder, selectedPicker: durationTypeVaule,isRequired: true)
            
            newCell.onTextValueChange = { [weak self] text in
                return self?.presenter.validateText(text: text, index: indexPath.row,rules: field.validators).errorMessage
            }
            newCell.onReturn = { [weak self] text in
                guard let self  = self else { return nil }
                let result = presenter.validateText(text: text, index: indexPath.row,rules: field.validators)
                if result.isValid {
                    _ = newCell.textField.resignFirstResponder()
                }
                return result.errorMessage

            }
            
            newCell.onPickerValueChange = { [weak self] text in
                self?.presenter.updateValue(text, at: indexPath.row+1)
            }
            cell = newCell

        }
        return cell
    }
}
extension AddMedicalItemViewController {
    func configureCell(cell: FormTextField,field: MedicalItemFormField, indexPath: IndexPath, isRequired: Bool = false) -> FormTextField {
        cell.configure(title: field.label, text: field.value as? String, placeholder: field.placeholder, isRequired: field.validators.contains(.required))
        cell.textField.returnKeyType = field.returnType
        cell.textField.keyboardType = field.keyboardMode
        
        cell.onValueChange = { [weak self] text in
            return self?.presenter.validateText(text: text, index: indexPath.row,rules: field.validators).errorMessage
        }
        
        return cell

    }

    func textTableViewCell(indexPath: IndexPath, _ field: MedicalItemFormField) -> FormTextField {
        var cell = tableView.dequeueReusableCell(withIdentifier: FormTextField.identifier, for: indexPath) as! FormTextField
        cell = configureCell(cell: cell, field: field, indexPath: indexPath, isRequired: true)
        cell.onReturn = { [weak self] text in
            guard let self  = self else { return nil }
            let result = presenter.validateText(text: text, index: indexPath.row,rules: field.validators)
            if result.isValid {
                _ = cell.textField.resignFirstResponder()
            }
            return result.errorMessage

        }
        return cell
    }
    

}

extension AddMedicalItemViewController: AddMedicalItemViewDelegate {
    func reloadData() {
        tableView.reloadData()
    }
    
    func showError(_ message: String?) {
        if let msg = message {
            showToast(message: msg, type: .error)
        }
    }
    
    func dismiss() {
        dismiss(animated: true)
    }
    
    func reloadField(at index: Int) {
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
}

extension AddMedicalItemViewController: DocumentNavigationDelegate {
    
    func push(_ vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
    func presentVC(_ vc: UIViewController) {
        present(vc, animated: true)
    }
}
*/
