//
//  ListBillRouter.swift
//  record
//
//  Created by Esakkinathan B on 12/02/26.
//
import VTDB

class ListBillRouter: ListBillRouterProtocol {
    
    weak var viewController: DocumentNavigationDelegate?
    
    init(viewController: DocumentNavigationDelegate? = nil) {
        self.viewController = viewController
    }
    
    func openAddBillVC(mode: BillFormMode, utilityAccountId: Int, type: BillType, onChange: @escaping (Persistable) -> Void) {
        let vc = AddBillAssembler.make(mode: mode, utilityAccountId: utilityAccountId, billType: type)
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
    
    func openEditBillVC(mode: BillFormMode, utilityAccoundId: Int, type: BillType, onEdit: @escaping (Persistable) -> Void) {
        //
    }


}
