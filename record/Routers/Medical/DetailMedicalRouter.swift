//
//  DetailMedicalRouter.swift
//  record
//
//  Created by Esakkinathan B on 09/02/26.
//

import UIKit
import VTDB
import QuickLook

class DetailMedicalRouter: DetailMedicalRouterProtocol {
    
    
    weak var viewController: DocumentNavigationDelegate?
    
    init(viewController: DocumentNavigationDelegate? = nil) {
        self.viewController = viewController
    }
    
    func openEditMedicalVC(mode: MedicalFormMode, onEdit: @escaping ((Persistable) -> Void)) {
        let vc = AddMedicalAssembler.make(mode: mode)
        vc.onEdit = onEdit
        
        let navVc = UINavigationController(rootViewController: vc)
        navVc.modalPresentationStyle = .pageSheet
        viewController?.presentVC(navVc)
        
    }
    func openListMedicalItemVC(kind: MedicalKind, medical: Medical) {
        let vc = ListMedicalItemAssembler.make(kind: kind, medical: medical)
        viewController?.push(vc)
    }
    
    func sharePdf(url: URL) {
        let activityVc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        activityVc.modalPresentationStyle = .pageSheet
        viewController?.presentVC(activityVc)
    }
    
    func openDocumentViewer(filePath: String) {
        let preview = QLPreviewController()
        preview.dataSource = viewController as? QLPreviewControllerDataSource
        viewController?.push(preview)

    }
}
