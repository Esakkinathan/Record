//
//  ListDocumentRouter.swift
//  record
//
//  Created by Esakkinathan B on 30/01/26.
//

import UIKit

class ListDocumentRouter: ListDocumentRouterProtocol {
    
    weak var viewController: DocumentNavigationDelegate?
    
    init(viewController: DocumentNavigationDelegate? = nil) {
        self.viewController = viewController
    }

    
    func openShareDocumentVC(filePath: String) {
        let activityVc = UIActivityViewController(activityItems: [URL(filePath:filePath)], applicationActivities: nil)
        viewController?.push(activityVc)
    }
    
    func openAddDocumentVC(mode: DocumentFormMode,onAdd: @escaping (Document) -> Void) {
        let vc = AddDocumentAssembler.makeAddDocumentScreen(mode: mode) 
        vc.onAdd = onAdd
        let navVc = UINavigationController(rootViewController: vc)
        navVc.modalPresentationStyle = .formSheet
        viewController?.presentVC(navVc)
    }
        
    func openDetailDocumentVC(document: Document, onUpdate: @escaping (Document) -> Void, onUpdateNotes: @escaping (String?,Int) -> Void) {
        let vc = DetailDocumentAssembler.makeDetailDocumentScreen(document: document)
        vc.onEdit = onUpdate
        vc.onUpdateNotes = onUpdateNotes
        viewController?.push(vc)
    }
}
