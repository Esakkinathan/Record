//
//  DetailDocumentProtocol.swift
//  record
//
//  Created by Esakkinathan B on 30/01/26.
//
import UIKit
import VTDB
protocol DetailDocumentPresenterProtocol {
    var expiryDate: Date? {get}
    var title: String { get }
    func editButtonClicked()
    func viewDocument()
    func updateNotes(text: String?)
    func numberOfSection() -> Int
    func numberOfSectionRows(at section: Int) -> Int
    func section(at section: Int) -> DetailDocumentSection
    func getRow(at indexPath: IndexPath) -> DetailDocumentRow
    func getTitle(for section: Int) -> String?
    func toggleNotesEditing(_ editing: Bool)
    var isNotesEditing: Bool {get}
    func uploadDocument()
    func uploadDocument(at index: Int, type: DocumentType)
    func openCameraClicked()
    //func didPickDocument(url: URL)
    func viewDidLoad()
    func addRemainderClicked()
    
    func processImages(from images: [UIImage])
    func processFile(urls: [URL])

    
    func addRemainder(date: Date)
    func canEditAt(_ indexPath: IndexPath) -> Bool
    func deleteRemainder(index: Int)
    func handleOffsetSelection(offset: ReminderOffset, date: Date)
}

protocol DetailDocumentViewDelegate: AnyObject {
    func showToastVC(message: String, type: ToastType)
    func reloadData()
    func showAlertOnAddRemainder()
    func configureToOpenDocument(previewUrl: URL)
    func showTimePicker(baseDate: Date)
    func showLoading()
    func stopLoading()
    func askPDFPassword(fileName: String) async -> String?


}

protocol DetailDocumentRouterProtocol {
    func openDocumentPicker()
    func openEditDocumentVC(mode: DocumentFormMode, onEdit: @escaping (Persistable) -> Void)
    func openDocumentViewer(filePath: String)
    func openDocumentScanner()
    func openGallery()
    func openDocumentPicker(type: DocumentType)

}

enum DetailDocumentRow {
    case image(path: String?)
    case info(title: String, value: String)
    case notes(text: String?, isEditable: Bool)
    case remainder(count: Int,Remainder?)
}

struct DetailDocumentSection {
    let title: String
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

