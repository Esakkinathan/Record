//
//  AddUtilityAssembler.swift
//  record
//
//  Created by Esakkinathan B on 11/02/26.
//
import UIKit

class AddUtilityAssembler {
    static func make(mode: UtilityFormMode) -> FormFieldViewController {
        let vc = FormFieldViewController()
        let presenter = AddUtilityPresenter(view: vc, mode: mode)
        vc.presenter = presenter
        
        return vc
    }
}
