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
    
    func openAddMedicalItemVC(mode: MedicalItemFormMode, medical: Medical, kind: MedicalKind,startDate: Date,onAdd: @escaping (Persistable) -> Void) {
        let vc = AddMedicalItemAssembler.make(mode: mode, medical: medical, kind: kind,startDate: startDate)
        switch mode {
        case .add:
            vc.onAdd = onAdd
        case .edit(_):
            vc.onEdit = onAdd
        }
        let navVc = UINavigationController(rootViewController: vc)
        navVc.modalPresentationStyle = .pageSheet
        viewController?.presentVC(navVc)

    }
    

}
