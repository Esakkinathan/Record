//
//  AddBillAssembler.swift
//  record
//
//  Created by Esakkinathan B on 12/02/26.
//

import UIKit

class AddBillAssembler {
    static func make(mode: BillFormMode, utilityAccountId: Int, billType: BillType) -> FormFieldViewController {
        let vc = FormFieldViewController()
        let presenter = AddBillPresenter(view: vc,mode: mode, utilityAccountId: utilityAccountId, billType: billType)
        vc.presenter = presenter
        return vc
    }
}
