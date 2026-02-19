//
//  FormFieldViewController.swift
//  record
//
//  Created by Esakkinathan B on 11/02/26.
//

import UIKit
import VTDB

class FormFieldViewController: UIViewController {
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.keyboardDismissMode = .onDrag
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
        return tableView
    }()
    
    var presenter: FormFieldPresenterProtocol!
    var onAdd: ((Persistable) -> Void)?
    var onEdit: ((Persistable) -> Void)?
    var previewUrl: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.background
        presenter.viewDidLoad()
        setUpNavigationBar()
        setUpContents()
        hideKeyboardWhenTappedAround()
    }

    func setUpContents() {
        view.add(tableView)
        
        tableView.dataSource = self

        tableView.register(FormSelectField.self, forCellReuseIdentifier: FormSelectField.identifier)
        tableView.register(FormTextField.self, forCellReuseIdentifier: FormTextField.identifier)
        tableView.register(FormDateField.self, forCellReuseIdentifier: FormDateField.identifier)
        tableView.register(FormFileUpload.self, forCellReuseIdentifier: FormFileUpload.identifier)
        tableView.register(FormTextView.self, forCellReuseIdentifier: FormTextView.identifier)
        tableView.register(FormPasswordField.self, forCellReuseIdentifier: FormPasswordField.myidentifier)
        tableView.register(FormTextFieldSelectField.self, forCellReuseIdentifier: FormTextFieldSelectField.identifier)
        tableView.register(ButtonTableViewCell.self, forCellReuseIdentifier: ButtonTableViewCell.identifier)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
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
        view.endEditing(true)
        presenter.saveClicked()
    }
}

extension FormFieldViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfFields()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let field = presenter.field(at: indexPath.row)
        var cell: UITableViewCell
        switch field.type {
        case .text:
            cell = textFieldCell(indexPath, field)
        case .password:
            cell = passwordFieldCell(indexPath, field)
        case .date:
            cell = dateFieldCell(indexPath, field)
        case .select:
            cell = selectCell(indexPath, field)
        case .textSelect:
            cell = textSelectCell(indexPath, field)
        case .textView:
            cell = textViewCell(indexPath,field)
        case .fileUpload:
            cell = fileUploadCell(indexPath, field)
        case .button:
            cell = buttonViewCell(indexPath, field)
        }
        return cell
    }
}

extension FormFieldViewController: FormFieldViewDelegate {
    
    func showError(_ message: String?) {
        if let msg = message {
            showToast(message: msg, type: .error)
        }
    }
    
    func reloadData() {
        tableView.reloadData()
    }
    
    func reloadField(at index: Int) {
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)

    }
    
    func dismiss() {
        dismiss(animated: true)
    }
    
    func configureToOpenDocument(previewUrl: URL) {
        self.previewUrl  = previewUrl
    }
    
    
}

extension FormFieldViewController: UIDocumentPickerDelegate {

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        print(url.path)
        presenter.didPickDocument(url: url)
    }
}

extension FormFieldViewController: DocumentNavigationDelegate {
    
    func push(_ vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
    func presentVC(_ vc: UIViewController) {
        present(vc, animated: true)
    }
}


extension FormFieldViewController {
    
    
    func isFieldRequired(field: FormField) -> Bool{
        return field.validators.contains(.required)
    }
    
    func getMaxValue(rules: [ValidationRules]) -> Int {
        for rule in rules {
            switch rule {
            case .maxLength(let value):
                return value
            case .exactLength(let value):
                return value
            default:
                continue
            }
        }
        return 30
    }

    
    func configureCell(cell: FormTextField,field: FormField, indexPath: IndexPath) -> FormTextField {
        cell.configure(title: field.label, text: field.value as? String, placeholder: field.placeholder, isRequired: isFieldRequired(field: field),  maxCount: getMaxValue(rules: field.validators))
        cell.textField.returnKeyType = field.returnType ?? .default
        cell.textField.keyboardType = field.keyboardMode ?? .alphabet
        
        cell.onValueChange = { [weak self] text in
            return self?.presenter.validateText(text: text, index: indexPath.row,rules: field.validators).errorMessage
        }
        
        return cell

    }

    
    
    func textFieldCell(_ indexPath: IndexPath, _ field: FormField) -> FormTextField {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: FormTextField.identifier, for: indexPath) as! FormTextField
        
        cell = configureCell(cell: cell, field: field, indexPath: indexPath)
        
        cell.onReturn = { [weak self] text in
            guard let self  = self else { return nil }
            let result = presenter.validateText(text: text, index: indexPath.row, rules: field.validators)
            if result.isValid {
                _ = cell.textField.resignFirstResponder()
                if field.gotoNextField{
                    let nextCell = getNextCell(indexPath: indexPath) as! FormTextField
                    _ = nextCell.textField.becomeFirstResponder()
                }
            }
            return result.errorMessage
        }
        return cell
    }
    
