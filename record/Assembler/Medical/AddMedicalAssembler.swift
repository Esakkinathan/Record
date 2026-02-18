//
//  AddMedicalAssembler.swift
//  record
//
//  Created by Esakkinathan B on 09/02/26.
//
import UIKit
class AddMedicalAssembler {
    
    static func make(mode: MedicalFormMode) -> FormFieldViewController {
        let vc = FormFieldViewController()
        let router =  AddMedicalRouter(viewController: vc)
        let presenter = AddMedicalPresenter(view: vc, router: router, mode: mode)
        vc.presenter = presenter
        return vc
        
    }
}
