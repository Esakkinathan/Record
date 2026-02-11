//
//  AddDocumentViewController.swift
//  record
//
//  Created by Esakkinathan B on 25/01/26.
//

import UIKit
internal import UniformTypeIdentifiers
import QuickLook

class AddDocumentViewController: UIViewController {
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.keyboardDismissMode = .interactive
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
        return tableView
    }()
    
    var presenter: AddDocumentPresenterProtocol!
    var onAdd: ((Document) -> Void)?
    var onEdit: ((Document) -> Void)?
    var previewUrl: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.background
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
        presenter.saveClicked()
    }
    
}

extension AddDocumentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfFields()
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        let field = presenter.field(at: indexPath.row)
        switch field.type {
            
        case .select:
            let newCell = tableView.dequeueReusableCell(withIdentifier: FormSelectField.identifier, for: indexPath) as! FormSelectField
            newCell.configure(field: field, isRequired: true)
            newCell.onSelectClicked = { [weak self] in
                self?.presenter.selectClicked(at: indexPath.row)
            }
            cell = newCell
                        
        case .number:
            
            let newCell = tableView.dequeueReusableCell(withIdentifier: FormTextField.identifier, for: indexPath) as! FormTextField
            newCell.configure(field: field,isRequired: true)
            
            newCell.onValueChange = { [weak self] text in
                return self?.presenter.validateText(text: text, index: indexPath.row,rules: field.validators).errorMessage
            }
            
            newCell.onReturn = { [weak self] text in
                guard let self  = self else { return "" }
                let result = presenter.validateText(text: text, index: indexPath.row,rules: field.validators)
                if result.isValid {
                    _ = newCell.textField.resignFirstResponder()
                }
                return result.errorMessage
            }
            
            cell = newCell
            
        case .expiryDate:
            let newCell = tableView.dequeueReusableCell(withIdentifier: FormDateField.identifier, for: indexPath) as! FormDateField
            
            newCell.configure(field: field)
            
            newCell.onValueChange = { [weak self] date in
                self?.presenter.updateValue(date, at: indexPath.row)
                return nil
            }
            cell = newCell
            
        case .fileUpload:
            let newCell = tableView.dequeueReusableCell(withIdentifier: FormFileUpload.identifier, for: indexPath) as! FormFileUpload
            
            newCell.configure(field: field)
            
            newCell.onUploadDocument = { [weak self] in
                self?.presenter.uploadDocument(at: indexPath.row)
            }
            newCell.onViewDocument = { [weak self] in
                self?.presenter.viewDocument(at: indexPath.row)
            }
            newCell.onRemoveDocument = { [weak self] in
                self?.presenter.removeDocument(at: indexPath.row)
            }
            
            cell = newCell
            
        }
        return cell
    }
    
}

extension AddDocumentViewController: DocumentNavigationDelegate {
    
    func push(_ vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
    func presentVC(_ vc: UIViewController) {
        present(vc, animated: true)
    }
}


extension AddDocumentViewController: AddDocumentViewDelegate {
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
extension AddDocumentViewController: UIDocumentPickerDelegate {

    func documentPicker(
        _ controller: UIDocumentPickerViewController,
        didPickDocumentsAt urls: [URL]
    ) {
        guard let url = urls.first else { return }
        presenter.didPickDocument(url: url)
    }
}

extension AddDocumentViewController: QLPreviewControllerDataSource {
    
    func configureToOpenDocument(previewUrl: URL) {
        self.previewUrl  = previewUrl
    }
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> any QLPreviewItem {
            return previewUrl! as QLPreviewItem
    }

}

/*
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        switch indexPath.row {
        case 0:
            switch selectedCategory {
                
            case .Default:
                let newCell: FormSelectField
                
                switch documentAction {
                case .add:
                    newCell = pickerTableViewCell(title: selectName, isRequired: true)
                case .edit:
                    newCell = pickerTableViewCell(title: selectName, text: document.name,isRequired: true)
                }
                
            cell = newCell
                
            case .Custom:
                var newCell: FormTextField
                switch documentAction {
                case .add:
                    newCell = textFieldTableViewCell(title: enterName,placeHolder: namePlaceholder, isRequired: true)
                case .edit:
                    newCell = textFieldTableViewCell(title: enterName,text: document.name ,placeHolder: namePlaceholder, isRequired: true)
                }
                newCell.textField.returnKeyType = .next
                newCell.onReturn = { [weak self] in
                    let nextCell = self?.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! FormTextField
                    _ = nextCell.textField.becomeFirstResponder()
                }
                cell = newCell

            }
        case 1:
            var newCell: FormTextField
            switch documentAction {
            case .add:
                newCell = textFieldTableViewCell(title: enterNumber, placeHolder: numberPlaceholder, isRequired: true)
            case .edit:
                newCell = textFieldTableViewCell(title: enterNumber, text: document.number,placeHolder: numberPlaceholder, isRequired: true)
            }

            newCell.textField.returnKeyType = .done
            
            newCell.onReturn = { [weak self] in
                self?.view.endEditing(true)
            }
            
            cell = newCell

        case 2:
            let newCell: FormDateField
            switch documentAction {
            case .add:
                newCell = dateTableViewCell(title: addExpiryDate)
            case .edit:
                newCell = dateTableViewCell(title: addExpiryDate,date: document.expiryDate)
                
            }
            newCell.onDateChange = { [weak self] date in
                guard let self = self else { return }
                documentDate = date
            }
            cell = newCell
        case 3:
            let newCell: FormFileUpload
            switch documentAction {
            case .add:
                newCell = fileUploadTableViewCell(title: addDocument)
            case .edit:
                newCell = fileUploadTableViewCell(title: addDocument,filePath: document.file)
            }
            newCell.onUploadDocument = { [weak self] in
            guard let self = self else {return}
            let picker = UIDocumentPickerViewController(
                forOpeningContentTypes: [.pdf, .image],
                asCopy: true
            )
            picker.delegate = self
            self.present(picker, animated: true)
            }
            cell = newCell
        default:
            cell = UITableViewCell()
        }
        return cell
    }

extension AddDocumentViewController {
    
    func pickerTableViewCell(title: String, text: String? = nil, isRequired: Bool = false) -> FormSelectField {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: FormSelectField.identifier) as! FormSelectField
        cell.configure(title: title, text: text, isRequired: isRequired)
        
        return cell
    }
    
    func textFieldTableViewCell(title: String,text: String? = nil, placeHolder: String, isRequired: Bool = false) -> FormTextField {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: FormTextField.identifier) as! FormTextField
        cell.configure(title: title,text: text ,placeholder: placeHolder,isRequired: isRequired)
        return cell

    }
    func dateTableViewCell(title: String, date: Date? = nil, isRequired: Bool = false) -> FormDateField {
        
        let cell  = tableView.dequeueReusableCell(withIdentifier: FormDateField.identifier) as! FormDateField
        cell.configure(title: title,date: date, isRequired: isRequired)
        return cell
    }
    
    func fileUploadTableViewCell(title: String, filePath: String? = nil, isRequired: Bool = false) -> FormFileUpload {
        let cell = tableView.dequeueReusableCell(withIdentifier: FormFileUpload.identifier) as! FormFileUpload
        cell.configure(title: title,filePath: filePath,isRequired: isRequired)
        return cell
    }

}
extension AddDocumentViewController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController,
                        didPickDocumentsAt urls: [URL]) {

        guard let sourceURL = urls.first else { return }
        documentFile = sourceURL
        let fileCell = tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as! FormFileUpload
        fileCell.configureDocument(filePath: sourceURL.path)
    }
    

}
*/
