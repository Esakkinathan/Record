//
//  ListDcoumentAssembler.swift
//  record
//
//  Created by Esakkinathan B on 30/01/26.
//

import UIKit



enum ListDocumentAssembler {
    
    static func make() -> UIViewController {
        
        let vc = ListDocumentViewController()
        let repo = DocumentRepository()
        let router = ListDocumentRouter(viewController: vc)
        
        let addUseCase: AddDocumentUseCaseProtocol = AddDocumentUseCase(repository: repo)
        let updateUseCase: UpdateDocumentUseCaseProtocol = UpdateDocumentUseCase(repository: repo)
        let fetchUseCase: FetchDocumentsUseCaseProtocol = FetchDocumentsUseCase(repository: repo)
        let deleteUseCase: DeleteDocumentUseCaseProtocol = DeleteDocumentUseCase(repository: repo)
        
        let presenter = ListDocumentPresenter(
            view: vc,
            router: router,
            addUseCase: addUseCase,
            updateUseCase: updateUseCase,
            deleteUseCase: deleteUseCase,
            fetchUseCase: fetchUseCase,
        )
        vc.presenter = presenter
        return vc
    }
        

}
