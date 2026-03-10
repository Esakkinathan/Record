//
//  AddDocumentPresenter.swift
//  record
//
//  Created by Esakkinathan B on 30/01/26.
//
import Foundation
import UIKit
import Vision
import PDFKit


class AddDocumentPresenter: FormFieldPresenter {
    
    var mode: DocumentFormMode
    var router: AddDocumentRouterProtocol
    let fileManager: AppFileManager
    let fetchUseCase: FetchDocumentsUseCaseProtocol
    var options: Set<String> = []
    init(view: FormFieldViewDelegate? = nil, router: AddDocumentRouterProtocol, mode: DocumentFormMode, fetchUseCase: FetchDocumentsUseCaseProtocol) {
        self.router = router
        self.mode = mode
        fileManager = AppFileManager()
        self.fetchUseCase = fetchUseCase
        super.init(view: view)
        options = fetchUseCase.fetchDocument()
    }
    func existing() -> Document? {
        if case let .edit(doc) = mode {
            if let file = doc.file {
                doc.file = DocumentThumbnailProvider.fullURL(from: file)
            }
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
                    validators: [.maxLength(1000)],
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
        //let options = DefaultDocument.getList()
        
        let selected = field.value as? String ?? DefaultDocument.defaultValue.rawValue
        options.insert(selected)
        router.openSelectVC(options: Array(options), selected: selected, addExtra: true, validator: field.validators) { [weak self] value in
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
        view?.reloadData()
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
                        print("updating teh value")
                        self.updateValues(model: model)
                        self.view?.stopLoading()
                        self.view?.reloadData()
                        self.view?.showToastVc(message: "Kindly verify the values in the field", type: .info)

                    } catch {
                        self.view?.stopLoading()
                        self.view?.showError(error.localizedDescription)
                    }
                    
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
        
//        func preprocessURL(urls: [URL]) {
//            var validUrl: [PDFDocument] = []
//            for url in urls {
//                guard let pdf = PDFDocument(url: url) else { continue }
//                if pdf.isLocked {
//                    view?.askForPassword(name: url.lastPathComponent) { [weak self] password, canAdd in
//                        if canAdd {
//                            if pdf.unlock(withPassword: password) {
//                                validUrl.append(pdf)
//                            } else {
//                                self?.view?.showError("Wrong password retry or cancel")
//                                )
//                            }
//                        } else {
//                            
//                        }
//                    }
//                } else {
//                    validUrl.append(pdf)
//                }
//            }
//        }


    }
/*
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
                        self.view?.stopLoading()
                        view?.reloadData()
                        view?.showToastVc(message: "Kindly verify the values in the field", type: .info)
                    case .failure(let error):
                        self.view?.stopLoading()
                        view?.showError(error.localizedDescription)
                    }
                    
                }
            } else {
                let data = PDFService().generatePDF(from: images)
                view?.stopLoading()
                saveFile(pdfData: data)
            }
        }

    }
 */
    override func processImages(from images: [UIImage]) {
        guard !images.isEmpty else { return }
        
        view?.showLoading()
        
        Task { [weak self] in
            guard let self else { return }
            
            let useOCR = await withCheckedContinuation { continuation in
                self.view?.showYesNoAlert { value in
                    continuation.resume(returning: value)
                }
            }
            
            if useOCR {
                do {
                    let model = try await DocumentOCRService().process(images: images)
                    await MainActor.run {
                        self.updateValues(model: model)
                        self.view?.stopLoading()
                        self.view?.reloadData()
                        self.view?.showToastVc(message: "Kindly verify the values in the field", type: .info)
                    }
                } catch {
                    await MainActor.run {
                        self.view?.stopLoading()
                        self.view?.showError(error.localizedDescription)
                    }
                }
            } else {
                let data = PDFService().generatePDF(from: images)
                await MainActor.run {
                    self.view?.stopLoading()
                    self.saveFile(pdfData: data)
                }
            }
        }
    }
    
}
