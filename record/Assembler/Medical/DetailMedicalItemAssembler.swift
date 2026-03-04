//
//  DetailMedicalItemAssembler.swift
//  record
//
//  Created by Esakkinathan B on 26/02/26.
//
import UIKit

class DetailMedicalItemAssembler {
    static func make(medicalItem: Medicine, medical: Medical) -> DetailMedicalItemViewController {
        let vc = DetailMedicalItemViewController()
        let updateUseCase = UpdateMedicineUseCase(repository: MedicineRepository())
        let router = DetailMedicineRouter(view: vc)
        let presenter = DetailMedicalItemPresenter(view: vc, medicalItem: medicalItem, router: router,updateUseCase: updateUseCase,medical: medical)
        vc.presenter = presenter
        return vc
    }
}
