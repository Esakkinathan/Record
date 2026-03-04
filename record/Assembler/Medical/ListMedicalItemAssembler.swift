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
        let repo = MedicineRepository()
        let addUseCase = AddMedicineUseCase(repository: repo)
        let updateUseCase = UpdateMedicineUseCase(repository: repo)
        let deleteUseCase = DeleteMedicineUseCase(repository: repo)
        let fetchUseCase = FetchMedicineUseCase(repository: repo)

        let logRepo = MedicalIntakeLogRepository()
        
        let addLogUseCase = AddLogUseCase(repository: logRepo)
        let updateLogUseCase = UpdateLogUseCase(repository: logRepo)
        let fetchLogUseCase = FetchLogUseCase(repository: logRepo)

        
        let presenter = ListMedicalItemPresenter(view: vc, router: router, kind: kind, addUseCase: addUseCase, updateUseCase: updateUseCase, deleteUseCase: deleteUseCase, fetchUseCase: fetchUseCase, medical: medical, addLogUseCase: addLogUseCase, updateLogUseCase: updateLogUseCase, fetchLogUseCase: fetchLogUseCase)
        vc.presenter = presenter
        
        return vc
    }
}
