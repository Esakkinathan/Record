//
//  ListMedicaItemRoter.swift
//  record
//
//  Created by Esakkinathan B on 10/02/26.
//
import UIKit

class ListMedicaItemRouter: ListMedicalItemRouterProtocol {
    weak var viewController: DocumentNavigationDelegate?
    
    init(viewController: DocumentNavigationDelegate? = nil) {
        self.viewController = viewController
    }
    
    func openAddMedicalItemVC(mode: MedicalItemFormMode, medicalId: Int, kind: MedicalKind,onAdd: @escaping (MedicalItem) -> Void) {
        let vc = AddMedicalItemAssembler.make(mode: mode, medicalId: medicalId, kind: kind)
        vc.onAdd = onAdd
        let navVc = UINavigationController(rootViewController: vc)
        navVc.modalPresentationStyle = .formSheet
        viewController?.presentVC(navVc)

    }
    
    func openEditMedicalItemVC(mode: MedicalItemFormMode, medicalId: Int, kind: MedicalKind, onEdit: @escaping (MedicalItem) -> Void) {
        let vc = AddMedicalItemAssembler.make(mode: mode, medicalId: medicalId, kind: kind)
        vc.onEdit = onEdit
        let navVc = UINavigationController(rootViewController: vc)
        navVc.modalPresentationStyle = .formSheet
        viewController?.presentVC(navVc)

    }

}
