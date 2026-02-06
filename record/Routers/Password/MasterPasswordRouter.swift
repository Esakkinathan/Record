//
//  MasterPasswordRouter.swift
//  record
//
//  Created by Esakkinathan B on 06/02/26.
//
import UIKit

class MasterPasswordRouter: MasterPasswordRouterProtocol {
    
    weak var viewController: DocumentNavigationDelegate?
    init(viewController: DocumentNavigationDelegate? = nil) {
        self.viewController = viewController
    }
    func openListPasswordVC() {
        let vc = ListPasswordAssembler.makeListPasswordVC()
        let navVc = UINavigationController(rootViewController: vc)
        viewController?.presentVC(navVc)
    }
    
    
}
