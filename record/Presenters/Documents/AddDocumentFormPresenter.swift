//
//  AddDocumentPasswordViewController.swift
//  record
//
//  Created by Esakkinathan B on 14/02/26.
//

import Foundation
import UIKit
import Vision

class FormFieldPresenter: FormFieldPresenterProtocol {
    
    weak var view: FormFieldViewDelegate?
    var fields: [FormField] = []
    var isEdited: Bool = false
    init(view: FormFieldViewDelegate? = nil, ) {
        self.view = view
    }
    
    var title: String { "" }
    
    func field(at index: Int) -> FormField {
        return fields[index]
    }
    
    func field(of type: FormFieldType) -> FormField? {
        fields.first { $0.type == type }
    }

    func numberOfFields() -> Int {
        return fields.count
    }
    
    func updateValue(_ value: Any?, at index: Int) {
        isEdited = true
        fields[index].value = value
    }
    
    func viewDidLoad() {
        //
    }
    
    
    
    func validateText(text: String, index: Int, rules: [ValidationRules]) -> ValidationResult {
        isEdited = true
        let result = Validator.Validate(input: text, rules: rules)
        if result.isValid {
            updateValue(text, at: index)
        }
        return result
    }
    func recognizeText(from image: UIImage){}
    
    func cancelClicked() {
        if isEdited{
            view?.showExitAlert()
        } else {
            exitScreen()
        }
        
    }
    
    func exitScreen() {
        view?.dismiss()
    }
    
    func saveClicked() {
        //
    }
    
    func validateFields() -> Bool{
        for field in fields {
            if field.type == .date {
                let input = field.value as? Date
                let result = Validator.Validate(input: input?.toString() ?? "" , rules: field.validators)
                if !result.isValid {
                    view?.showError( "\(field.label) \(result.errorMessage?.replacingOccurrences(of: "This", with: "") ?? "")")
                    return result.isValid
                }
            } else {
                let result = Validator.Validate(input: field.value as? String ?? "" , rules: field.validators)
                if !result.isValid {
                    view?.showError( "\(field.label) \(result.errorMessage?.replacingOccurrences(of: "This", with: "") ?? "")")
                    return result.isValid
                }
            }
        }
        return true
    }
    
    func didSelectOption(at index: Int,_ value: String){}
    func selectClicked(at index: Int){
    }
    func formButtonClicked(){}
    
    func uploadDocument(at index: Int, type: DocumentType){}
    func viewDocument(at index: Int){}
    func removeDocument(at index: Int){}
    func didPickDocument(url: URL){}
    func saveImage(_ image: UIImage) {}
    func openCameraClicked() {}
    func processImages(from images: [UIImage]) {}
    func didPickDocuments(urls: [URL]) {}

}

class AddDocumentFormPresenter: FormFieldPresenter {
    
    var mode: DocumentFormMode
    var router: AddDocumentRouterProtocol
    
    init(view: FormFieldViewDelegate? = nil, router: AddDocumentRouterProtocol, mode: DocumentFormMode) {
        self.router = router
        self.mode = mode
        super.init(view: view)
    }
    func existing() -> Document? {
        if case let .edit(doc) = mode {
            return doc
        }
        return nil
    }

    func buildFields() {
        let existing = existing()
        let existingCase: DefaultDocument = DefaultDocument.valueOf(value: existing?.name)
        if fields.isEmpty {
            fields = [
                FormField(label: "Name", type: .select, validators: [.required], gotoNextField: false, value: existing?.name ?? DefaultDocument.defaultValue.rawValue),
                FormField(label: "Number", type: .text, validators: existingCase.validationRules, gotoNextField: false,  placeholder: "Enter Number", value: existing?.number,returnType: .next)
            ]
            if existingCase.hasExpiryDate {
                fields.append(FormField(label: "Expiry Date", type: .date, validators: [.required], gotoNextField: false, value: existing?.expiryDate))
            }
            fields.append(FormField(label: "Document File", type: .fileUpload, validators: [], gotoNextField: false, value: existing?.file))
        } else {
            let name = field(of: .select)?.value as? String ?? DefaultDocument.defaultValue.rawValue
            let documentCase = DefaultDocument.valueOf(value: name)
            let oldNumber = field(of: .text)?.value as? String ?? ""
            let expiryDate = field(of: .date)?.value as? Date
            let file = field(of: .fileUpload)?.value as? String
            fields = []
            fields = [
                FormField(label: "Name", type: .select, validators: [.required], gotoNextField: false, value: name),
                FormField(label: "Number", type: .text, validators: documentCase.validationRules, gotoNextField: false,  placeholder: "Enter Number", value: oldNumber,returnType: .next)
            ]
            if documentCase.hasExpiryDate {
                fields.append(FormField(label: "Expiry Date", type: .date, validators: [.required], gotoNextField: false, value: expiryDate))
            }
            fields.append(FormField(label: "Document File", type: .fileUpload, validators: [], gotoNextField: false, value: file))
        }
    }
    
