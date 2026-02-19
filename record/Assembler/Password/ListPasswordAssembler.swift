//
//  ListPasswordAssembler.swift
//  record
//
//  Created by Esakkinathan B on 03/02/26.
//

import UIKit

class ListPasswordAssembler {
    static func make() -> ListPasswordViewController {
        let vc = ListPasswordViewController()
        let router = ListPasswordRouter(viewController: vc)
        
        let repository = PasswordRepository()
        
        let addUseCase = AddPasswordUseCase(repository: repository)
        let updateUseCase = UpdatePasswordUseCase(repository: repository)
        let fetchUseCase = FetchPasswordUseCase(repository: repository)
        let deleteUseCase = DeletePasswordUseCase(repository: repository)
        let updateNotesUseCase = UpdatePasswordNotesUseCase(repository: repository)
        let toggleFavouriteUseCase = ToggleFavouriteUseCase(repository: repository)
        let presenter = ListPasswordPresenter(
            view: vc,
            router: router,
            addUseCase: addUseCase,
            updateUseCase: updateUseCase,
            deleteUseCase: deleteUseCase,
            fetchUseCase: fetchUseCase,
            updateNotesUseCase: updateNotesUseCase,
            toggleFavouriteUseCase: toggleFavouriteUseCase
        )
        vc.presenter = presenter
        return vc

    }
}
