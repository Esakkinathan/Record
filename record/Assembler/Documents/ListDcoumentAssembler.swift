//
//  ListDcoumentAssembler.swift
//  record
//
//  Created by Esakkinathan B on 30/01/26.
//

import UIKit



enum ListDocumentAssembler {
    
    static func makeListDocumentScreen() -> UIViewController {
        
        let vc = ListDocumentViewController()
        let repo = DocumentRepository()
        let router = ListDocumentRouter(viewController: vc)
        
        let addUseCase = AddDocumentUseCase(repository: repo)
        let updateUseCase = UpdateDocumentUseCase(repository: repo)
        let fetchUseCase = FetchDocumentsUseCase(repository: repo)
        let deleteUseCase = DeleteDocumentUseCase(repository: repo)
        let updateNotesUseCase = UpdateDocumentNotesUseCase(repository: repo)
        let presenter = ListDocumentPresenter(
            view: vc,
            router: router,
            addUseCase: addUseCase,
            updateUseCase: updateUseCase,
            deleteUseCase: deleteUseCase,
            fetchUseCase: fetchUseCase,
            updateNotesUseCase: updateNotesUseCase
        )
        vc.presenter = presenter
        return vc
    }
        

}
