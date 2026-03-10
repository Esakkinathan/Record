//
//  AddDocumentProtocol.swift
//  record
//
//  Created by Esakkinathan B on 30/01/26.
//
import Foundation
protocol AddDocumentRouterProtocol {
    func openDocumentScanner()
    func openGallery()
    func openDocumentPicker(type: DocumentType)
    func openDocumentViewer(filePath: String)
    func openCamera()
    func openSelectVC(options: [String], selected: String, addExtra: Bool,validator: [ValidationRules],onSelect: @escaping (String) -> Void )
}
