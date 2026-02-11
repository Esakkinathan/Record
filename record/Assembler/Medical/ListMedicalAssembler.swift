//
//  ListMedicalAssembler.swift
//  record
//
//  Created by Esakkinathan B on 09/02/26.
//

import UIKit
class ListMedicalAssembler {
    static func make() ->  ListMedicalViewController {
        let vc = ListMedicalViewController()
        let router = ListMedicalRouter(viewController: vc)
        
        let repo = MedicalRepository()
        let addUseCase = AddMedicalUseCase(repository: repo)
        let updateUseCase = UpdateMedicalUseCase(repository: repo)
        let fetchUseCase = FetchMedicalUseCase(repository: repo)
        let deleteUseCase = DeleteMedicalUseCase(repository: repo)
        let updateNotesUseCase = UpdateMedicalNotesUseCase(repository: repo)
        
        let presenter = ListMedicalPresenter(view: vc, router: router, addUseCase: addUseCase, updateUseCase: updateUseCase, deleteUseCase: deleteUseCase, fetchUseCase: fetchUseCase, updateNotesUseCase: updateNotesUseCase)
        vc.presenter = presenter
        return vc
    }
}
