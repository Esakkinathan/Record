//
//  ListUtilityAccountAssembler.swift
//  record
//
//  Created by Esakkinathan B on 12/02/26.
//

import UIKit

class ListUtilityAccountAssembler {
    static func make(utility: Utility) -> ListUtilityAccountViewController {
        let vc = ListUtilityAccountViewController()
        let router = ListUtilityAccountRouter(viewController: vc)
        let repo = UtilityAccountRepository()
        let addUseCase = AddUtilityAccountUseCase(repository: repo)
        let updateUseCase = UpdateUtilityAccountUseCase(repository: repo)
        let fetchUseCase = FetchUtilityAccountUseCase(repository: repo)
        let deleteUseCase = DeleteUtilityAccountUseCase(repository: repo)
        let updateNotesUseCase = UpdateUtilityAccountNotesUseCase(repository: repo)
        let presenter = ListUtilityAccountPresenter(view: vc, addUseCase: addUseCase, updateUseCase: updateUseCase, deleteUseCase: deleteUseCase, updateNotesUseCase: updateNotesUseCase, fetchUseCase: fetchUseCase,router: router, utility: utility)
        vc.presenter = presenter
        return vc
    }
}
