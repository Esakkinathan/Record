//
//  ListDocumentRounter.swift
//  record
//
//  Created by Esakkinathan B on 03/02/26.
//
import UIKit
import VTDB

class ListPasswordRouter: ListPasswordRouterProtocol {
        
    weak var viewController: DocumentNavigationDelegate?
    
    init(viewController: DocumentNavigationDelegate? = nil) {
        self.viewController = viewController
    }
    
    func openAddPasswordVC(mode: PasswordFormMode, onAdd: @escaping (Persistable) -> Void) {
        let vc = AddPasswordAssembler.make(mode: mode)
        vc.onAdd = onAdd
        let navVc = UINavigationController(rootViewController: vc)
        navVc.modalPresentationStyle = .pageSheet
        viewController?.presentVC(navVc)
    }
    
    func openDetailPasswordVC(password: Password, onUpdate: @escaping (Persistable) -> Void, onUpdateNotes: @escaping (String?, Int) -> Void) {
        let vc = DetailPasswordAssembler.make(password: password)
        vc.onEdit = onUpdate
        viewController?.push(vc)
    }

}
