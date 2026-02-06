//
//  DetailDocumentProtocol.swift
//  record
//
//  Created by Esakkinathan B on 30/01/26.
//
import UIKit

protocol DetailDocumentPresenterProtocol {
    var title: String { get }
    func editButtonClicked()
    func viewDocument()
    func updateNotes(text: String?)
    func numberOfSection() -> Int
    func numberOfSectionRows(at section: Int) -> Int
    func section(at indexPath: IndexPath) -> DetailDocumentRow
    func getTitle(for section: Int) -> String?
    func getSection(at section: Int) -> DetailDocumentSection
    func toggleNotesEditing(_ editing: Bool)
    var isNotesEditing: Bool {get}
}

protocol DetailDocumentViewDelegate: AnyObject {
    func reloadData()
    func configureToOpenDocument(previewUrl: URL)
    func updateDocumentNotes(text: String?,id: Int)
    func updateDocument(document: Document)
}

protocol DetailDocumentRouterProtocol {
    func openEditDocumentVC(mode: DocumentFormMode, onEdit: @escaping (Document) -> Void)
    func openDocumentViewer(filePath: String)
}

enum DetailDocumentRow {
    case image(path: String?)
    case info(title: String, value: String)
    case notes(text: String?, isEditable: Bool)
}

struct DetailDocumentSection {
    let title: String?
    let rows: [DetailDocumentRow]
}


enum DetailDocumentTextSection: CaseIterable {
    case name
    case number
    case createdAt
    case expiryDate
}

struct DetailDocumentTextSectionRow {
    var title: String
    var value: String
    var type: DetailDocumentTextSection
}

