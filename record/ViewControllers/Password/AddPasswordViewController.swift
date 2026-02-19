//
//  AddPasswordViewController.swift
//  record
//
//  Created by Esakkinathan B on 03/02/26.
//


import UIKit
/*
class AddPasswordViewController: UIViewController {
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.keyboardDismissMode = .onDrag
        tableView.estimatedRowHeight = 40
        tableView.rowHeight = UITableView.automaticDimension
        return tableView
    }()
    
    var onEdit: ((Password) -> Void)?
    var onAdd: ((Password) -> Void)?
    var presenter: AddPasswordPresenterProtocol!
    
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

    @objc func cancelClicked() {
        presenter.cancelClicked()
    }
    
    @objc func saveClicked() {
        presenter.saveClicked()
    }
    
    func setUpContents() {
        
        view.add(tableView)
        
        tableView.dataSource = self
        tableView.register(FormTextField.self, forCellReuseIdentifier: FormTextField.identifier)
        tableView.register(FormPasswordField.self, forCellReuseIdentifier: FormPasswordField.myidentifier)
        tableView.register(ButtonTableViewCell.self, forCellReuseIdentifier: ButtonTableViewCell.identifier)
        
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

    }

    

}

extension AddPasswordViewController: UITableViewDataSource {
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
            cell = textFieldCell(indexPath,field)
        case .username:
            cell = textFieldCell(indexPath,field)
        case .password:
            cell = passwordFieldCell(indexPath,field)
        case .button:
            let newCell = tableView.dequeueReusableCell(withIdentifier: ButtonTableViewCell.identifier, for: indexPath) as! ButtonTableViewCell
            newCell.configure(title: field.label)
            newCell.onButtonClicked = { [weak self] in
                self?.presenter.suggesPasswordClicked()
            }
            cell = newCell
        }
        return cell
    }
    
}

extension AddPasswordViewController {
    
    func configureCell(cell: FormTextField,field: PasswordFormField, indexPath: IndexPath) -> FormTextField {
        cell.configure(title: field.label, text: field.value as? String, placeholder: field.placeholder, isRequired: true)
        cell.textField.returnKeyType = field.returnType
        cell.textField.keyboardType = field.keyboardMode
        
        cell.onValueChange = { [weak self] text in
            return self?.presenter.validateText(text: text, index: indexPath.row,rules: field.validators).errorMessage
        }
        
        return cell

    }
    
    func textFieldCell(_ indexPath: IndexPath, _ field: PasswordFormField) -> FormTextField {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: FormTextField.identifier, for: indexPath) as! FormTextField
        cell = configureCell(cell: cell, field: field, indexPath: indexPath)
        
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
    
    func getNextCell(indexPath: IndexPath) -> UITableViewCell {
        let nextCell = self.tableView.cellForRow(at: IndexPath(row: indexPath.row + 1, section: indexPath.section ))
        return nextCell!

    }

    
    func passwordFieldCell(_ indexPath: IndexPath, _ field: PasswordFormField) -> FormPasswordField {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: FormPasswordField.myidentifier, for: indexPath) as! FormPasswordField
        cell = configureCell(cell: cell, field: field, indexPath: indexPath) as! FormPasswordField
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

extension AddPasswordViewController: AddPasswordViewDelegate {
    func dismiss() {
        dismiss(animated: true)
    }
    func reloadData() {
        tableView.reloadData()
    }
    func showError(_ message: String?) {
        if let msg = message {
            showToast(message: msg, type: .error)
        }
    }

}


extension AddPasswordViewController: DocumentNavigationDelegate {
    func push(_ vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
    func presentVC(_ vc: UIViewController) {
        vc.modalPresentationStyle = .formSheet
        vc.preferredContentSize = .init(width: 200, height: 500)
        present(vc, animated: true)
    }
}
*/
