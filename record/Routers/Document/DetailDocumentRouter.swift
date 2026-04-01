//
//  DetailDocumentRouter.swift
//  record
//
//  Created by Esakkinathan B on 02/02/26.
//

import UIKit
internal import UniformTypeIdentifiers
import QuickLook
import VTDB
import PhotosUI
import VisionKit

class DetailDocumentRouter: DetailDocumentRouterProtocol {
    
    func openDocumentScanner() {
        guard VNDocumentCameraViewController.isSupported else {
            print("Scanner not supported")
            return
        }

        let transparentAppearance = UINavigationBarAppearance()
        transparentAppearance.configureWithTransparentBackground()
        UINavigationBar.appearance().standardAppearance = transparentAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = transparentAppearance
        UINavigationBar.appearance().compactAppearance = transparentAppearance

        let scanner = VNDocumentCameraViewController()
        scanner.delegate = viewController as? VNDocumentCameraViewControllerDelegate
        viewController?.presentVC(scanner)
    }

    func openDocumentPicker() {
        let picker = UIDocumentPickerViewController(
            forOpeningContentTypes: [.pdf, .image],
            asCopy: true
        )
        picker.delegate = viewController as? UIDocumentPickerDelegate
        viewController?.presentVC(picker)
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
    
    func openDocumentViewer(filePath: String) {
        let preview = QLPreviewController()
        preview.dataSource = viewController as? QLPreviewControllerDataSource
        viewController?.push(preview)
    }

    
    weak var viewController: DocumentNavigationDelegate?
    
    init(viewController: DocumentNavigationDelegate) {
        self.viewController = viewController
    }
    
    func openEditDocumentVC( mode: DocumentFormMode, onEdit: @escaping (Persistable) -> Void) {
        let vc = AddDocumentAssembler.make(mode: mode)
        vc.onEdit = onEdit
        let navVc = UINavigationController(rootViewController: vc)
        vc.hidesBottomBarWhenPushed = true
        navVc.modalPresentationStyle = .pageSheet
        viewController?.presentVC(navVc)
    }
    
    
}
