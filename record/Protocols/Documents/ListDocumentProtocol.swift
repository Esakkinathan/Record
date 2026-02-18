//
//  ListDocumentProtocol.swift
//  record
//
//  Created by Esakkinathan B on 28/01/26.
//

import UIKit
import VTDB

protocol ListDocumentPresenterProtocol {
    
    var currentSort: DocumentSortOption { get }
    func numberOfRows() -> Int
    func document(at index: Int)  -> Document
//    func addDocument(_ document: Document)
//    func updateDocument(_ document: Document)
    func deleteDocument(at index: Int)
    func gotoAddDocumentScreen()
    func didSelectedRow(at index: Int)
    func shareDocument(at index: Int)
    func search(text: String?)
    func didSelectSortField(_ field: DocumentSortField)
    func viewDidLoad()
    func shareDocumentWithLock(at index: Int, password: String)
    func validatePassword(_ password1: String, _ password2: String, at index: Int)
}

protocol DocumentNavigationDelegate: AnyObject {
    func push(_ vc: UIViewController)
    func presentVC(_ vc: UIViewController)
}
protocol ListDocumentViewDelegate: AnyObject {
    func showToastVC(message: String, type: ToastType)
    func reloadData()
    func refreshSortMenu()
}

protocol ListDocumentRouterProtocol {
    func openDetailDocumentVC(document: Document,onUpdate: @escaping (Persistable) -> Void, onUpdateNotes: @escaping (String?,Int) -> Void)
    func openAddDocumentVC(mode: DocumentFormMode, onAdd: @escaping (Persistable) -> Void)
    func openShareDocumentVC(filePath: String)
}
