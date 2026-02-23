//
//  ListDocumentRouter.swift
//  record
//
//  Created by Esakkinathan B on 30/01/26.
//

import UIKit
import VTDB
class ListDocumentRouter: ListDocumentRouterProtocol {
    
    weak var viewController: DocumentNavigationDelegate?
    
    init(viewController: DocumentNavigationDelegate? = nil) {
        self.viewController = viewController
    }

    
    func openShareDocumentVC(filePath: String) {
        let activityVc = UIActivityViewController(activityItems: [URL(filePath:filePath)], applicationActivities: nil)
        activityVc.modalPresentationStyle = .pageSheet
        viewController?.presentVC(activityVc)
    }
    
    func openAddDocumentVC(mode: DocumentFormMode,onAdd: @escaping (Persistable) -> Void) {
        let vc = AddDocumentAssembler.make(mode: mode)
        vc.onAdd = onAdd
        let navVc = UINavigationController(rootViewController: vc)
        navVc.modalPresentationStyle = .pageSheet
        
        viewController?.presentVC(navVc)
    }
        
    func openDetailDocumentVC(document: Document, onUpdate: @escaping (Persistable) -> Void, onUpdateNotes: @escaping (String?,Int) -> Void) {
        let vc = DetailDocumentAssembler.make(document: document)
        vc.onEdit = onUpdate
        vc.onUpdateNotes = onUpdateNotes
        viewController?.push(vc)
    }
}
