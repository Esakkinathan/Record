//
//  AddDocumentViewAssembler.swift
//  record
//
//  Created by Esakkinathan B on 30/01/26.
//

import UIKit

class AddDocumentAssembler {
    static func makeAddDocumentScreen(mode: DocumentFormMode) -> AddDocumentViewController {
        
        let vc = AddDocumentViewController()
        let router = AddDocumentRouter(viewController: vc)
        let presenter = AddDocumentPresenter(view: vc, router: router, mode: mode)
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
