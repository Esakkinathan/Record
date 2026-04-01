//
//  AddMedicalPresenter.swift
//  record
//
//  Created by Esakkinathan B on 09/02/26.
//

import UIKit

class AddMedicalPresenter: FormFieldPresenter {
    let router: AddMedicalRouterProtocol
    let mode: MedicalFormMode
    var doctors: Set<String>
    var hospitals: Set<String> = Set()
    let fetchUseCase: FetchMedicalUseCase
    let fileManager: AppFileManager
    init(view: FormFieldViewDelegate? = nil, router: AddMedicalRouterProtocol, mode: MedicalFormMode,fetchUseCase: FetchMedicalUseCase ) {
        self.router = router
        self.mode = mode
        self.fetchUseCase = fetchUseCase
        doctors = fetchUseCase.fetchDoctors()
        hospitals = fetchUseCase.fetchHospitals()
        fileManager = AppFileManager()
        super.init(view: view)
        doctors.insert(AppConstantData.none)
        hospitals.insert(AppConstantData.none)
    }
    
    func existing() -> Medical? {
        if case let .edit(medical) = mode {
            if let file = medical.receipt {
                medical.receipt = DocumentThumbnailProvider.fullURL(from: file)
            }
            return medical
        }
        return nil
    }

    func buildFields() {
        let existing = existing()
        
        fields = [
            FormField(label: "Type", type: .select, validators: [.required], gotoNextField: false, value: existing?.type.rawValue ?? MedicalType.checkup.rawValue),
            FormField(label: "Title", type: .text, validators: [.required, .maxLength(50)], gotoNextField: false, placeholder: "Enter Title", value: existing?.title,returnType: .next,),
            FormField(label: "Diagonsed At", type: .date, validators: [.required], gotoNextField: false, value: existing?.date),
            FormField(label: "Hospital", type: .select, validators: [.maxLength(100), .singleAlphanumberAllowed], gotoNextField: true, value: existing?.hospital ?? AppConstantData.none, returnType: .next),
            FormField(label: "Doctor", type: .select, validators: [.maxLength(50), .singleAlphanumberAllowed], gotoNextField: false, value: existing?.doctor ?? AppConstantData.none, returnType: .done),
            FormField(label: "Medical Reciept", type: .fileUpload, validators: [], gotoNextField: false, value: existing?.receipt),
        ]
    }
    override var title: String {
        return mode.navigationTitle
    }
    
    override func viewDidLoad() {
        buildFields()
    }
    
    func buildMedical() -> Medical {
        let type = field(at: 0).value as? String ?? MedicalType.defaultValue.rawValue
        let title = field(at: 1).value as? String ?? MedicalType.defaultValue.rawValue
        let medicalType = MedicalType(rawValue: type) ?? MedicalType.defaultValue
        let recordDate = field(at: 2).value as? Date ?? Date()
        let hospitalData = field(at: 3).value as? String
        let hospital: String? = hospitalData == AppConstantData.none ? nil : hospitalData
        let doctorData = field(at: 4).value as? String
        let doctor: String? = doctorData == AppConstantData.none ? nil : doctorData
        var file: String?
        let date = Date().timeIntervalSince1970
        if let path = field(of: .fileUpload)?.value as? String {
            file = saveFileLocally(URL(filePath: path), name: "\(title)_\(date)")
        }
        switch mode {
        case .add:
            return Medical(id: 1, title: title, type: medicalType,hospital: hospital, doctor: doctor, date: recordDate.start,receipt: file)
        case .edit(let medical):
            medical.update(title: title, type: medicalType, hospital: hospital,doctor: doctor,date: recordDate.start, receipt: file)
            return medical
        }
    }
    
    func saveFileLocally(_ sourceURL: URL, name: String) -> String? {
        let fileName = name.replacingOccurrences(of: " ", with: "")
        let path = fileManager.saveFileLocally(sourceURL: sourceURL, directory: .medicalReciept, name: fileName)
        return path
    }
    
    override func openCameraClicked(){
        router.openCamera()
    }
    
    func saveFile(pdfData: Data) {
        let url = fileManager.saveFile(pdfData: pdfData)
        guard let url = url else { return }
        updateFile(url: url)
    }
    
    override func processFile(urls: [URL]) {
        view?.stopLoading()
        let merger = PDFMergerService()
        Task {
            do {
                let data = try await merger.mergePDFs(from: urls) { [weak self] url in
                    guard let self else { return nil }
                    return await self.view?.askPDFPassword(fileName: url.lastPathComponent)
                }
                guard let data else {
                    view?.showError("No valid PDF selected")
                    self.view?.stopLoading()
                    return
                }

                saveFile(pdfData: data)
            } catch {
                view?.showError(error.localizedDescription)
            }
            self.view?.stopLoading()

        }
    }

    override func processImages(from images: [UIImage]) {
        view?.showLoading()
        guard !images.isEmpty else {
            view?.stopLoading()
            return
        }
        let data = PDFService().generatePDF(from: images)
        saveFile(pdfData: data)
        view?.stopLoading()
    }

    
    override func saveClicked() {
        if validateFields() {
            let medical = buildMedical()

            switch mode {
            case .add:
                view?.onAdd?(medical)
                view?.showToastVc(message: "Data added successfully", type: .success)
            case .edit:
                view?.onEdit?(medical)
                view?.showToastVc(message: "Data modified successfully", type: .success)
            }
            view?.dismiss()
        }
    }
    
    override func selectClicked(at index: Int ) {
        let field = field(at: index)
        var options: [String] = []
        var selected: String = ""
        var addExtra: Bool = false
        if field.type == .select {
            if index == 0 {
                options = MedicalType.getList()
                selected = field.value as? String ?? MedicalType.defaultValue.rawValue
            } else {
                let value = field.value as? String ?? AppConstantData.none
                addExtra = true
                if index == 3 {
                    hospitals.insert(value)
                    options = Array(hospitals)
                   selected = value
               } else if index == 4 {
                   doctors.insert(value)
                   options = Array(doctors)
                   selected = value
               }
            }
        }
        router.openSelectVC(options: options, selected: selected, addExtra: addExtra, validator: field.validators) { [weak self] value in
            self?.didSelectOption(at: index,value)
        }

    }
    
    override func didSelectOption(at index: Int,_ value: String) {
        updateValue(value, at: index)
        view?.reloadField(at: index, )
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
}
