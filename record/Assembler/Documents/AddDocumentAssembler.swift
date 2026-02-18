//
//  AddDocumentViewAssembler.swift
//  record
//
//  Created by Esakkinathan B on 30/01/26.
//

import UIKit

class AddDocumentAssembler {
    static func make(mode: DocumentFormMode) -> FormFieldViewController {
        
        let vc = FormFieldViewController()
        let router = AddDocumentRouter(viewController: vc)
        let presenter = AddDocumentFormPresenter(view: vc, router: router, mode: mode)
        vc.presenter = presenter
        return vc
        
    }
}

class SuggesPasswordScreenAssembler {
    static func make() -> SuggesPasswordViewController {
        let vc = SuggesPasswordViewController()
        return vc
    }
}
