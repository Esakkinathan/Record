//
//  ListMedicaItemRoter.swift
//  record
//
//  Created by Esakkinathan B on 10/02/26.
//
import UIKit
import VTDB

class ListMedicaItemRouter: ListMedicalItemRouterProtocol {
    weak var viewController: DocumentNavigationDelegate?
    
    init(viewController: DocumentNavigationDelegate? = nil) {
        self.viewController = viewController
    }
    
    func openAddMedicalItemVC(mode: MedicalItemFormMode, medicalId: Int, kind: MedicalKind,startDate: Date,onAdd: @escaping (Persistable) -> Void) {
        let vc = AddMedicalItemAssembler.make(mode: mode, medicalId: medicalId, kind: kind,startDate: startDate)
        vc.onAdd = onAdd
        let navVc = UINavigationController(rootViewController: vc)
        navVc.modalPresentationStyle = .formSheet
        viewController?.presentVC(navVc)

    }
    
    func openEditMedicalItemVC(mode: MedicalItemFormMode, medicalId: Int, kind: MedicalKind, startDate: Date, onEdit: @escaping (Persistable) -> Void) {
        let vc = AddMedicalItemAssembler.make(mode: mode, medicalId: medicalId, kind: kind, startDate: startDate)
        vc.onEdit = onEdit
        let navVc = UINavigationController(rootViewController: vc)
        navVc.modalPresentationStyle = .formSheet
        viewController?.presentVC(navVc)

    }

}
