//
//  DetailDocumentPresenter.swift
//  record
//
//  Created by Esakkinathan B on 02/02/26.
//

import Foundation
import UIKit


class DetailDocumentPresenter: DetailDocumentPresenterProtocol {
        
    var title: String {
        return document.name
    }
    var expiryDate: Date? {
        return document.expiryDate
    }

    let fileManager: AppFileManager
    var document: Document
    weak var view: DetailDocumentViewDelegate?
    let router: DetailDocumentRouterProtocol
    var sections: [DetailDocumentSection] = []
    
    var isNotesEditing: Bool = false
    let addRemainderUseCase: AddRemainderUseCaseProtocol
    let fetchRemainderUseCase: FetchRemainderUseCaseProtocol
    let deleteRemainderUseCase: DeleteRemainderUseCaseProtocol
    let updateUseCase: UpdateDocumentUseCaseProtocol
    var remainders: [Remainder] = []
    
    init(document: Document, view: DetailDocumentViewDelegate? = nil, router: DetailDocumentRouterProtocol, addRemainderUseCase: AddRemainderUseCaseProtocol, fetchRemainderUseCase: FetchRemainderUseCaseProtocol, deleteRemainderUseCase: DeleteRemainderUseCaseProtocol, updateUseCase: UpdateDocumentUseCaseProtocol) {
        self.document = document
        self.view = view
        self.router = router
        self.addRemainderUseCase = addRemainderUseCase
        self.fetchRemainderUseCase = fetchRemainderUseCase
        self.deleteRemainderUseCase = deleteRemainderUseCase
        self.updateUseCase = updateUseCase
        fileManager = AppFileManager()
    }
    
    func viewDidLoad() {
        fetchRemainder()
        buildSection()
    }
    
    func updateDocument(_ document: Document) {
        //self.document.update(name: document.name, number: document.number, expiryDate: document.expiryDate, file: document.file)
        DispatchQueue.main.async { [weak self] in
            self?.updateUseCase.execute(document: document)
            self?.buildSection()
            self?.view?.reloadData()
            self?.view?.showToastVC(message: "Data modified successfully", type: .success)
        }
    }
    
    func editButtonClicked() {
        router.openEditDocumentVC(mode: .edit(document)) { [weak self] document in
            guard let self = self else { return }
            updateDocument(document as! Document)
            //view?.updateDocument(document: document)
        }
    }
    
    func viewDocument() {
        if let file = document.file, let path = DocumentThumbnailProvider.fullURL(from: file) {
            router.openDocumentViewer(filePath: path)
            view?.configureToOpenDocument(previewUrl: URL(filePath: path))
        }
    }
    
    func updateNotes(text: String?) {
        document.notes = text
        buildSection()
        //view?.reloadData()
    }
    
    func getTitle(for section: Int) -> String? {
        let title = sections[section].title
        if title == "Notes" || title == "Remainders" {
            return nil
        }
        return title
    }
    
    func numberOfSection() -> Int {
        return sections.count
    }
    
    func numberOfSectionRows(at section: Int) -> Int {
        return sections[section].rows.count
    }
    
    func buildSection() {
        sections = []
        sections.append(
            .init(
                title: "Document Preview",
                rows: [.image(path: document.file)]
            )
        )

        
        var infoRows: [DetailDocumentRow] = [
            .info(title: "Name", value: document.name),
            .info(title: "Number", value: document.number),
            .info(title: "Created At", value: document.createdAt.toString()),
            .info(title: "Last Modified", value: document.lastModified.reminderFormatted())
        ]
        if let file = document.file, let path = DocumentThumbnailProvider.fullURL(from: file) {
            infoRows.append(.info(title: "File Size", value: formattedFileSize(from: URL(filePath: path))))
        }
        if let date = document.expiryDate {
            infoRows.append(.info(title: "Expiry Date", value: date.toString()))
        }
        sections.append(.init(title: "Info", rows: infoRows))
            
        sections.append(.init(title: "Notes", rows: [.notes(text: document.notes, isEditable: isNotesEditing)]))
        if let expiryDate = document.expiryDate {
            if expiryDate > Date() {
                var remainderRow: [DetailDocumentRow] = []
                var index = 1
                for remainder in remainders {
                    remainderRow.append(.remainder(count: index, remainder))
                    index += 1
                }
                if remainderRow.isEmpty {
                    remainderRow.append(.remainder(count: 1, nil))
                }
                sections.append(.init(title: "Remainders", rows: remainderRow))
            }
        }
    }
    
    func section(at section: Int) -> DetailDocumentSection {
        return sections[section]
    }
    func getRow(at indexPath: IndexPath) -> DetailDocumentRow {

        return sections[indexPath.section].rows[indexPath.row]
    }
    
