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

    
    var document: Document
    weak var view: DetailDocumentViewDelegate?
    let router: DetailDocumentRouterProtocol
    var sections: [DetailDocumentSection] = []
    
    var isNotesEditing: Bool = false
    let addRemainderUseCase: AddRemainderUseCaseProtocol
    let fetchRemainderUseCase: FetchRemainderUseCaseProtocol
    let deleteRemainderUseCase: DeleteRemainderUseCaseProtocol
    
    var remainders: [Remainder] = []
    
    init(document: Document, view: DetailDocumentViewDelegate? = nil, router: DetailDocumentRouterProtocol, addRemainderUseCase: AddRemainderUseCaseProtocol, fetchRemainderUseCase: FetchRemainderUseCaseProtocol, deleteRemainderUseCase: DeleteRemainderUseCaseProtocol) {
        self.document = document
        self.view = view
        self.router = router
        self.addRemainderUseCase = addRemainderUseCase
        self.fetchRemainderUseCase = fetchRemainderUseCase
        self.deleteRemainderUseCase = deleteRemainderUseCase
    }
    
    func viewDidLoad() {
        fetchRemainder()
        buildSection()
    }
    
    func updateDocument(_ document: Document) {
        self.document.update(name: document.name, number: document.number, expiryDate: document.expiryDate, file: document.file)
        buildSection()
        view?.reloadData()
    }
    
    func editButtonClicked() {
        router.openEditDocumentVC(mode: .edit(document)) { [weak self] document in
            guard let self = self else { return }
            updateDocument(document as! Document)
            view?.updateDocument(document: document)
        }
    }
    
    func viewDocument() {
        if let filePath = document.file {
            router.openDocumentViewer(filePath: filePath)
            view?.configureToOpenDocument(previewUrl: URL(filePath: filePath))
        }
        
    }
    
    
    func updateNotes(text: String?) {
        document.notes = text
        buildSection()
        view?.reloadData()
    }
    
    func getTitle(for section: Int) -> String? {
        let title = sections[section].title
        if title == "Notes" || title == "Remainder" {
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
            .info(title: "Last modified", value: document.lastModified.reminderFormatted())
        ]
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
                sections.append(.init(title: "Remainder", rows: remainderRow))
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
            view?.updateDocumentNotes(
                text: document.notes,
                id: document.id
            )
        }

        buildSection()
        view?.reloadData()
    }
    
    func uploadDocument() {
        router.openDocumentPicker()
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

    
    func didPickDocument(url: URL) {
        let path = saveFileLocally(url, name: document.name, number: document.number)
        document.file = path
        buildSection()
        view?.reloadData()
        view?.updateDocument(document: document)
    }
}

extension DetailDocumentPresenter {
    
    func addRemainderClicked() {
        if remainders.count < 3 {
            view?.showAlertOnAddRemainder()
        } else {
            view?.showToastVC(message: "Maximum 3 Remainders only", type: .info)
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
        if indexPath.section == 3 {
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
}
