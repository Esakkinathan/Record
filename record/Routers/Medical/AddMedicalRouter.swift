//
//  AddMedicalRouter.swift
//  record
//
//  Created by Esakkinathan B on 09/02/26.
//
internal import UniformTypeIdentifiers
import QuickLook
import UIKit
import PhotosUI

class AddMedicalRouter: AddMedicalRouterProtocol {
    weak var viewController: DocumentNavigationDelegate?
    
    init(viewController: DocumentNavigationDelegate? = nil) {
        self.viewController = viewController
    }
    func openGallery() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 10
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = viewController as? PHPickerViewControllerDelegate
        viewController?.presentVC(picker)
    }
    func openDocumentPicker(type: DocumentType) {
        let picker: UIDocumentPickerViewController
        switch type {
        case .pdf:
            picker = UIDocumentPickerViewController(
                forOpeningContentTypes: [.pdf],
                asCopy: true
            )
        case .image:
            picker = UIDocumentPickerViewController(
                forOpeningContentTypes: [.image],
                asCopy: true
            )
        }
        
        picker.allowsMultipleSelection = true
        picker.delegate = viewController as? UIDocumentPickerDelegate
        viewController?.presentVC(picker)
        picker.showToast(message: "Max 10 files are allowed", type: .info)
    }

    func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("Camera not available")
            return
        }

        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = viewController as? (UIImagePickerControllerDelegate & UINavigationControllerDelegate)
        picker.allowsEditing = true
        viewController?.presentVC(picker)

    }
    func openSelectVC(options: [String], selected: String, addExtra: Bool, onSelect: @escaping (String) -> Void) {
        let vc = SelectViewAssembler.make(options: options, selectedOption: selected,addExtra: addExtra)
        vc.onValueSelected = onSelect
        viewController?.push(vc)
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
}