    func toggleNotesEditing(_ editing: Bool) {
        isNotesEditing = editing

        if !editing {
            updateUseCase.execute(text: document.notes, id: document.id)
        }

        buildSection()
        view?.reloadData()
    }
    
    func uploadDocument() {
        router.openDocumentPicker()
    }

//    func didPickDocument(url: URL) {
//        let path = saveFileLocally(url, name: document.name, number: document.number)
//        document.file = path
//        buildSection()
//        view?.reloadData()
//        view?.updateDocument(document: document)
//    }
}

extension DetailDocumentPresenter {
    
    func addRemainderClicked() {
        if remainders.count < 3 {
            view?.showAlertOnAddRemainder()
        } else {
            view?.showToastVC(message: "Maximum 3 remainders only", type: .info)
        }
    }
    
    func fetchRemainder() {
        remainders = fetchRemainderUseCase.execute(id: document.id)
    }
    
    func addRemainder(date: Date) {
        let remainder = Remainder(id: 1, documentId: document.id, date: date)
        let id = addRemainderUseCase.execute(remainder: remainder)
        remainder.id = id
        remainders.append(remainder)
        NotificationManager.shared.setRemainderNotification(document: document, remainderId: remainders.count, date: date)
        buildSection()
        view?.reloadData()
    }
    
    func deleteRemainder(index: Int) {
        let remainder = remainders.remove(at: index)
        deleteRemainderUseCase.execute(id: remainder.id)
        NotificationManager.shared.removeRemainderNotification(documentId: document.id,remainderId: remainders.count+1)
        buildSection()
        view?.reloadData()
    }
    
    func canEditAt(_ indexPath: IndexPath) -> Bool {
        let section = section(at: indexPath.section)
        if section.title == "Remainders" {
            return true
        }
        return false
    }
    
    func handleOffsetSelection(offset: ReminderOffset, date: Date) {
        if offset == .custom {
            view?.showAlertOnAddRemainder()
            return
        }
        
        guard let baseDate = offset.date(expiryDate: date) else {
            return
        }
        view?.showTimePicker(baseDate: baseDate)
    }
    
    func formattedFileSize(from url: URL) -> String {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            if let fileSize = attributes[.size] as? Int64 {
                
                let formatter = ByteCountFormatter()
                formatter.allowedUnits = [.useKB, .useMB, .useGB]
                formatter.countStyle = .file
                formatter.allowsNonnumericFormatting = false
                
                return formatter.string(fromByteCount: fileSize)
            }
        } catch {
            print("Error:", error)
        }
        
        return "0 KB"
    }
    
    func processFile(urls: [URL]) {
        view?.showLoading()
        Task {
            do {
                let pdfData = try await PDFMergerService().mergePDFs(from: urls) { [weak self] url in
                    guard let self else {
                        self?.view?.stopLoading()
                        return nil
                        
                    }
                    return await self.view?.askPDFPassword(fileName: url.lastPathComponent)
                }
                guard let pdfData else {
                    self.view?.showToastVC(message: "No valid PDF selected", type: .error)
                    self.view?.stopLoading()
                    return
                }

                self.saveFile(pdfData: pdfData)
            } catch {
                self.view?.showToastVC(message: error.localizedDescription, type: .error)
            }
            self.view?.stopLoading()

        }
        
    }

    
    func processImages(from images: [UIImage]) {
        guard !images.isEmpty else { return }
        
        view?.showLoading()
        
        Task { [weak self] in
            guard let self else {
                self?.view?.stopLoading()
                return
            }
            let data = PDFService().generatePDF(from: images)
            await MainActor.run {
                self.saveFile(pdfData: data)
                self.view?.stopLoading()
            }
        }
    }
    func saveFile(pdfData: Data) {
        var fileName = document.name.replacingOccurrences(of: " ", with: "")
        fileName = "\(fileName)_\(document.number)"
        let sourceUrl = fileManager.saveFile(pdfData: pdfData)
        if let url = sourceUrl {
            let path = fileManager.saveFileLocally(sourceURL: url, directory: .docs, name: fileName)
            updateFile(url: path)
        }
        //return path
    }
    func updateFile(url: String?) {
        document.file = url
        updateUseCase.execute(document: document)
        buildSection()
        view?.reloadData()
        //view?.reloadField(at: index)
    }
    
    func openCameraClicked(){
        router.openDocumentScanner()
    }
    func uploadDocument(at index: Int, type: DocumentType) {
        switch type {
        case .pdf:
            router.openDocumentPicker(type: type)
        case .image:
            router.openGallery()
        }
        
    }



}
