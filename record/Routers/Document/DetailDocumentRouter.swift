//
//  DetailDocumentRouter.swift
//  record
//
//  Created by Esakkinathan B on 02/02/26.
//

import UIKit
import QuickLook

class DetailDocumentRouter: DetailDocumentRouterProtocol {

    weak var viewController: DocumentNavigationDelegate?
    
    init(viewController: DocumentNavigationDelegate) {
        self.viewController = viewController
    }
    
    func openEditDocumentVC( mode: DocumentFormMode, onEdit: @escaping (Document) -> Void) {
        let vc = AddDocumentAssembler.makeAddDocumentScreen(mode: mode)
        vc.onEdit = onEdit
        let navVc = UINavigationController(rootViewController: vc)
        vc.hidesBottomBarWhenPushed = true
        navVc.modalPresentationStyle = .formSheet
        viewController?.presentVC(navVc)
    }
    
    func openDocumentViewer(filePath: String) {
        let preview = QLPreviewController()
        preview.dataSource = viewController as? QLPreviewControllerDataSource
        viewController?.push(preview)

    }
    

}
