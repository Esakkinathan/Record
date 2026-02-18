//
//  DetailDocumentAssembler.swift
//  record
//
//  Created by Esakkinathan B on 30/01/26.
//

import UIKit

class DetailDocumentAssembler {
    static func make(document: Document) -> DetailDocumentViewController {
        let vc = DetailDocumentViewController()
        let router = DetailDocumentRouter(viewController: vc)
        let presenter = DetailDocumentPresenter(document: document, router: router)
        vc.presenter = presenter
        presenter.view = vc
        return vc
    }
}
