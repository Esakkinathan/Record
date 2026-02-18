//
//  AddDocumentRuter.swift
//  record
//
//  Created by Esakkinathan B on 01/02/26.
//
import UIKit
internal import UniformTypeIdentifiers
import QuickLook

class AddDocumentRouter: AddDocumentRouterProtocol {
        
    weak var viewController: DocumentNavigationDelegate?
    
    init(viewController: DocumentNavigationDelegate? = nil) {
        self.viewController = viewController
    }
    
    func openDocumentPicker() {
        let picker = UIDocumentPickerViewController(
            forOpeningContentTypes: [.pdf, .image],
            asCopy: true
        )
        picker.delegate = viewController as? UIDocumentPickerDelegate
        viewController?.presentVC(picker)
    }
    
    func openDocumentViewer(filePath: String) {
        let preview = QLPreviewController()
        preview.dataSource = viewController as? QLPreviewControllerDataSource
        viewController?.push(preview)
    }
    
    func openSelectVC(options: [String], selected: String, addExtra: Bool,onSelect: @escaping (String) -> Void) {
        let vc = SelectionViewController(options: options,selectedOption: selected, addExtra: addExtra)
        vc.onValueSelected = onSelect
        viewController?.push(vc)
    }

}
