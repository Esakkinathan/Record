//
//  ListDocumentRounter.swift
//  record
//
//  Created by Esakkinathan B on 03/02/26.
//
import UIKit

class ListPasswordRouter: ListPasswordRouterProtocol {
        
    weak var viewController: DocumentNavigationDelegate?
    
    init(viewController: DocumentNavigationDelegate? = nil) {
        self.viewController = viewController
    }
    
    func openAddPasswordVC(mode: PasswordFormMode, onAdd: @escaping (Password) -> Void) {
        let vc = AddPasswordAssembler.makeAddPasswordScreen(mode: mode)
        vc.onAdd = onAdd
        let navVc = UINavigationController(rootViewController: vc)
        navVc.modalPresentationStyle = .formSheet
        viewController?.presentVC(navVc)
    }
    
    func openDetailPasswordVC(password: Password, onUpdate: @escaping (Password) -> Void, onUpdateNotes: @escaping (String?, Int) -> Void) {
        let vc = DetailPasswordAssembler.makePasswordScreen(password: password)
        vc.onEdit = onUpdate
        viewController?.push(vc)
    }

}
