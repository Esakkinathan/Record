//
//  AddMedicalProtocol.swift
//  record
//
//  Created by Esakkinathan B on 09/02/26.
//
protocol AddMedicalRouterProtocol {
    func openGallery()
    func openDocumentPicker(type: DocumentType)
    func openDocumentViewer(filePath: String)
    func openCamera()
    func openSelectVC(options: [String], selected: String, addExtra: Bool, validator: [ValidationRules],onSelect: @escaping (String) -> Void )
}
