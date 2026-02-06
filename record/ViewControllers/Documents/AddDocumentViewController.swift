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
    
    let tableView = UITableView()
    
    var selectedCategory = DocumentCategory.Default
    var document: Document!
    
    var documentAction = DocumentAction.add
    var documentName = ""
    var documentNumber = ""
    var documentDate : Date?
    var documentFile: URL?
    var onAdd: ((Document) -> Void)?
    var onEdit: ((Document) -> Void)?
        
    
    let addDocument = "Add Document"
    
    let enterNumber = "Enter Number"
    
    let enterName = "Enter Name"
    
    let addExpiryDate = "Add Expiry Date"

    let namePlaceholder = "Document Name"
    
    let numberPlaceholder = "Document Number"

    let selectName = "Select Document"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpNavigationBar()
        setUpContents()
    }
    func setUpContents() {
        view.basicSetUp(for: tableView)
        
        tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150

        tableView.register(FormSelectField.self, forCellReuseIdentifier: FormSelectField.identifier)
        tableView.register(FormTextField.self, forCellReuseIdentifier: FormTextField.identifier)
        tableView.register(FormDateField.self, forCellReuseIdentifier: FormDateField.identifier)
        tableView.register(FormFileUpload.self, forCellReuseIdentifier: FormFileUpload.identifier)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: PaddingSize.heightPadding),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: -PaddingSize.widthPadding),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: PaddingSize.widthPadding),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -PaddingSize.widthPadding)
        ])
    }
    func setUpNavigationBar() {
        title = addDocument
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: AppConstantData.cancel, style: AppConstantData.buttonStyle, target: self, action: #selector(cancelClicked))
        navigationItem .rightBarButtonItem = UIBarButtonItem(title: AppConstantData.save, style: AppConstantData.buttonStyle, target: self, action: #selector(saveClicked))
    }
    
    func configure(_ category: DocumentCategory, action: DocumentAction,  document: Document? = nil ) {
        selectedCategory = category
        documentAction = action
        if let doc = document {
            self.document = doc
            documentName = doc.name
            documentDate = doc.expiryDate
        }
    }
    
    @objc func cancelClicked() {
        dismiss(animated: true)
    }
    
    @objc func saveClicked() {
        dismiss(animated: true)
        let buildDocument = buildDocument()
        switch documentAction {
        case .add:
            onAdd?(buildDocument)
        case .edit:
            onEdit?(buildDocument)
        }
    }
    
    func buildDocument() -> Document {
        return Document(
            id: 1,
            name: getDocumentName(),
            number: getDocumentNumber(),
            expiryDate: documentDate,
            file: getDocumentFilePath(),
            type: selectedCategory)
    }

}

extension AddDocumentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        4
    }
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
extension AddDocumentViewController {
    func getDocumentName() -> String {
        let name: String
        switch selectedCategory {
        case .Default:
            name = documentName
        case .Custom:
            let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! FormTextField
            name = cell.enteredText
        }
        return name
    }
    
    func getDocumentNumber() -> String {
        let numberCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0))
        let number = (numberCell as! FormTextField).enteredText
        return number
    }
    func getDocumentFilePath() -> String? {
        guard let path = documentFile else { return nil }
        return handlePickedFile(path)
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
    
    func handlePickedFile(_ sourceURL: URL) -> String{
        let fileManager = FileManager.default

        let documentsDir = fileManager.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!
        let documentName = documentName.replacingOccurrences(of: " ", with: "_")
        let documentNumber = documentNumber
        let fileName: String
        if documentName.isEmpty && documentNumber.isEmpty{
            fileName = sourceURL.lastPathComponent
        } else if documentNumber.isEmpty{
            fileName = documentName + sourceURL.lastPathComponent
        } else {
            fileName = documentName + "_" + documentNumber + "." + sourceURL.pathExtension
        }
        let destinationURL = documentsDir.appendingPathComponent(fileName)

        do {
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }

            try fileManager.copyItem(at: sourceURL, to: destinationURL)

            return destinationURL.path

        } catch {
            print("File copy failed:", error)
            return ""
        }
    }

}

extension AddDocumentViewController {
}
