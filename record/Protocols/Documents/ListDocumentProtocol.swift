//
//  ListDocumentProtocol.swift
//  record
//
//  Created by Esakkinathan B on 28/01/26.
//

import UIKit
import VTDB

protocol ListDocumentPresenterProtocol {
    var total: Int { get }
    var currentSort: DocumentSortOption { get }
    var isSelectionMode: Bool { get set }
    func numberOfRows() -> Int
    func document(at index: Int)  -> Document
    func deleteDocument(at index: Int)
    func deleteClicked(at index: Int)
    func gotoAddDocumentScreen()
    func didSelectedRow(at index: Int)
    func shareDocument(at index: Int)
    func search(text: String?)
    func didSelectSortField(_ field: DocumentSortField)
    func viewDidLoad()
    func shareDocumentWithLock(at index: Int, password: String)
    func validatePassword(_ password1: String, _ password2: String, at index: Int)
    func toggleClicked(at index: Int)
    var isEmpty: Bool { get }
    var isSearching: Bool { get }
    func shareButtonClicked(_ indexPath: IndexPath)
    func loadDocuments(reset: Bool)
    func toggleSelection(at index: Int)
    func clearSelection()
    func deleteMultiple()
    func shareMultiple()
    func updateRestrictionForSelected(lock: Bool)
    var selectedIndexes: Set<Int> { get }
    func selectionState() -> SelectionRestrictionState
    func deleteDocument(_ document: Document)
}

protocol DocumentNavigationDelegate: AnyObject {
    func push(_ vc: UIViewController)
    func presentVC(_ vc: UIViewController)
}
protocol ListDocumentViewDelegate: AnyObject {
    func showToastVC(message: String, type: ToastType)
    func reloadData()
    func refreshSortMenu()
    func showAlertOnShare(_ indexPath: IndexPath)
    func showAlertOnDelete(at index: Int)
    func reloadField(at index: Int)
    func exitSelectionMode()
    func showAlertOnDelete(_ documents: [Document])

}

protocol ListDocumentRouterProtocol {
    func openDetailDocumentVC(document: Document)
    func openAddDocumentVC(mode: DocumentFormMode, onAdd: @escaping (Persistable) -> Void)
    func openShareDocumentVC(filePath: String)
    func openShareMultipleDocumentsVC(filePaths: [String])
}
