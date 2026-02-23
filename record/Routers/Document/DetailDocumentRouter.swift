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

class DetailDocumentRouter: DetailDocumentRouterProtocol {

    func openDocumentPicker() {
        let picker = UIDocumentPickerViewController(
            forOpeningContentTypes: [.pdf, .image],
            asCopy: true
        )
        picker.delegate = viewController as? UIDocumentPickerDelegate
        viewController?.presentVC(picker)
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
    
    func openDocumentViewer(filePath: String) {
        let preview = QLPreviewController()
        preview.dataSource = viewController as? QLPreviewControllerDataSource
        viewController?.push(preview)

    }
    

}
