//
//  ListDocumentProtocol.swift
//  record
//
//  Created by Esakkinathan B on 28/01/26.
//

import UIKit

protocol ListDocumentProtocol {
    
    var currentSort: DocumentSortOption { get }
    func numberOfRows() -> Int
    func document(at index: Int)  -> Document
    func addDocument(_ document: Document)
    func updateDocument(document: Document)
    func deleteDocument(at index: Int)
    func getSelectedSegement() -> Int
    func gotoAddDocumentScreen()
    func didSelectedRow(at index: Int)
    func shareDocument(at index: Int)
    func search(text: String?)
    func didSelectSortField(_ field: DocumentSortField)
    func viewDidLoad()
    func shareDocumentWithLock(at index: Int, password: String)
}

protocol DocumentNavigationDelegate: AnyObject {
    func push(_ vc: UIViewController)
    func presentVC(_ vc: UIViewController)
}
protocol ListDocumentViewDelegate: AnyObject {
    func reloadData()
    func refreshSortMenu()
}

protocol ListDocumentRouterProtocol {
    func openDetailDocumentVC(document: Document,onUpdate: @escaping (Document) -> Void, onUpdateNotes: @escaping (String?,Int) -> Void)
    func openAddDocumentVC(mode: DocumentFormMode, onAdd: @escaping (Document) -> Void)
    func openShareDocumentVC(filePath: String)
}
