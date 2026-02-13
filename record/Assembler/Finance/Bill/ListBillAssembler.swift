//
//  ListBillAssembler.swift
//  record
//
//  Created by Esakkinathan B on 12/02/26.
//
import UIKit

class ListBillAssembler {
    static func make(type: BillType, utilityAccount: UtilityAccount) -> ListBillViewController {
        let vc = ListBillViewController()
        let router = ListBillRouter(viewController: vc)
        
        let repo = BillRepository()
        
        let addUseCase = AddBillUseCase(repository: repo)
        let updateUseCase = UpdateBillUseCase(repository: repo)
        let fetchUseCase = FetchBillUseCase(repository: repo)
        let deleteUseCase = DeleteBillUseCase(repository: repo)
        let markAsPaidUseCase = MarkAsPaidUseCase(repository: repo)
        let presenter = ListBillPresenter(view: vc,router: router, billType: type, addUseCase: addUseCase, updateUseCase: updateUseCase, deleteUseCase: deleteUseCase, fetchUseCase: fetchUseCase, markAsPaidUseCase: markAsPaidUseCase ,utilityAccount: utilityAccount)
        
        vc.presenter = presenter
        
        return vc

    }
}
