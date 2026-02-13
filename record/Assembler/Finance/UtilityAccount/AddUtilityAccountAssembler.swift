//
//  AddUtilityAssembler.swift
//  record
//
//  Created by Esakkinathan B on 12/02/26.
//
import UIKit

class AddUtilityAccountAssembler {
    static func make(mode: UtilityAccountFormMode, utility: Utility) -> FormFieldViewController {
        let vc = FormFieldViewController()
        let presenter = AddUtilityAccountPresenter(view: vc, mode: mode, utility: utility)
        vc.presenter = presenter
        return vc
    }
}
