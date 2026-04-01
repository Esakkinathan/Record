//
//  DetailMedicalItemAssembler.swift
//  record
//
//  Created by Esakkinathan B on 26/02/26.
//
import UIKit

class DetailMedicalItemAssembler {
    static func make(medicalItem: Medicine, medical: Medical, date: Date) -> DetailMedicalItemViewController {
        let vc = DetailMedicalItemViewController()
        let updateUseCase = UpdateMedicineUseCase(repository: MedicineRepository())
        let router = DetailMedicineRouter(view: vc)
        //let updateUseCase = UpdateMedicineUseCase(repository: MedicineRepository())
        let logRepo = MedicalIntakeLogRepository()
        
        let addLogUseCase = AddLogUseCase(repository: logRepo)
        let updateLogUseCase = UpdateLogUseCase(repository: logRepo)
        let fetchLogUseCase = FetchLogUseCase(repository: logRepo)

        let presenter = DetailMedicalItemPresenter(view: vc, medicalItem: medicalItem, router: router,updateUseCase: updateUseCase,medical: medical,date: date, addLogUseCase: addLogUseCase, updateLogUseCase: updateLogUseCase, fetchLogUseCase: fetchLogUseCase )
        vc.presenter = presenter
        return vc
    }
}
