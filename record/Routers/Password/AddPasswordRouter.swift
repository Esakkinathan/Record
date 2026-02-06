//
//  AddPasswordRouter.swift
//  record
//
//  Created by Esakkinathan B on 03/02/26.
//

import UIKit

class AddPasswordRouter: AddPasswordRouterProtocol {
    
    weak var viewController: DocumentNavigationDelegate?
    
    init(viewController: DocumentNavigationDelegate?) {
        self.viewController = viewController
    }
    func openSuggestPasswordScreen(onApply: ((String) -> Void)?) {
        let vc = SuggesPasswordScreenAssembler.make()
        vc.onApply = onApply
        let navVc = UINavigationController(rootViewController: vc)
        viewController?.presentVC(navVc)
    }

    
}
