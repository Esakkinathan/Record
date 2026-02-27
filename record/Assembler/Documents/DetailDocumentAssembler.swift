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
        let repo = RemainderRepository()
        let addUseCase = AddRemainderUseCase(repository: repo)
        let fetchUseCase = FetchRemainderUseCase(repository: repo)
        let deleteUseCase = DeleteRemainderUseCase(repository: repo)
        let presenter = DetailDocumentPresenter(document: document, router: router, addRemainderUseCase: addUseCase, fetchRemainderUseCase: fetchUseCase, deleteRemainderUseCase: deleteUseCase)
        vc.presenter = presenter
        presenter.view = vc
        return vc
    }
}
