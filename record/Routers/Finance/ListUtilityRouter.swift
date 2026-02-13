//
//  Untitled.swift
//  record
//
//  Created by Esakkinathan B on 11/02/26.
//
import VTDB

class ListUtilityRouter: ListUtilityRouterProtocol {
    weak var viewController: DocumentNavigationDelegate?
    
    init(viewController: DocumentNavigationDelegate? = nil) {
        self.viewController = viewController
    }
    
    func openListUtilityAccountVC(utility: Utility) {
        let vc = ListUtilityAccountAssembler.make(utility: utility)
        viewController?.push(vc)
    }
    
    func openAddUtilityVC(mode: UtilityFormMode, onChange: ((Persistable) -> Void)?) {
        let vc = AddUtilityAssembler.make(mode: mode)
        switch mode {
        case .add:
            vc.onEdit = onChange
        case .edit(_):
            vc.onAdd = onChange
        }
        let navVc = UINavigationController(rootViewController: vc)
        navVc.modalPresentationStyle = .formSheet

        viewController?.presentVC(navVc)
    }
}
