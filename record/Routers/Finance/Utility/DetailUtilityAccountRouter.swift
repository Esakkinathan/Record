//
//  DetailUtilityAccountRouter.swift
//  record
//
//  Created by Esakkinathan B on 12/02/26.
//
import VTDB
class DetailUtilityAccountRouter: DetailUtilityAccountRouterProtocol {
    
    weak var viewController: DocumentNavigationDelegate?
    
    init(viewController: DocumentNavigationDelegate? = nil) {
        self.viewController = viewController
    }
    
    func openListBillVC(type: BillType, utilityAccount: UtilityAccount) {
        let vc = ListBillAssembler.make(type: type, utilityAccount: utilityAccount)
        viewController?.push(vc)
    }
    
    func openEditUtilityAccountVC(mode: UtilityAccountFormMode, utility: Utility,onEdit: @escaping (Persistable) -> Void) {
        let vc = AddUtilityAccountAssembler.make(mode: mode, utility: utility)
        vc.onEdit = onEdit
        let navVc = UINavigationController(rootViewController: vc)
        navVc.modalPresentationStyle = .formSheet
        viewController?.presentVC(navVc)

    }


}
