//
//  ListMedicalItemAssembler.swift
//  record
//
//  Created by Esakkinathan B on 10/02/26.
//
import UIKit

class ListMedicalItemAssembler {
    static func make(kind: MedicalKind, medical: Medical) -> ListMedicalItemViewController {
        let vc = ListMedicalItemViewController()
        let router = ListMedicaItemRouter(viewController: vc)
        let repo = MedicalItemRepository()
        let addUseCase = AddMedicalItemUseCase(repository: repo)
        let updateUseCase = UpdateMedicalItemUseCase(repository: repo)
        let deleteUseCase = DeleteMedicalItemUseCase(repository: repo)
        let fetchUseCase = FetchMedicalItemUseCase(repository: repo)

        let presenter = ListMedicalItemPresenter(view: vc, router: router, kind: kind, addUseCase: addUseCase, updateUseCase: updateUseCase, deleteUseCase: deleteUseCase, fetchUseCase: fetchUseCase, medical: medical)
        vc.presenter = presenter
        
        return vc
    }
}
