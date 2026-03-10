//
//  Untitled.swift
//  record
//
//  Created by Esakkinathan B on 09/02/26.
//
import UIKit
import VTDB
class ListMedicalRouter: ListMedicalRouterProtocol {
    
    weak var viewController: DocumentNavigationDelegate?
    
    init(viewController: DocumentNavigationDelegate? = nil) {
        self.viewController = viewController
    }
    
    func openAddMedicalVC(mode: MedicalFormMode, onAdd: @escaping (Persistable) -> Void) {
        let vc = AddMedicalAssembler.make(mode: mode)
        vc.onAdd = onAdd
        let navVc = UINavigationController(rootViewController: vc)
        navVc.modalPresentationStyle = .pageSheet
        viewController?.presentVC(navVc)
    }
    func openDetailMedicalVC(medical: Medical) {
        let vc = DetailMedicalAssembler.make(medical: medical)
        viewController?.push(vc)
    }
}
