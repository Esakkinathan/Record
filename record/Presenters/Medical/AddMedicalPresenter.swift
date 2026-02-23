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
    let doctors: [String]
    let hospitals: [String]
    let fetchUseCase: FetchMedicalUseCase
    init(view: FormFieldViewDelegate? = nil, router: AddMedicalRouterProtocol, mode: MedicalFormMode,fetchUseCase: FetchMedicalUseCase ) {
        self.router = router
        self.mode = mode
        self.fetchUseCase = fetchUseCase
        doctors = fetchUseCase.fetchDoctors()
        hospitals = fetchUseCase.fetchHospitals()
        super.init(view: view)
    }
    
    func existing() -> Medical? {
        if case let .edit(medical) = mode {
            return medical
        }
        return nil
    }
    override func numberOfFields() -> Int {
        return fields.count - 1
    }
    

    func buildFields() {
        let existing = existing()
        
        fields = [
            FormField(label: "Type", type: .select, validators: [.required], gotoNextField: false, value: existing?.type.rawValue ?? MedicalType.checkup.rawValue),
            FormField(label: "Title", type: .text, validators: [.required, .maxLength(30)], gotoNextField: true, placeholder: "Enter Title", value: existing?.title,returnType: .next,),
            FormField(label: "Hospital", type: .select, validators: [.maxLength(30)], gotoNextField: true, value: existing?.hospital ?? AppConstantData.none, returnType: .next),
            FormField(label: "Doctor", type: .select, validators: [.maxLength(30)], gotoNextField: false, value: existing?.doctor ?? AppConstantData.none, returnType: .done),
            FormField(label: "Recorded At", type: .date, validators: [.required], gotoNextField: false, value: existing?.date),
            FormField(label: "Medical Reciept", type: .fileUpload, validators: [], gotoNextField: false, value: existing?.receipt),
            FormField(label: "Duration", type: .textSelect, validators: [.required, .maxValue(30)], gotoNextField: false, placeholder: "Duration", value: existing?.duration != nil ? String(existing!.duration) : nil, returnType: .done, keyboardMode: .numberPad),
            FormField(label: "Duration Type", type: .text, validators: [], gotoNextField: false, value: existing?.durationType.rawValue ?? DurationType.day.rawValue),
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
        let hospitalData = field(at: 2).value as? String
        let hospital: String? = hospitalData == AppConstantData.none ? nil : hospitalData
        let doctorData = field(at: 3).value as? String
        let doctor: String? = doctorData == AppConstantData.none ? nil : doctorData
        let recordDate = field(at: 4).value as? Date ?? Date()
        let durationValue = field(at: 6).value as? String ?? "1"
        let duration = Int(durationValue) ?? 1
        let durationType = field(at: 7).value as? String ?? DurationType.day.rawValue
        let medicalDurationType: DurationType = DurationType(rawValue: durationType) ?? DurationType.day
        var file: String?
        let date = Date().timeIntervalSince1970
        if let path = field(of: .fileUpload)?.value as? String {
            file = saveFileLocally(URL(filePath: path), name: "\(title)_\(date)")
        }
        switch mode {
        case .add:
            return Medical(id: 1, title: title, type: medicalType, duration: duration, durationType: medicalDurationType,hospital: hospital, doctor: doctor, date: recordDate.start,receipt: file)
        case .edit(let medical):
            medical.update(title: title, type: medicalType, duration: duration, durationType: medicalDurationType, hospital: hospital,doctor: doctor,date: recordDate.start, receipt: file)
            return medical
        }
    }
    
    func saveFileLocally(_ sourceURL: URL, name: String) -> String? {

        let fileManager = FileManager.default
        let documentsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let govtDocsDir = documentsDir.appendingPathComponent("MedicalReciept", isDirectory: true)

        do {
            if !fileManager.fileExists(atPath: govtDocsDir.path) {
                try fileManager.createDirectory(at: govtDocsDir,withIntermediateDirectories: true,attributes: nil)
            }

            let docName = name.replacingOccurrences(of: " ", with: "")
            let fileName = "\(docName).\(sourceURL.pathExtension)"
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
    
    override func openCameraClicked(){
        router.openCamera()
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
    override func didPickDocuments(urls: [URL]) {
        let merger = PDFMergerService()
        do {
            let data = try merger.mergePDFs(from: urls)
            saveFile(pdfData: data)
        } catch {
            view?.showError(error.localizedDescription)
        }
    }

    override func processImages(from images: [UIImage]) {
        view?.showLoading()
        guard !images.isEmpty else {
            return
        }
        let data = DocumentOCRService().generate(from: images)
        saveFile(pdfData: data)
        view?.stopLoading()
    }

    
    override func saveClicked() {
        if validateFields() {
            let medical = buildMedical()

            switch mode {
            case .add:
                view?.onAdd?(medical)
            case .edit:
                view?.onEdit?(medical)
            }
            view?.dismiss()
        }
    }
    
    override func selectClicked(at index: Int ) {
        let field = field(at: index)
        var options: [String] = []
        var selected: String = ""
        if field.type == .select {
            if index == 0 {
                options = MedicalType.getList()
                selected = field.value as? String ?? MedicalType.defaultValue.rawValue
            } else {
                options += [AppConstantData.none]
                let value = field.value as? String
                if let value, value != AppConstantData.none {
                    options += [value]
                }
                if index == 2 {
                    options +=  hospitals
                   selected = field.value as? String ?? AppConstantData.none

               } else if index == 3 {
                   options += doctors
                   selected = field.value as? String ?? AppConstantData.none

               }

            }
            
        } else if field.type == .textSelect {
            let nextField: FormField = super.field(at: index+1)
            
            selected = nextField.value as? String ?? DurationType.day.rawValue
            options = DurationType.getList()
        }
        router.openSelectVC(options: options, selected: selected, addExtra: false) { [weak self] value in
            self?.didSelectOption(at: index,value)
        }

    }
    
    override func didSelectOption(at index: Int,_ value: String) {
        switch index {
        case 6:
            updateValue(value, at: index+1)
        default:
            updateValue(value, at: index)
        }
        view?.reloadField(at: index, )
    }
    override func uploadDocument(at index: Int, type: DocumentType) {
        router.openDocumentPicker()
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
}
