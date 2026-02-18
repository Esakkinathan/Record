//
//  DetailMedicalRouter.swift
//  record
//
//  Created by Esakkinathan B on 09/02/26.
//

import UIKit
import VTDB

class DetailMedicalRouter: DetailMedicalRouterProtocol {
    
    
    weak var viewController: DocumentNavigationDelegate?
    
    init(viewController: DocumentNavigationDelegate? = nil) {
        self.viewController = viewController
    }
    
    func openEditMedicalVC(mode: MedicalFormMode, onEdit: @escaping ((Persistable) -> Void)) {
        let vc = AddMedicalAssembler.make(mode: mode)
        vc.onEdit = onEdit
        
        let navVc = UINavigationController(rootViewController: vc)
        navVc.modalPresentationStyle = .formSheet
        viewController?.presentVC(navVc)
        
    }
    func openListMedicalItemVC(kind: MedicalKind, medical: Medical) {
        let vc = ListMedicalItemAssembler.make(kind: kind, medical: medical)
        viewController?.push(vc)
    }

    


}
