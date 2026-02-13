//
//  ListUtilityAccountRouter.swift
//  record
//
//  Created by Esakkinathan B on 12/02/26.
//
import UIKit
import VTDB

class ListUtilityAccountRouter: ListUtilityAccountRouterProtocol {
    
    weak var viewController: DocumentNavigationDelegate?
    
    init(viewController: DocumentNavigationDelegate? = nil) {
        self.viewController = viewController
    }
    
    func openAddUtilityAccountVC(mode: UtilityAccountFormMode, utility: Utility, onChange: ((any VTDB.Persistable) -> Void)?) {
        let vc = AddUtilityAccountAssembler.make(mode: mode, utility: utility)
        switch mode {
        case .add:
            vc.onAdd = onChange
        case .edit(_):
            vc.onEdit = onChange
        }
        let navVc = UINavigationController(rootViewController: vc)
        navVc.modalPresentationStyle = .formSheet

        viewController?.presentVC(navVc)

    }
    func openDetailUtilityAccountVC(utilityAccount: UtilityAccount, utility: Utility, onUpdate: @escaping (UtilityAccount) -> Void, onUpdateNotes: @escaping (String?, Int) -> Void) {
        let vc = DetailUtilityAccountAssembler.make(utilityAccount: utilityAccount, utility: utility)
        vc.onEdit = onUpdate
        vc.onUpdateNotes = onUpdateNotes
        viewController?.push(vc)
    }

    

}
