//
//  AddMedicalItemAssembler.swift
//  record
//
//  Created by Esakkinathan B on 10/02/26.
//
import UIKit
class AddMedicalItemAssembler {
    static func make(mode: MedicalItemFormMode, medical: Medical, kind: MedicalKind, startDate: Date) -> FormFieldViewController {
        let vc = FormFieldViewController()
        let router = AddMedicalItemRouter(viewController: vc)
        let presenter = AddMedicalItemPresenter(view: vc, router: router, mode: mode,medical: medical, kind: kind, startDate: startDate)
        vc.presenter = presenter
        return vc
    }
}
