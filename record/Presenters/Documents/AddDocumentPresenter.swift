//
//  AddDocumentPresenter.swift
//  record
//
//  Created by Esakkinathan B on 30/01/26.
//
import Foundation
/*
class AddDocumentPresenter: AddDocumentPresenterProtocol {
    var fields: [DocumentFormField] = []
    weak var view: AddDocumentViewDelegate?
    let mode: DocumentFormMode
    var title: String {
        return mode.navigationTitle
    }
    var router: AddDocumentRouterProtocol
    
    init(view: AddDocumentViewDelegate? = nil, router: AddDocumentRouterProtocol, mode: DocumentFormMode) {
        self.view = view
        self.router = router
        self.mode = mode
        
        buildFields()
    }
    
    func field(at index: Int) -> DocumentFormField {
        return fields[index]
    }
    
    func field(of type: DocumentFormFieldType) -> DocumentFormField? {
        fields.first { $0.type == type }
    }

    
    func numberOfFields() -> Int {
        fields.count
    }
    
    func validateText(text: String, index: Int,rules: [ValidationRules] = []) -> ValidationResult {
        let result = Validator.Validate(input: text, rules: rules)
        if result.isValid {
            updateValue(text, at: index)
        }
        return result
    }

    func updateValue(_ value: Any?, at index: Int) {
        fields[index].value = value
    }
    
    func saveClicked() {
        if validateFields() {
            let document = buildDocument()

            switch mode {
            case .add:
                view?.onAdd?(document)
            case .edit:
                view?.onEdit?(document)
            }
            view?.dismiss()
        }
    }

    func validateFields() -> Bool{
        for field in fields {
            if  field.type ==  .number {
                let result = Validator.Validate(input: field.value as? String ?? "" , rules: field.validators)
                if !result.isValid {
                    view?.showError( "\(field.label) \(result.errorMessage?.replacingOccurrences(of: "This", with: "") ?? "")")
                    return result.isValid
                }
            }
        }
        return true
    }
    
    func cancelClicked() {
        view?.dismiss()
    }
    
    func buildFields() {
        let existing = existingDocument()
        if fields.isEmpty {
            fields = [
                DocumentFormField(label: "Name", placeholder: "Document Name", type:  .select, validators: [.required], value: existing?.name ?? DefaultDocument.defaultValue.rawValue),
                DocumentFormField(label: "Number", placeholder: "Document Number", type: .number, validators: DefaultDocument.defaultValue.validationRules, value: existing?.number),
                
//                DocumentFormField(label: "Expiry Date", placeholder: nil, type: .expiryDate, validators: [], value: existing?.expiryDate),
                DocumentFormField(label: "Document File", placeholder: nil, type: .fileUpload, validators: [], value: existing?.file)
            ]
        } else {
            let documentName = field(of: .select)?.value as? String ?? DefaultDocument.defaultValue.rawValue
            let documentCase = DefaultDocument.valueOf(value: field(of: .select)?.value as? String ?? "")
            let oldNumber = field(of: .number)?.value as? String ?? ""
            let expiryDate = field(of: .expiryDate)?.value as? Date
            let file = field(of: .fileUpload)?.value as? String
            
            fields = []
            fields.append(DocumentFormField(label: "Name", placeholder: "Document Name", type:  .select, validators: [.required], value: documentName))
            fields.append(DocumentFormField(label: "Number", placeholder: "Document Number", type: .number, validators: documentCase.validationRules, value: oldNumber))
            if documentCase.hasExpiryDate {
                fields.append(DocumentFormField(label: "Expiry Date", placeholder: nil, type: .expiryDate, validators: [], value: expiryDate))
            }
            fields.append(DocumentFormField(label: "Document File", placeholder: nil, type: .fileUpload, validators: [], value: file))
        }
        
    }
    
    func existingDocument() -> Document? {
        if case let .edit(doc) = mode {
            return doc
        }
        return nil
    }
    
    func buildDocument() -> Document {
        let name = field(of: .select)?.value as? String ?? DefaultDocument.defaultValue.rawValue
        let number = field(of: .number)?.value as? String ?? DefaultDocument.defaultValue.rawValue
        let expiryDate = field(of: .expiryDate)?.value as? Date
        var file: String?
        if let path = field(of: .fileUpload)?.value as? String {
            file = saveFileLocally(URL(filePath: path), name: name, number: number)
        }
        switch mode {
        case .add:
            return Document(id:1,name: name, number: number, expiryDate: expiryDate, file: file)
        case .edit(let document):
            document.update(name: name, number: number, expiryDate: expiryDate, file: file)
            return document
        }
        
    }
    
    func saveFileLocally(_ sourceURL: URL, name: String, number: String) -> String? {

        let fileManager = FileManager.default
        let documentsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let govtDocsDir = documentsDir.appendingPathComponent("GovtDocs", isDirectory: true)

        do {
            if !fileManager.fileExists(atPath: govtDocsDir.path) {
                try fileManager.createDirectory(at: govtDocsDir,withIntermediateDirectories: true,attributes: nil)
            }

            let docName = name.replacingOccurrences(of: " ", with: "")
            let fileName = "\(docName)_\(number).\(sourceURL.pathExtension)"
            let destinationURL = govtDocsDir.appendingPathComponent(fileName)

            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }

            try fileManager.copyItem(at: sourceURL, to: destinationURL)

            return destinationURL.path

        } catch {
            print("File save failed:", error)
            return nil
        }
    }

    func uploadDocument(at index: Int) {
        router.openDocumentPicker()
    }
    
    func viewDocument(at index: Int) {
        guard let path = fields[index].value as? String else { return }
        view?.configureToOpenDocument(previewUrl: URL(filePath: path))
        router.openDocumentViewer(filePath: path)

    }
    
    func removeDocument(at index: Int) {
        fields[index].value = nil
        view?.reloadField(at: index)
    }
    
    func didPickDocument(url: URL) {
        guard let index = fields.firstIndex(where: { $0.type == .fileUpload }) else { return }
        fields[index].value = url.path
        view?.reloadField(at: index)
    }
    
    func selectClicked(at index: Int) {
        let field = fields[index]
        let options = DefaultDocument.getList()
        let selected = field.value as? String ?? DefaultDocument.defaultValue.rawValue

        router.openSelectVC(options: options, selected: selected) { [weak self] value in
                self?.didSelectOption(value)
        }
    }
    
    func didSelectOption(_ value: String) {
        fields[0].value = value
        buildFields()
        view?.reloadData()
    }

}
*/
