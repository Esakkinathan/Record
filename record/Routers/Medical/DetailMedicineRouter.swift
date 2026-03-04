//
//  DetailMedicineRouter.swift
//  record
//
//  Created by Esakkinathan B on 04/03/26.
//
import VTDB

protocol DetailMedicineRouterProtocol {
    func openEditMedicalVC(mode: MedicalItemFormMode, medical: Medical, kind: MedicalKind, startDate: Date,onEdit: @escaping ((Persistable) -> Void))

}
class DetailMedicineRouter: DetailMedicineRouterProtocol {
    weak var viewController: DocumentNavigationDelegate?
    init(view: DocumentNavigationDelegate? = nil) {
        self.viewController = view
    }
    func openEditMedicalVC(mode: MedicalItemFormMode, medical: Medical, kind: MedicalKind, startDate: Date, onEdit: @escaping ((Persistable) -> Void)) {
        let vc = AddMedicalItemAssembler.make(mode: mode, medical: medical, kind: kind, startDate: startDate)
        let navVc = UINavigationController(rootViewController: vc)
        navVc.modalPresentationStyle = .pageSheet
        viewController?.presentVC(navVc)
    }
    
}
