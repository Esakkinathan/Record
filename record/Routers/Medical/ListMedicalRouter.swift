//
//  Untitled.swift
//  record
//
//  Created by Esakkinathan B on 09/02/26.
//
import UIKit

class ListMedicalRouter: ListMedicalRouterProtocol {
    
    weak var viewController: DocumentNavigationDelegate?
    
    init(viewController: DocumentNavigationDelegate? = nil) {
        self.viewController = viewController
    }
    
    func openAddMedicalVC(mode: MedicalFormMode, onAdd: @escaping (Medical) -> Void) {
        let vc = AddMedicalAssembler.make(mode: mode)
        vc.onAdd = onAdd
        let navVc = UINavigationController(rootViewController: vc)
        navVc.modalPresentationStyle = .formSheet
        viewController?.presentVC(navVc)
    }
    func openDetailMedicalVC(medical: Medical, onUpdate: @escaping (Medical) -> Void, onUpdateNotes: @escaping (String?, Int) -> Void) {
        let vc = DetailMedicalAssembler.make(medical: medical)
        vc.onEdit = onUpdate
        vc.onUpdateNotes = onUpdateNotes
        viewController?.push(vc)
    }

    
}
