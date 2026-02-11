//
//  AddMedicalViewController.swift
//  record
//
//  Created by Esakkinathan B on 09/02/26.
//
import UIKit

class AddMedicalViewController: UIViewController {
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.keyboardDismissMode = .onDrag
        tableView.estimatedRowHeight = 40
        tableView.rowHeight = UITableView.automaticDimension
        return tableView
    }()

    var onEdit: ((Medical) -> Void)?
    var onAdd: ((Medical) -> Void)?
    var presenter: AddMedicalPresenterProtocol!

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
        tableView.register(FormDateField.self, forCellReuseIdentifier: FormDateField.identifier)
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

extension AddMedicalViewController: UITableViewDataSource {
    
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
        case .title:
            cell = textTableViewCell(indexPath: indexPath, field)
        case .type:
            let newCell = tableView.dequeueReusableCell(withIdentifier: FormSelectField.identifier, for: indexPath) as! FormSelectField
            newCell.configure(title: field.label, text: field.value as? String, isRequired: true)
            newCell.onSelectClicked = { [weak self] in
                self?.presenter.selectClicked(at: indexPath.row)
            }
            cell = newCell

        case .hospital:
            cell = textTableViewCell(indexPath: indexPath, field)
        case .doctor:
            var newCell = tableView.dequeueReusableCell(withIdentifier: FormTextField.identifier, for: indexPath) as! FormTextField
            newCell = configureCell(cell: newCell, field: field, indexPath: indexPath)
            newCell.onReturn = { [weak self] text in
                guard let self  = self else { return nil }
                let result = presenter.validateText(text: text, index: indexPath.row,rules: field.validators)
                if result.isValid {
                    _ = newCell.textField.resignFirstResponder()
                }
                return result.errorMessage
            }
            cell = newCell
        case .date:
            let newCell = tableView.dequeueReusableCell(withIdentifier: FormDateField.identifier, for: indexPath) as! FormDateField
            
            newCell.configure(title: field.label, date: field.value as? Date)
            
            newCell.onValueChange = { [weak self] date in
                self?.presenter.updateValue(date, at: indexPath.row)
                return nil
            }
            cell = newCell

        }
        return cell
    }

}
extension AddMedicalViewController {
    func configureCell(cell: FormTextField,field: MedicalFormField, indexPath: IndexPath, isRequired: Bool = false) -> FormTextField {
        cell.configure(title: field.label, text: field.value as? String, placeholder: field.placeholder, isRequired: field.validators.contains(.required))
        cell.textField.returnKeyType = field.returnType
        cell.textField.keyboardType = field.keyboardMode
        
        cell.onValueChange = { [weak self] text in
            return self?.presenter.validateText(text: text, index: indexPath.row,rules: field.validators).errorMessage
        }
        
        return cell

    }

    func textTableViewCell(indexPath: IndexPath, _ field: MedicalFormField) -> FormTextField {
        var cell = tableView.dequeueReusableCell(withIdentifier: FormTextField.identifier, for: indexPath) as! FormTextField
        cell = configureCell(cell: cell, field: field, indexPath: indexPath, isRequired: true)
        cell.onReturn = { [weak self] text in
            guard let self  = self else { return nil }
            let result = presenter.validateText(text: text, index: indexPath.row,rules: field.validators)
            if result.isValid {
                _ = cell.textField.resignFirstResponder()
                let nextCell = getNextCell(indexPath: indexPath) as! FormTextField
                _ = nextCell.textField.becomeFirstResponder()
            }
            return result.errorMessage

        }
        return cell
    }
}

extension AddMedicalViewController {
    func getNextCell(indexPath: IndexPath) -> UITableViewCell {
        let nextCell = self.tableView.cellForRow(at: IndexPath(row: indexPath.row + 1, section: indexPath.section ))
        return nextCell!

    }

}

extension AddMedicalViewController: AddMedicalViewDelegate {
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


extension AddMedicalViewController: DocumentNavigationDelegate {
    
    func push(_ vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
    func presentVC(_ vc: UIViewController) {
        present(vc, animated: true)
    }
}