    override var title: String {
        return mode.navigationTitle
    }
        
    override func viewDidLoad() {
        buildFields()
    }
    
    func buildDocument() -> Document {
        let name = field(of: .select)?.value as? String ?? DefaultDocument.defaultValue.rawValue
        let number = field(of: .text)?.value as? String ?? DefaultDocument.defaultValue.rawValue
        let expiryDate = field(of: .date)?.value as? Date
        var file: String?
        if let path = field(of: .fileUpload)?.value as? String {
            file = saveFileLocally(URL(filePath: path), name: name, number: number)
        }
        switch mode {
        case .add:
            return Document(id: 1,name: name, number: number, expiryDate: expiryDate, file: file)
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
    override func saveImage(_ image: UIImage) {
        
        guard let data = image.jpegData(compressionQuality: 0.8) else { return  }
        
        let fileName = UUID().uuidString + ".jpg"
        
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName)
        
        do {
            try data.write(to: tempURL)
            print("Temp saved at:", tempURL)
            didPickDocument(url: tempURL)
        } catch {
            print("Error saving temp image:", error)
            return
        }

    }
    
    func saveFile(pdfData: Data) {
        let name = UUID().uuidString + ".pdf"
        
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(name)
        
        do {
            try pdfData.write(to: tempURL)
            print("Temp saved at:", tempURL)
            didPickDocument(url: tempURL)
        } catch {
            print("Error saving temp image:", error)
            return
        }
    }
    
    override func uploadDocument(at index: Int, type: DocumentType) {
        switch type {
        case .pdf:
            router.openDocumentPicker(type: type)
        case .image:
            router.openGallery()
        }
        
    }
    
    override func viewDocument(at index: Int) {
        guard let path = fields[index].value as? String else { return }
        view?.configureToOpenDocument(previewUrl: URL(filePath: path))
        router.openDocumentViewer(filePath: path)

    }
    
    override func removeDocument(at index: Int) {
        updateValue(nil, at: index)
        view?.reloadField(at: index)
    }
    
    override func didPickDocument(url: URL) {
        guard let index = fields.firstIndex(where: { $0.type == .fileUpload }) else { return }
        updateValue(url.path, at: index)
        view?.reloadField(at: index)
    }
    
    override func didPickDocuments(urls: [URL]) {
        let merger = PDFMergerService()
        do {
            let data = try merger.mergePDFs(from: urls)
            saveFile(pdfData: data)
        } catch {
            view?.showError(error.localizedDescription)
        }
    }
    
    override func openCameraClicked(){
        router.openDocumentScanner()
        //view?.openScanner()
    }
    
    override func selectClicked(at index: Int ) {
        let field = field(at: index)
        let options = DefaultDocument.getList()
        let selected = field.value as? String ?? DefaultDocument.defaultValue.rawValue
        
        router.openSelectVC(options: options, selected: selected, addExtra: true) { [weak self] value in
            self?.didSelectOption(at: index,value)
        }
    }
    
    override func didSelectOption(at index: Int,_ value: String) {
        fields[index].value = value
        buildFields()
        view?.reloadData()
    }
    
    
    override func saveClicked() {
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
    
    override func processImages(from images: [UIImage]) {
        guard !images.isEmpty else {
            return
        }
        view?.showLoading()
        DocumentOCRService().process(images: images) { [weak self] result in
            
            guard let self = self else {return}
            print("updation starts")
            switch result {
            case .success(let model):
                self.updateValue(model.detectedType.rawValue, at: 0)
                self.buildFields()
                self.view?.reloadData()
                self.updateValue(model.documentNumber, at: 1)
                
                if let date = model.expiryDate {
                    updateValue(date, at: 2)
                }
                self.saveFile(pdfData: model.pdfData)
                self.view?.stopLoading()
                view?.reloadData()
                view?.showToastVc(message: "Kindly verify the values in the field", type: .info)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
    }
}
