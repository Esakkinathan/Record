//
//  DetailPasswordRouter.swift
//  record
//
//  Created by Esakkinathan B on 04/02/26.
//
import UIKit
import VTDB
class DetailPasswordRouter: DetailPasswordRouterProtocol {
    
    weak var viewController: DocumentNavigationDelegate?
    
    init(viewController: DocumentNavigationDelegate? = nil) {
        self.viewController = viewController
    }
    
    func openEditPasswordVC(mode: PasswordFormMode, onEdit: @escaping ((Persistable) -> Void)) {
        let vc = AddPasswordAssembler.make(mode: mode)
        vc.onEdit = onEdit
        
        let navVc = UINavigationController(rootViewController: vc)
        navVc.modalPresentationStyle = .formSheet
        viewController?.presentVC(navVc)
        
    }

}
