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
    
    
    var document: Document
    weak var view: DetailDocumentViewDelegate?
    let router: DetailDocumentRouterProtocol
    var sections: [DetailDocumentSection] = []
    
    var isNotesEditing: Bool = false
    
    init(document: Document, view: DetailDocumentViewDelegate? = nil, router: DetailDocumentRouterProtocol) {
        self.document = document
        self.view = view
        self.router = router
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
        if title == "Notes" {
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
            .info(title: "Created At", value: document.createdAt.toString())
        ]
        if let date = document.expiryDate {
            infoRows.append(.info(title: "Expiry Date", value: date.toString()))
        }
        sections.append(.init(title: "Info", rows: infoRows))
            
        sections.append(.init(title: "Notes", rows: [.notes(text: document.notes, isEditable: isNotesEditing)]))
    }
    
    func section(at indexPath: IndexPath) -> DetailDocumentRow {
        return sections[indexPath.section].rows[indexPath.row]
    }
    
    func getSection(at section: Int) -> DetailDocumentSection {
        return sections[section]
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
