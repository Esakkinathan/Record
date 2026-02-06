//
//  DetailPasswordRouter.swift
//  record
//
//  Created by Esakkinathan B on 04/02/26.
//
import UIKit

class DetailPasswordRouter: DetailPasswordRouterProtocol {
    
    weak var viewController: DocumentNavigationDelegate?
    
    init(viewController: DocumentNavigationDelegate? = nil) {
        self.viewController = viewController
    }
    
    func openEditPasswordVC(mode: PasswordFormMode, onEdit: @escaping ((Password) -> Void)) {
        let vc = AddPasswordAssembler.makeAddPasswordScreen(mode: mode)
        vc.onEdit = onEdit
        
        let navVc = UINavigationController(rootViewController: vc)
        navVc.modalPresentationStyle = .formSheet
        viewController?.presentVC(navVc)
        
    }

}
