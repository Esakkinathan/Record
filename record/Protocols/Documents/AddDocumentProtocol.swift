//
//  AddDocumentProtocol.swift
//  record
//
//  Created by Esakkinathan B on 30/01/26.
//
import Foundation
/*
protocol AddDocumentPresenterProtocol {
    var title: String {get}
    func field(at index: Int) -> DocumentFormField
    func numberOfFields() -> Int
    func updateValue(_ value: Any?, at index: Int)
    func saveClicked()
    func validateText(text: String, index: Int,rules: [ValidationRules]) -> ValidationResult
    
    func uploadDocument(at index: Int)
    func viewDocument(at index: Int)
    func removeDocument(at index: Int)
    func didPickDocument(url: URL)
    
    func selectClicked(at index: Int)
    func cancelClicked()
    func didSelectOption(_ value: String)

}

protocol AddDocumentViewDelegate: AnyObject {
    var onAdd: ((Document) -> Void)? { get set }
    var onEdit: ((Document) -> Void)? { get set }
    func reloadData()
    func showError(_ message: String?)
    func dismiss()
    func reloadField(at index: Int)
    func configureToOpenDocument(previewUrl: URL)
}
*/
protocol AddDocumentRouterProtocol {
    func openDocumentScanner()
    func openGallery()
    func openDocumentPicker(type: DocumentType)
    func openDocumentViewer(filePath: String)
    func openCamera()
    func openSelectVC(options: [String], selected: String, addExtra: Bool,onSelect: @escaping (String) -> Void )
}
