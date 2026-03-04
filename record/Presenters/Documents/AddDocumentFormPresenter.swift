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
    var maxFiles: Int  = 5
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
    func openCameraClicked() {}
    func processImages(from images: [UIImage]) {}
    func processFile(urls: [URL]) {}
}

class AddDocumentFormPresenter: FormFieldPresenter {
    
    var mode: DocumentFormMode
    var router: AddDocumentRouterProtocol
    let fileManager: AppFileManager
    init(view: FormFieldViewDelegate? = nil, router: AddDocumentRouterProtocol, mode: DocumentFormMode) {
        self.router = router
        self.mode = mode
        fileManager = AppFileManager()
        super.init(view: view)
    }
    func existing() -> Document? {
        if case let .edit(doc) = mode {
            return doc
        }
        return nil
    }

    func buildFields() {
        
        
        let existingDoc = existing()
        let isInitialBuild = fields.isEmpty
        
        let name: String
        let number: String?
        let expiryDate: Date?
        let file: String?
        let notes: String?
        
        if isInitialBuild {
            name = existingDoc?.name ?? DefaultDocument.defaultValue.rawValue
            number = existingDoc?.number
            expiryDate = existingDoc?.expiryDate
            file = existingDoc?.file
            notes = nil
        } else {
            name = field(of: .select)?.value as? String ?? DefaultDocument.defaultValue.rawValue
            number = field(of: .text)?.value as? String
            expiryDate = field(of: .date)?.value as? Date
            file = field(of: .fileUpload)?.value as? String
            notes = field(of: .textView)?.value as? String
        }
        
        let documentCase = DefaultDocument.valueOf(value: name)
        
        // MARK: - Build Fields Once
        
        var newFields: [FormField] = [
            FormField(
                label: "Name",
                type: .select,
                validators: [.required, .maxLength(30), .alphanumeric],
                gotoNextField: false,
                value: name
            ),
            FormField(
                label: "Number",
                type: .text,
                validators: documentCase.validationRules,
                gotoNextField: false,
                placeholder: "Enter Number",
                value: number,
                returnType: .next
            )
        ]
        
        if documentCase.hasExpiryDate {
            newFields.append(
                FormField(
                    label: "Expiry Date",
                    type: .date,
                    validators: documentCase == .custom ? [] : [.required],
                    gotoNextField: true,
                    value: expiryDate
                )
            )
        }
        
        newFields.append(
            FormField(
                label: "Document File",
                type: .fileUpload,
                validators: [],
                gotoNextField: false,
                value: file
            )
        )
        
        if case .add = mode {
            newFields.append(
                FormField(
                    label: "Notes",
                    type: .textView,
                    validators: [.maxLength(300)],
                    gotoNextField: false,
                    value: notes
                )
            )
        }
        
        fields = newFields
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
            let notes = field(of: .textView)?.value as? String
            return Document(id: 1,name: name, number: number, expiryDate: expiryDate, file: file,notes: notes)
        case .edit(let document):
            document.update(name: name, number: number, expiryDate: expiryDate, file: file)
            return document
        }
        
    }
    
    func saveFileLocally(_ sourceURL: URL, name: String, number: String) -> String? {

        var fileName = name.replacingOccurrences(of: " ", with: "")
        fileName = "\(name)_\(number)"
        let path = fileManager.saveFileLocally(sourceURL: sourceURL, directory: .docs, name: fileName)
        return path
        
    }
    
    func saveFile(pdfData: Data) {
        let url = fileManager.saveFile(pdfData: pdfData)
        guard let url = url else { return }
        updateFile(url: url)
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
    
    func updateFile(url: URL) {
        guard let index = fields.firstIndex(where: { $0.type == .fileUpload }) else { return }
        updateValue(url.path, at: index)
        view?.reloadField(at: index)
    }
        
    override func openCameraClicked(){
        router.openDocumentScanner()
    }
    
    override func selectClicked(at index: Int ) {
        let field = field(at: index)
        let options = DefaultDocument.getList()
        let selected = field.value as? String ?? DefaultDocument.defaultValue.rawValue
        //let validators = field.validators
        router.openSelectVC(options: options, selected: selected, addExtra: true, validator: field.validators) { [weak self] value in
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
    
    func updateValues(model: ExtractedDocumentModel) {
        updateValue(model.detectedType.rawValue, at: 0)
        buildFields()
        updateValue(model.documentNumber, at: 1)
        
        if let date = model.expiryDate {
            updateValue(date, at: 2)
        }
        saveFile(pdfData: model.pdfData)
    }
    
    override func processFile(urls: [URL]) {
        view?.showLoading()
        view?.showYesNoAlert() { [weak self] value in
            guard let self = self else { return }
            if value {
                Task {
                    do {
                        let model = try await DocumentOCRService().process(urls: urls)
                        self.updateValues(model: model)
                        self.view?.reloadData()
                        self.view?.showToastVc(message: "Kindly verify the values in the field", type: .info)

                    } catch {
                        self.view?.showError(error.localizedDescription)
                    }
                    self.view?.stopLoading()
                }

            } else {
                do {
                    let pdfData = try PDFMergerService().mergePDFs(from: urls)
                    self.saveFile(pdfData: pdfData)
                } catch {
                    self.view?.showError(error.localizedDescription)
                }
                self.view?.stopLoading()
            }
        }

    }
    
    override func processImages(from images: [UIImage]) {
        guard !images.isEmpty else {
            return
        }
        view?.showLoading()
        view?.showYesNoAlert() { [weak self] value in
            guard let self = self else { return }
            if value {
                DocumentOCRService().process(images: images) { [weak self] result in
                    
                    guard let self = self else {return}
                    switch result {
                    case .success(let model):
                        self.updateValues(model: model)
                        view?.reloadData()
                        view?.showToastVc(message: "Kindly verify the values in the field", type: .info)
                    case .failure(let error):
                        view?.showError(error.localizedDescription)
                    }
                    self.view?.stopLoading()
                }
            } else {
                let data = PDFService().generatePDF(from: images)
                view?.stopLoading()
                saveFile(pdfData: data)
            }
        }

    }
    
    //    func didPickDocuments(urls: [URL]) {
    //        view?.showLoading()
    //        view?.showYesNoAlert() { [weak self] value in
    //            guard let self = self else { return }
    //            if value {
    //                Task {
    //                    do {
    //                        let model = try await DocumentOCRService().process(urls: urls)
    //                        self.updateValue(model.detectedType.rawValue, at: 0)
    //                        self.buildFields()
    //                        self.updateValue(model.documentNumber, at: 1)
    //
    //                        if let date = model.expiryDate {
    //                            self.updateValue(date, at: 2)
    //                        }
    //                        self.saveFile(pdfData: model.pdfData)
    //
    //                        self.view?.reloadData()
    //                        self.view?.showToastVc(message: "Kindly verify the values in the field", type: .info)
    //
    //                    } catch {
    //                        self.view?.showError(error.localizedDescription)
    //                    }
    //                    self.view?.stopLoading()
    //                }
    //
    //            } else {
    //                do {
    //                    let pdfData = try PDFMergerService().mergePDFs(from: urls)
    //                    self.saveFile(pdfData: pdfData)
    //                    self.view?.reloadData()
    //                } catch {
    //                    self.view?.showError(error.localizedDescription)
    //                }
    //                self.view?.stopLoading()
    //            }
    //        }
    //    }

}
