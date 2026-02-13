//
//  ListUtilityAssembler.swift
//  record
//
//  Created by Esakkinathan B on 11/02/26.
//
import UIKit

class ListUtilityAssembler {
    static func make() -> ListUtilityViewController {
        let vc = ListUtilityViewController()
        let router = ListUtilityRouter(viewController: vc)
        let repo = UtilityRepository()
        let addUseCase = AddUtilityUseCase(repository: repo)
        let updateUseCase = UpdateUtilityUseCase(repository: repo)
        let fetchUseCase = FetchUtilityUseCase(repository: repo)
        let deleteUseCase = DeleteUtilityUseCase(repository: repo)
        //let updateNotesUseCase = UpdateUtilityNotesUseCase(repository: repo)
        let presenter = ListUtilityPresenter(view: vc, addUseCase: addUseCase, updateUseCase: updateUseCase, deleteUseCase: deleteUseCase, fetchUseCase: fetchUseCase, router: router)
        vc.presenter = presenter
        return vc
    }
}