    func passwordFieldCell(_ indexPath: IndexPath, _ field: FormField) -> FormPasswordField {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: FormPasswordField.myidentifier, for: indexPath) as! FormPasswordField
        
        cell = configureCell(cell: cell, field: field, indexPath: indexPath) as! FormPasswordField
        cell.onReturn = { [weak self] text in
            guard let self  = self else { return nil }
            let result = presenter.validateText(text: text, index: indexPath.row,rules: field.validators)
            if result.isValid {
                _ = cell.textField.resignFirstResponder()
                if field.gotoNextField {
                    let nextCell = getNextCell(indexPath: indexPath) as! FormTextField
                    _ = nextCell.textField.becomeFirstResponder()
                }
            }
            return result.errorMessage
        }
        
        return cell
    }

    func dateFieldCell(_ indexPath: IndexPath, _ field: FormField) -> FormDateField {
        let cell = tableView.dequeueReusableCell(withIdentifier: FormDateField.identifier, for: indexPath) as! FormDateField
        
        cell.configure(title: field.label, date: field.value as? Date,isRequired: isFieldRequired(field: field))
        
        cell.onValueChange = { [weak self] date in
            self?.presenter.updateValue(date, at: indexPath.row)
            return nil
        }
        return cell

    }
    
    
    
    func getNextCell(indexPath: IndexPath) -> UITableViewCell? {
        let nextCell = self.tableView.cellForRow(at: IndexPath(row: indexPath.row + 1, section: indexPath.section ))
        return nextCell

    }
    
    func selectCell(_ indexPath: IndexPath, _ field: FormField) -> FormSelectField {
        let cell = tableView.dequeueReusableCell(withIdentifier: FormSelectField.identifier, for: indexPath) as! FormSelectField
        cell.configure(title: field.label, text: field.value as? String, isRequired: isFieldRequired(field: field))
        cell.onSelectClicked = { [weak self] in
            self?.presenter.selectClicked(at: indexPath.row)
        }
        return cell
    }
    
    func textSelectCell(_ indexPath: IndexPath, _ field: FormField) -> FormTextFieldSelectField {
        let cell = tableView.dequeueReusableCell(withIdentifier: FormTextFieldSelectField.identifier, for: indexPath) as! FormTextFieldSelectField
        
        cell.textField.returnKeyType = field.returnType ?? .default
        cell.textField.keyboardType = field.keyboardMode ?? .alphabet
        
        let selectValue = presenter.field(at: indexPath.row+1).value as? String ?? ""
        
        cell.configure(title: field.label, text: field.value as? String, placeholder: field.placeholder,selectedValue: selectValue, isRequired: isFieldRequired(field: field))
        
        cell.onTextValueChange = { [weak self] text in
            return self?.presenter.validateText(text: text, index: indexPath.row,rules: field.validators).errorMessage
        }
        cell.onReturn = { [weak self] text in
            guard let self  = self else { return nil }
            let result = presenter.validateText(text: text, index: indexPath.row,rules: field.validators)
            if result.isValid {
                _ = cell.textField.resignFirstResponder()
            }
            return result.errorMessage
        }
        
        cell.onSelectClicked = { [weak self] in
            self?.presenter.selectClicked(at: indexPath.row)
        }
        
        return cell

    }
     
    func fileUploadCell(_ indexPath: IndexPath, _ field: FormField) -> FormFileUpload {
        let cell = tableView.dequeueReusableCell(withIdentifier: FormFileUpload.identifier, for: indexPath) as! FormFileUpload
        
        cell.configure(title: field.label, filePath: field.value as? String, isRequired: isFieldRequired(field: field))
        
        cell.onUploadDocument = { [weak self] in
            self?.presenter.uploadDocument(at: indexPath.row)
        }
        cell.onViewDocument = { [weak self] in
            self?.presenter.viewDocument(at: indexPath.row)
        }
        cell.onRemoveDocument = { [weak self] in
            self?.presenter.removeDocument(at: indexPath.row)
        }
        return cell
    }
    
    func textViewCell(_ indexPath: IndexPath,_ field: FormField) -> FormTextView {
        let cell = tableView.dequeueReusableCell(withIdentifier: FormTextView.identifier, for: indexPath) as! FormTextView
        cell.configure(title: field.label, text: field.value as? String, isRequired: isFieldRequired(field: field))
        cell.textView.keyboardType = .default
        cell.onValueChange = { [weak self] text in
            return self?.presenter.validateText(text: text, index: indexPath.row, rules: field.validators).errorMessage
        }
        return cell
    }
    
    func buttonViewCell(_ indexPath: IndexPath, _ field: FormField) -> ButtonTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ButtonTableViewCell.identifier, for: indexPath) as! ButtonTableViewCell
        cell.configure(title: field.label)
        cell.onButtonClicked = { [weak self] in
            self?.presenter.formButtonClicked()
        }
        return cell
    }

}
