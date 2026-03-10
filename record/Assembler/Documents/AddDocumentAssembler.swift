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
        let fetchUseCase = FetchDocumentsUseCase(repository: DocumentRepository())
        let presenter = AddDocumentPresenter(view: vc, router: router, mode: mode, fetchUseCase: fetchUseCase)
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
